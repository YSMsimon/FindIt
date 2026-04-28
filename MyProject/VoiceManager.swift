import Foundation
import AVFoundation
import SwiftUI

class VoiceManager: ObservableObject {
    static let shared = VoiceManager()
    private let synthesizer = AVSpeechSynthesizer()
    @AppStorage("voiceOutputEnabled") private var voiceOutputEnabled: Bool = true
    
    private init() {}
    
    func speak(_ text: String) {
        guard voiceOutputEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
} 