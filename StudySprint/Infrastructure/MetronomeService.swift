//
//  MetronomeService.swift
//  StudySprint
//

import AVFoundation
import Combine

class MetronomeService: NSObject, ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var buffer: AVAudioPCMBuffer?
    private var timer: Timer?
    private var isPlayingInternal = false
    private var currentBPMInternal: Int = 250
    
    @Published var isEnabled = false
    
    var isPlaying: Bool {
        return isPlayingInternal
    }
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine, let playerNode = playerNode else { return }
        
        audioEngine.attach(playerNode)
        
        let mainMixer = audioEngine.mainMixerNode
        let outputFormat = mainMixer.outputFormat(forBus: 0)
        
        audioEngine.connect(playerNode, to: mainMixer, format: outputFormat)
        
        // Crear el sonido "tick"
        createTickSound(format: outputFormat)
        
        do {
            try audioEngine.start()        } catch {
        }
    }
    
    private func createTickSound(format: AVAudioFormat) {
        let sampleRate = format.sampleRate
        let duration: Float = 0.05 // 50 milisegundos de duración
        let frameCount = AVAudioFrameCount(duration * Float(sampleRate))
        
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        pcmBuffer.frameLength = frameCount
        
        guard let channels = pcmBuffer.floatChannelData else { return }
        
        let frequency: Float = 880 // 880 Hz = nota La5 (un tick agradable)
        let amplitude: Float = 0.3 // Volumen moderado
        
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let value = amplitude * sin(Float(Double .pi) * frequency * time)
            
            // Aplicar envolvente de caída rápida (para que sea un "tick" corto)
            let envelope: Float
            if time < 0.01 {
                envelope = time / 0.01 // Aumento rápido
            } else {
                envelope = max(0, 1 - (time - 0.01) / 0.04) // Caída rápida
            }
            
            let finalValue = value * envelope
            
            for channel in 0..<Int(pcmBuffer.format.channelCount) {
                channels[channel][frame] = finalValue
            }
        }
        
        buffer = pcmBuffer
    }
    
    func setBPM(_ bpm: Int) {
        currentBPMInternal = bpm
        
        if isPlayingInternal && isEnabled {
            restartTimer()
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stop()
        }
    }
    
    func start() {
        guard isEnabled else { return }
        
        if isPlayingInternal {
            stop()
        }
        
        isPlayingInternal = true
        startTimer()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isPlayingInternal = false
    }
    
    private func restartTimer() {
        guard isPlayingInternal && isEnabled else { return }
        
        timer?.invalidate()
        timer = nil
        startTimer()
    }
    
    private func startTimer() {
        let interval = 60.0 / Double(currentBPMInternal)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playTick()
        }
    }
    
    private func playTick() {
        guard let playerNode = playerNode, let buffer = buffer else { return }
        
        if !playerNode.isPlaying {
            playerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
            playerNode.play()
        } else {
            // Si ya está reproduciendo, solo programamos otro buffer
            playerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        }
    }
}
