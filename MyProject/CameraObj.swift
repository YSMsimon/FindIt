import UIKit
import AVFoundation
import Vision
import CoreML
import SwiftUI

// SwiftUI wrapper for the UIKit camera view controller
struct CameraObj: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraObjectDetectionViewController {
        return CameraObjectDetectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraObjectDetectionViewController, context: Context) {
        // Update if needed
    }
}

class CameraObjectDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Camera Capture Properties
    private let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput!
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var rootLayer: CALayer!
    private var bufferSize: CGSize = .zero

    // MARK: - Vision Properties
    private var detectionOverlay: CALayer! = nil
    private var requests = [VNRequest]()
    private var lastSpokenObject: String?
    @AppStorage("voiceOutputEnabled") private var voiceOutputEnabled: Bool = true
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenTime: Date = Date()
    private let minimumTimeBetweenAnnouncements: TimeInterval = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        setupLayers()
        setupVision()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    private func stopSession() {
        session.stopRunning()
        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Camera Setup
    private func setupAVCapture() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Match model input size

        guard let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back).devices.first else {
                print("No back camera")
                return
        }

        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }

        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true

        do {
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device: \(error)")
        }

        session.commitConfiguration()

        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        rootLayer = view.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)

        // Start the session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    // MARK: - Vision Setup
    private func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
            print("⚠️ Warning: YOLOv3.mlmodelc not found in bundle")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                self?.visionRequestDidComplete(request: request, error: error)
            }
            request.imageCropAndScaleOption = .scaleFill
            requests = [request]
            print("✅ Successfully loaded YOLOv3 model")
        } catch {
            print("❌ Error loading Vision ML model: \(error)")
            requests = []
        }
    }

    // MARK: - Layer Setup
    private func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
        
        // Update layer frame when view layout changes
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateLayerFrame),
                                             name: UIDevice.orientationDidChangeNotification,
                                             object: nil)
    }
    
    @objc private func updateLayerFrame() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.frame = rootLayer.bounds
        CATransaction.commit()
    }

    // MARK: - Process Frames
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        var requestOptions: [VNImageOption: Any] = [:]

        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraData]
        }

        let orientation = exifOrientationFrom(deviceOrientation: UIDevice.current.orientation)

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print("Failed to perform request: \(error)")
        }
    }

    // MARK: - Vision Completion
    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            self.detectionOverlay.sublayers = nil // Clear previous boxes

            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                return
            }

            for observation in results {
                guard let topLabel = observation.labels.first else { continue }
                
                // Only show detections with confidence > 0.5
                if topLabel.confidence > 0.5 {
                    let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox,
                                                                  Int(self.bufferSize.width),
                                                                  Int(self.bufferSize.height))

                    let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
                    let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                                  identifier: topLabel.identifier,
                                                                  confidence: topLabel.confidence)

                    shapeLayer.addSublayer(textLayer)
                    self.detectionOverlay.addSublayer(shapeLayer)
                    
                    // Announce new object detection
                    let currentTime = Date()
                    if self.lastSpokenObject != topLabel.identifier && 
                       self.voiceOutputEnabled &&
                       currentTime.timeIntervalSince(self.lastSpokenTime) >= self.minimumTimeBetweenAnnouncements {
                        self.lastSpokenObject = topLabel.identifier
                        self.lastSpokenTime = currentTime
                        let confidence = Int(topLabel.confidence * 100)
                        self.speak("Detected \(topLabel.identifier) with \(confidence) percent confidence")
                    }
                }
            }
        }
    }

    private func speak(_ text: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            self.synthesizer.speak(utterance)
        }
    }

    // MARK: - Drawing Helpers
    private func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.borderColor = UIColor.systemOrange.cgColor
        shapeLayer.borderWidth = 3
        shapeLayer.cornerRadius = 8
        return shapeLayer
    }

    private func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = String(format: "\(identifier)\n%.0f%%", confidence * 100)
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: 40)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.minY - 20)
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7).cgColor
        textLayer.fontSize = 14
        textLayer.alignmentMode = .center
        textLayer.cornerRadius = 6
        textLayer.masksToBounds = true
        return textLayer
    }

    // MARK: - Orientation
    private func exifOrientationFrom(deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        switch deviceOrientation {
        case .portraitUpsideDown: return .left
        case .landscapeLeft: return .upMirrored
        case .landscapeRight: return .down
        case .portrait: return .up
        default: return .up
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        updateLayerFrame()
    }

    deinit {
        stopSession()
        NotificationCenter.default.removeObserver(self)
    }
}

