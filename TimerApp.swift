import SwiftUI
import AppKit

@main
struct TimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    var originalImage: NSImage?
    var eventMonitor: EventMonitor?
    var currentRepetition: Int = 0
    var totalRepetitions: Int = 0
    var timeRemaining: Int = 0
    var totalTime: Int = 0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Esconder o ícone do dock
        NSApp.setActivationPolicy(.accessory)
        
        // Criar item na menu bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Criar imagem do ícone
        originalImage = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
        
        if let button = statusBarItem?.button {
            button.image = originalImage
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Criar popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 290)
        popover?.behavior = .transient
        popover?.delegate = self
        popover?.contentViewController = NSHostingController(rootView: TimerContentView())
        
        // Criar monitor de eventos para fechar o popover ao clicar fora
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self = self, let popover = self.popover, popover.isShown {
                self.closePopover()
            }
        }
        
        // Observar notificações do timer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(timerStopped),
            name: NSNotification.Name("TimerStopped"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(repetitionChanged(_:)),
            name: NSNotification.Name("RepetitionChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(timerProgress(_:)),
            name: NSNotification.Name("TimerProgress"),
            object: nil
        )
    }
    
    @objc func timerStopped() {
        currentRepetition = 0
        totalRepetitions = 0
        updateIcon()
    }
    
    @objc func repetitionChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let current = userInfo["current"] as? Int,
           let total = userInfo["total"] as? Int {
            currentRepetition = current
            totalRepetitions = total
            updateIcon()
        }
    }
    
    @objc func timerProgress(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let remaining = userInfo["remaining"] as? Int,
           let total = userInfo["total"] as? Int {
            timeRemaining = remaining
            totalTime = total
            updateIcon()
        }
    }
    
    func updateIcon() {
        guard let button = statusBarItem?.button else { return }
        
        // Se não estiver rodando ou não houver repetição, usar ícone original
        if currentRepetition == 0 || totalRepetitions == 0 {
            button.image = originalImage
            if #available(macOS 10.14, *) {
                button.contentTintColor = nil
            }
            return
        }
        
        // Criar imagem com barra de progresso e número da repetição
        if let imageWithProgress = createProgressBarImage(repetition: currentRepetition) {
            button.image = imageWithProgress
            if #available(macOS 10.14, *) {
                button.contentTintColor = nil
            }
        } else {
            button.image = originalImage
        }
    }
    
    func createProgressBarImage(repetition: Int) -> NSImage? {
        // Calcular o tamanho do número primeiro
        let numberString = "\(repetition)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let attributedString = NSAttributedString(string: numberString, attributes: attributes)
        let stringSize = attributedString.size()
        
        // Tamanho da barra de progresso
        let barWidth: CGFloat = 3
        let barHeight: CGFloat = 18
        let spacing: CGFloat = 4 // Espaço entre barra e número
        
        // Criar imagem mais larga para acomodar barra + número
        let totalWidth = barWidth + spacing + stringSize.width
        let imageSize = NSSize(width: totalWidth, height: 22)
        let image = NSImage(size: imageSize)
        image.isTemplate = true // Template para aparecer branco no menu bar
        
        image.lockFocus()
        
        // Calcular progresso (0.0 a 1.0)
        var progress: CGFloat = 0.0
        if totalTime > 0 {
            let elapsed = totalTime - timeRemaining
            progress = CGFloat(elapsed) / CGFloat(totalTime)
            // Arredondar para múltiplos de 10% (0.0, 0.1, 0.2, ..., 1.0)
            progress = round(progress * 10) / 10
            progress = min(max(progress, 0.0), 1.0)
        }
        
        // Desenhar barra de progresso vertical (de baixo para cima)
        let barX: CGFloat = 0
        let barY: CGFloat = (imageSize.height - barHeight) / 2
        let barRect = NSRect(x: barX, y: barY, width: barWidth, height: barHeight)
        
        // Desenhar fundo da barra (vazio)
        NSColor.white.withAlphaComponent(0.3).setFill()
        barRect.fill()
        
        // Desenhar progresso (de baixo para cima)
        if progress > 0 {
            let progressHeight = barHeight * progress
            let progressY = barY
            let progressRect = NSRect(x: barX, y: progressY, width: barWidth, height: progressHeight)
            NSColor.white.setFill()
            progressRect.fill()
        }
        
        // Desenhar o número à direita da barra (branco, sem fundo)
        let numberX = barWidth + spacing
        let numberY = (imageSize.height - stringSize.height) / 2 // Centralizar verticalmente
        let numberRect = NSRect(x: numberX, y: numberY, width: stringSize.width, height: stringSize.height)
        attributedString.draw(in: numberRect)
        
        image.unlockFocus()
        
        return image
    }
    
    @objc func togglePopover() {
        guard let event = NSApp.currentEvent else { return }
        
        // Se for clique direito, mostrar menu de contexto
        if event.type == .rightMouseUp {
            showContextMenu(event: event)
            return
        }
        
        guard popover != nil else { return }
        
        if popover?.isShown == true {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    func showContextMenu(event: NSEvent) {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit Timer", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        if let button = statusBarItem?.button {
            let location = NSPoint(x: button.bounds.width / 2, y: button.bounds.height + 5)
            menu.popUp(positioning: quitItem, at: location, in: button)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func showPopover() {
        guard let button = statusBarItem?.button,
              let popover = popover else { return }
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        eventMonitor?.start()
    }
    
    func closePopover() {
        popover?.performClose(nil)
        eventMonitor?.stop()
    }
    
    // NSPopoverDelegate
    func popoverDidClose(_ notification: Notification) {
        eventMonitor?.stop()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        eventMonitor?.stop()
    }
}

// Monitor de eventos para detectar cliques fora do popover
class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

