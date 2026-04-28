//
//  Help.swift
//  MyProject
//
//  Created by Simon Yang on 2025-06-08.
//

import SwiftUI

struct Help: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
               
                // About Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("About")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This app combines advanced AI technology with real-time object detection to help you identify and learn about the world around you.")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Features Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Features")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    FeatureRow(icon: "camera.fill", title: "Live Camera Detection", description: "Real-time object detection using your device's camera")
                    FeatureRow(icon: "photo.fill", title: "Photo Analysis", description: "Upload photos for detailed object identification")
                    FeatureRow(icon: "speaker.wave.2.fill", title: "Voice Feedback", description: "Audio announcements of detected objects")
                    FeatureRow(icon: "message.fill", title: "AI Chat Assistant", description: "Ask questions about detected objects")
                }
                .padding(.horizontal)
                
                // How to Use Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("How to Use")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    InstructionRow(number: "1", text: "Point your camera at objects or upload photos")
                    InstructionRow(number: "2", text: "Wait for the AI to identify objects")
                    InstructionRow(number: "3", text: "Use the chat to ask questions about detected objects")
                    InstructionRow(number: "4", text: "Enable voice feedback in settings for audio announcements")
                }
                .padding(.horizontal)
                
                // Tips Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tips")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TipRow(text: "Ensure good lighting for better detection")
                    TipRow(text: "Hold the camera steady for accurate results")
                    TipRow(text: "Use the chat to learn more about detected objects")
                    TipRow(text: "Adjust confidence threshold in settings if needed")
                }
                .padding(.horizontal)
                
                // Version Info
                VStack(spacing: 5) {
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("© 2025 FindIt")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("Orange"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color("Orange"))
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundColor(Color("Orange"))
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    Help()
}
