//
//  PhotoView.swift
//  MyProject
//
//  Created by Simon Yang on 2025-03-16.
//

import SwiftUI
import PhotosUI
import Vision
import CoreML
import AVFoundation

struct PhotoView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var classificationResults: [String] = []
    @State private var isAuthorized = false
    @State private var showPermissionAlert = false
    @State private var detectedObjects: [VNRecognizedObjectObservation] = []
    @State private var showResults = false
    @AppStorage("voiceOutputEnabled") private var voiceOutputEnabled: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let selectedImage {
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                        
                        ForEach(detectedObjects.indices, id: \.self) { index in
                            let observation = detectedObjects[index]
                            DetectionBoxView(observation: observation, imageSize: selectedImage.size)
                        }
                    }
                }
                
                PhotosPicker(selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Upload Photo")
                    }
                    .font(.headline)
                    .padding()
                    .background(Color("Orange"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                            await detectObjects(in: image)
                        }
                    }
                }
                
                if showResults && !detectedObjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Objects:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(detectedObjects.indices, id: \.self) { index in
                            let observation = detectedObjects[index]
                            if let topLabel = observation.labels.first {
                                Text("\(topLabel.identifier) - \(String(format: "%.2f", topLabel.confidence * 100))%")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color("Grey").opacity(0.7))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .onAppear {
            checkPhotoLibraryPermission()
        }
        .alert("Photo Library Access Required", isPresented: $showPermissionAlert) {
            Button("Go to Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow access to your photo library in Settings to use this feature.")
        }
    }
    
    private func detectObjects(in image: UIImage) async {
        guard let model = try? YOLOv3() else {
            print("Failed to load YOLOv3 model")
            return
        }
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("Failed to convert image to pixel buffer")
            return
        }
        
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: model.model)) { request, error in
            if let error = error {
                print("Vision ML request error: \(error)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            DispatchQueue.main.async {
                self.detectedObjects = results
                self.showResults = true
                
                // Announce detected objects
                if self.voiceOutputEnabled {
                    for observation in results {
                        if let topLabel = observation.labels.first, topLabel.confidence > 0.5 {
                            let confidence = Int(topLabel.confidence * 100)
                            self.speak("Detected \(topLabel.identifier) with \(confidence) percent confidence")
                        }
                    }
                }
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? await handler.perform([request])
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isAuthorized = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    isAuthorized = newStatus == .authorized || newStatus == .limited
                    if !isAuthorized {
                        showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            isAuthorized = false
            showPermissionAlert = true
        @unknown default:
            isAuthorized = false
            showPermissionAlert = true
        }
    }
}

struct DetectionBoxView: View {
    let observation: VNRecognizedObjectObservation
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let box = observation.boundingBox
            let rect = CGRect(
                x: box.minX * geometry.size.width,
                y: (1 - box.maxY) * geometry.size.height,
                width: box.width * geometry.size.width,
                height: box.height * geometry.size.height
            )
            
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            if let topLabel = observation.labels.first {
                Text("\(topLabel.identifier) \(Int(topLabel.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .position(x: rect.minX, y: rect.minY - 10)
            }
        }
    }
}

// Helper extension to convert UIImage to CVPixelBuffer
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                       Int(size.width),
                                       Int(size.height),
                                       kCVPixelFormatType_32ARGB,
                                       attrs,
                                       &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                              width: Int(size.width),
                              height: Int(size.height),
                              bitsPerComponent: 8,
                              bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}

#Preview {
    PhotoView()
}
