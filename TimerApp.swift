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
    var blinkTimer: Timer?
    var isBlinking: Bool = false
    var originalImage: NSImage?
    var orangeImage: NSImage?
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Esconder o ícone do dock
        NSApp.setActivationPolicy(.accessory)
        
        // Criar item na menu bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Criar imagens do ícone
        originalImage = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
        orangeImage = createOrangeImage()
        
        if let button = statusBarItem?.button {
            button.image = originalImage
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Criar popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 270)
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
            selector: #selector(timerFinished),
            name: NSNotification.Name("TimerFinished"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(timerStarted),
            name: NSNotification.Name("TimerStarted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(timerStopped),
            name: NSNotification.Name("TimerStopped"),
            object: nil
        )
    }
    
    func createOrangeImage() -> NSImage? {
        guard let original = originalImage else { return nil }
        
        // Criar uma cópia da imagem e torná-la template
        let templateImage = original.copy() as? NSImage
        templateImage?.isTemplate = true
        return templateImage
    }
    
    @objc func timerFinished() {
        startBlinking()
    }
    
    @objc func timerStarted() {
        stopBlinking()
    }
    
    @objc func timerStopped() {
        stopBlinking()
    }
    
    func startBlinking() {
        // Sempre parar qualquer piscar anterior antes de iniciar um novo
        stopBlinking()
        
        isBlinking = true
        
        guard let button = statusBarItem?.button else { return }
        var showOrange = false
        var blinkCount = 0
        let maxBlinks = 6 // 3 blinks completos (0.5s * 6 = 3s)
        
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            blinkCount += 1
            
            // Parar após 3 blinks completos (3 segundos)
            if blinkCount > maxBlinks {
                self.stopBlinking()
                return
            }
            
            showOrange.toggle()
            
            if showOrange {
                // Aplicar cor laranja
                if #available(macOS 10.14, *) {
                    button.contentTintColor = .orange
                }
                button.image = self.orangeImage
            } else {
                // Voltar à cor original
                if #available(macOS 10.14, *) {
                    button.contentTintColor = nil
                }
                button.image = self.originalImage
            }
        }
    }
    
    func stopBlinking() {
        isBlinking = false
        blinkTimer?.invalidate()
        blinkTimer = nil
        
        guard let button = statusBarItem?.button else { return }
        if #available(macOS 10.14, *) {
            button.contentTintColor = nil
        }
        button.image = originalImage
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
        blinkTimer?.invalidate()
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

