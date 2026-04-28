# FindIt - Intelligent Object Recognition

FindIt is an iOS app that combines real-time object recognition, voice interaction, and conversational AI in one SwiftUI experience. It uses CoreML and AVFoundation to detect objects from the camera feed, and integrates an AI chatbot through OpenRouter (DeepSeek API) for contextual Q&A.

## Features

- Real-time object detection using camera input
- On-device vision pipeline with CoreML + Vision
- Voice output for accessibility and hands-free feedback
- AI chatbot integration via OpenRouter for intelligent conversation
- SwiftUI-based interface with multiple app sections (camera, photo, community, settings, chatbot)

## Tech Stack

- Swift
- SwiftUI
- CoreML
- Vision
- AVFoundation
- OpenRouter API (DeepSeek model)

## Project Structure

- `MyProject/` - Main iOS app source code
- `MyProjectTests/` - Unit test target
- `MyProjectUITests/` - UI test target
- `MyProject.xcodeproj/` - Xcode project

## Requirements

- macOS with Xcode installed
- iOS 16.0+ (recommended)
- Apple Developer account (for running on physical device, optional)
- OpenRouter API key (for chatbot feature)

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/YSMsimon/FindIt.git
   cd MyProject
   ```

2. Open the project in Xcode:

   ```bash
   open MyProject.xcodeproj
   ```

3. Configure chatbot credentials in `MyProject/AIService.swift`:
   - Set `apiKey` to your OpenRouter API key
   - Set `model` to your desired model id

4. Download `YOLOv3.mlmodel` and place it at:
   - `MyProject/YOLOv3.mlmodel`
   - Suggested source: Apple's Core ML model resources at [developer.apple.com/machine-learning/models](https://ml-assets.apple.com/coreml/models/Image/ObjectDetection/YOLOv3/YOLOv3.mlmodel)

5. Build and run from Xcode on Simulator or a physical iPhone.

## Configuration Notes

- Camera permission is required for live object detection.
- Microphone/speech permissions may be required depending on your voice features and app flow.
- Keep API keys out of commits. For production, move secrets to a secure config pattern instead of hardcoding.
- `YOLOv3.mlmodel` is intentionally gitignored because GitHub rejects files over 100 MB.

## Accessibility and UX Focus

FindIt is designed to be responsive and inclusive by combining:

- Real-time visual understanding
- Voice output for easier interaction
- Conversational assistance for guidance and discovery

## Future Improvements

- Secure API key management (xcconfig / environment-based)
- Expanded model options and prompt tuning
- Detection history and analytics
- Performance tuning for lower-latency inference

## Author

Designed and developed by Simon Yang.

