import SwiftUI
import AVFoundation

struct TimerContentView: View {
    @AppStorage("lastIntervalMinutes") private var intervalMinutes: Int = 5
    @AppStorage("lastIntervalSeconds") private var intervalSeconds: Int = 0
    @AppStorage("lastNumberOfRepetitions") private var numberOfRepetitions: Int = 1
    @State private var isRunning: Bool = false
    @State private var timeRemaining: Int = 0
    @State private var currentRepetition: Int = 0
    @State private var timer: Timer?
    @State private var totalTimeHours: Int = 0
    @State private var totalTimeMinutes: Int = 0
    @State private var totalTimeSeconds: Int = 0
    @State private var isEditingTotalTime: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Timer")
                .font(.headline)
                .padding(.top)
            
            if isRunning {
                // Mostrar countdown
                VStack(spacing: 10) {
                    Text("Repetition \(currentRepetition)/\(numberOfRepetitions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(timeRemaining <= 10 ? .red : .primary)
                }
                .padding()
                
                Button("Stop") {
                    stopTimer()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                // Configuração inicial
                VStack(spacing: 15) {
                    HStack {
                        Text("Interval:")
                        Spacer()
                        Picker("", selection: $intervalMinutes) {
                            ForEach(0..<301) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .frame(width: 100)
                        
                        Picker("", selection: $intervalSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Repetitions:")
                        Spacer()
                        Stepper(value: $numberOfRepetitions, in: 1...100) {
                            Text("\(numberOfRepetitions)")
                        }
                        .onChange(of: numberOfRepetitions) { _ in
                            updateTotalTimeFromRepetitions()
                        }
                    }
                    
                    HStack {
                        Text("Total time:")
                        Spacer()
                        if isEditingTotalTime {
                            HStack(spacing: 4) {
                                Picker("", selection: $totalTimeHours) {
                                    ForEach(0..<25) { hour in
                                        Text("\(hour)").tag(hour)
                                    }
                                }
                                .frame(width: 50)
                                .onChange(of: totalTimeHours) { _ in
                                    calculateRepetitionsFromTotalTime()
                                }
                                Text("h")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                
                                Picker("", selection: $totalTimeMinutes) {
                                    ForEach(0..<60) { minute in
                                        Text("\(minute)").tag(minute)
                                    }
                                }
                                .frame(width: 50)
                                .onChange(of: totalTimeMinutes) { _ in
                                    calculateRepetitionsFromTotalTime()
                                }
                                Text("m")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                
                                Picker("", selection: $totalTimeSeconds) {
                                    ForEach(0..<60) { second in
                                        Text("\(second)").tag(second)
                                    }
                                }
                                .frame(width: 50)
                                .onChange(of: totalTimeSeconds) { _ in
                                    calculateRepetitionsFromTotalTime()
                                }
                                Text("s")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                
                                Button(action: {
                                    isEditingTotalTime = false
                                }) {
                                    Text("✓")
                                        .font(.caption)
                                }
                                .buttonStyle(.borderless)
                            }
                        } else {
                            Button(action: {
                                isEditingTotalTime = true
                                updateTotalTimeFromRepetitions()
                            }) {
                                Text(formatTotalTime())
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Button("Start") {
                        startTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(intervalMinutes == 0 && intervalSeconds == 0)
                }
                .padding()
            }
            
            Divider()
                .padding(.vertical, 5)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .padding(.bottom, 10)
        }
        .frame(width: 300, height: 290)
        .padding(.horizontal, 10)
        .onAppear {
            updateTotalTimeFromRepetitions()
        }
        .onChange(of: intervalMinutes) { _ in
            if !isEditingTotalTime {
                updateTotalTimeFromRepetitions()
            }
        }
        .onChange(of: intervalSeconds) { _ in
            if !isEditingTotalTime {
                updateTotalTimeFromRepetitions()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
        let totalSeconds = intervalMinutes * 60 + intervalSeconds
        guard totalSeconds > 0 else { return }
        
        currentRepetition = 1
        timeRemaining = totalSeconds
        isRunning = true
        
        // Notificar a repetição atual
        notifyRepetitionChanged()
        // Notificar progresso inicial
        notifyTimerProgress()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                // Notificar progresso a cada segundo
                notifyTimerProgress()
            } else {
                // Timer terminou
                playAlertSound()
                
                if currentRepetition < numberOfRepetitions {
                    // Próxima repetição
                    currentRepetition += 1
                    timeRemaining = totalSeconds
                    // Notificar mudança de repetição
                    notifyRepetitionChanged()
                    // Notificar progresso (resetado para nova repetição)
                    notifyTimerProgress()
                } else {
                    // Todas as repetições completas
                    stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = 0
        currentRepetition = 0
        
        // Notificar que o timer parou (para resetar o ícone)
        NotificationCenter.default.post(name: NSNotification.Name("TimerStopped"), object: nil)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    func formatTotalTime() -> String {
        let intervalTotalSeconds = intervalMinutes * 60 + intervalSeconds
        let totalSeconds = intervalTotalSeconds * numberOfRepetitions
        
        if totalSeconds == 0 {
            return "0:00:00"
        }
        
        let totalDays = totalSeconds / 86400
        let remainingAfterDays = totalSeconds % 86400
        let totalHours = remainingAfterDays / 3600
        let remainingAfterHours = remainingAfterDays % 3600
        let totalMinutes = remainingAfterHours / 60
        let totalSecs = remainingAfterHours % 60
        
        if totalDays > 0 {
            return String(format: "%d day%@ %d:%02d:%02d hours", 
                         totalDays, 
                         totalDays == 1 ? "" : "s",
                         totalHours, 
                         totalMinutes, 
                         totalSecs)
        } else if totalHours > 0 {
            return String(format: "%d:%02d:%02d hours", totalHours, totalMinutes, totalSecs)
        } else {
            return String(format: "%d:%02d", totalMinutes, totalSecs)
        }
    }
    
    func playAlertSound() {
        // Usar o som de sistema padrão
        NSSound.beep()
        
        // Alternativa: usar um som mais alto
        if let sound = NSSound(named: "Glass") {
            sound.play()
        }
    }
    
    func notifyRepetitionChanged() {
        NotificationCenter.default.post(
            name: NSNotification.Name("RepetitionChanged"),
            object: nil,
            userInfo: [
                "current": currentRepetition,
                "total": numberOfRepetitions
            ]
        )
    }
    
    func notifyTimerProgress() {
        let totalSeconds = intervalMinutes * 60 + intervalSeconds
        NotificationCenter.default.post(
            name: NSNotification.Name("TimerProgress"),
            object: nil,
            userInfo: [
                "remaining": timeRemaining,
                "total": totalSeconds
            ]
        )
    }
    
    func updateTotalTimeFromRepetitions() {
        let intervalTotalSeconds = intervalMinutes * 60 + intervalSeconds
        let totalSeconds = intervalTotalSeconds * numberOfRepetitions
        
        totalTimeHours = totalSeconds / 3600
        let remainingAfterHours = totalSeconds % 3600
        totalTimeMinutes = remainingAfterHours / 60
        totalTimeSeconds = remainingAfterHours % 60
    }
    
    func calculateRepetitionsFromTotalTime() {
        let intervalTotalSeconds = intervalMinutes * 60 + intervalSeconds
        guard intervalTotalSeconds > 0 else { return }
        
        let totalTimeInSeconds = totalTimeHours * 3600 + totalTimeMinutes * 60 + totalTimeSeconds
        let calculatedRepetitions = totalTimeInSeconds / intervalTotalSeconds
        
        if calculatedRepetitions > 0 && calculatedRepetitions <= 100 {
            numberOfRepetitions = calculatedRepetitions
        } else if calculatedRepetitions > 100 {
            numberOfRepetitions = 100
        } else {
            numberOfRepetitions = 1
        }
    }
}

