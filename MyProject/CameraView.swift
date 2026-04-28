import SwiftUI
import AVFoundation
private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

struct CameraView: View {
    @State private var isAuthorized = false
    @Environment(\.isPreview) private var isPreview
    @State private var isActive = true
    @StateObject private var voiceManager = VoiceManager.shared

    var body: some View {
        ZStack {
            if isAuthorized && !isPreview && isActive {
                CameraObj()
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if !isAuthorized {
                        Text("Camera Access Required")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                        Button(action: {
                            requestCameraPermission()
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Enable Camera")
                            }
                            .font(.headline)
                            .padding()
                            .background(Color("Orange"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .onAppear {
            if !isPreview {
                checkCameraPermission()
                isActive = true
            }
        }
        .onDisappear {
            isActive = false
            voiceManager.stopSpeaking()
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            isAuthorized = false
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        @unknown default:
            isAuthorized = false
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                isAuthorized = granted
            }
        }
    }
}
