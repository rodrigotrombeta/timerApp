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
        .frame(width: 300, height: 270)
        .padding(.horizontal, 10)
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
        
        // Notificar que o timer iniciou (para resetar o ícone)
        NotificationCenter.default.post(name: NSNotification.Name("TimerStarted"), object: nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Timer terminou
                playAlertSound()
                
                // Notificar que o timer acabou (para piscar o ícone)
                NotificationCenter.default.post(name: NSNotification.Name("TimerFinished"), object: nil)
                
                if currentRepetition < numberOfRepetitions {
                    // Próxima repetição
                    currentRepetition += 1
                    timeRemaining = totalSeconds
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
    
    func playAlertSound() {
        // Usar o som de sistema padrão
        NSSound.beep()
        
        // Alternativa: usar um som mais alto
        if let sound = NSSound(named: "Glass") {
            sound.play()
        }
    }
}

