//
//  SettingView.swift
//  MyProject
//
//  Created by Simon Yang on 2025-03-14.
//

import SwiftUI

struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let nativeName: String
}

struct DetectionHistory: Identifiable {
    let id = UUID()
    let objectName: String
    let confidence: Double
    let timestamp: Date
}

struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let isToggle: Bool
    @Binding var toggleValue: Bool
    let action: (() -> Void)?

    var body: some View {
        HStack {
            ZStack {
                Image(systemName: icon)
                    .foregroundColor(Color("Orange"))
                    .font(.system(size: 18, weight: .semibold))
            }
            Text(label)
                .foregroundColor(.primary)
                .font(.system(size: 17))
            Spacer()
            if isToggle {
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
                    .tint(Color("Orange"))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            action?()
        }
    }
}

struct SettingView: View {
    @AppStorage("voiceOutputEnabled") private var voiceOutputEnabled: Bool = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("selectedCategory") private var selectedCategory: String = "All"
    @AppStorage("confidenceThreshold") private var confidenceThreshold: Double = 0.5
    
    @State private var showLanguageSheet = false
    @State private var showProfileSheet = false
    @State private var showCategorySheet = false
    @State private var showHistorySheet = false
    @State private var showConfidenceSheet = false
    
    let languages: [Language] = [
        Language(code: "en", name: "English", nativeName: "English"),
        Language(code: "es", name: "Spanish", nativeName: "Español"),
        Language(code: "fr", name: "French", nativeName: "Français"),
        Language(code: "de", name: "German", nativeName: "Deutsch"),
        Language(code: "zh", name: "Chinese", nativeName: "中文"),
        Language(code: "ja", name: "Japanese", nativeName: "日本語")
    ]
    
    let categories = ["All", "Animals", "Plants", "Objects", "Food", "Vehicles"]
    
    let detectionHistory: [DetectionHistory] = [
        DetectionHistory(objectName: "Dog", confidence: 0.95, timestamp: Date().addingTimeInterval(-3600)),
        DetectionHistory(objectName: "Cat", confidence: 0.88, timestamp: Date().addingTimeInterval(-7200)),
        DetectionHistory(objectName: "Car", confidence: 0.92, timestamp: Date().addingTimeInterval(-10800)),
        DetectionHistory(objectName: "Tree", confidence: 0.85, timestamp: Date().addingTimeInterval(-14400)),
        DetectionHistory(objectName: "Chair", confidence: 0.78, timestamp: Date().addingTimeInterval(-18000))
    ]
    
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SettingRow(icon: "bell.fill", iconColor: .orange, label: "Notifications", isToggle: true, toggleValue: $notificationsEnabled, action: nil)
                    SettingRow(icon: "globe", iconColor: .orange, label: "Language Selection", isToggle: false, toggleValue: .constant(false), action: { showLanguageSheet = true })
                    SettingRow(icon: "moon.fill", iconColor: .orange, label: "Dark Mode", isToggle: true, toggleValue: $isDarkMode, action: nil)
                    SettingRow(icon: "person.crop.circle.fill", iconColor: .orange, label: "Profile", isToggle: false, toggleValue: .constant(false), action: { showProfileSheet = true })
                }
                Section {
                    SettingRow(icon: "speaker.wave.2.fill", iconColor: .orange, label: "Voice Output", isToggle: true, toggleValue: $voiceOutputEnabled, action: nil)
                    SettingRow(icon: "magnifyingglass.circle.fill", iconColor: .orange, label: "Category Preference", isToggle: false, toggleValue: .constant(false), action: { showCategorySheet = true })
                    SettingRow(icon: "clock.arrow.circlepath", iconColor: .orange, label: "Identification History", isToggle: false, toggleValue: .constant(false), action: { showHistorySheet = true })
                    SettingRow(icon: "percent", iconColor: .orange, label: "Confidence Threshold", isToggle: false, toggleValue: .constant(false), action: { showConfidenceSheet = true })
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
        }
        .preferredColorScheme(colorScheme)
        .sheet(isPresented: $showLanguageSheet) {
            NavigationView {
                List(languages) { language in
                    Button(action: {
                        selectedLanguage = language.code
                        showLanguageSheet = false
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(language.name)
                                    .font(.headline)
                                Text(language.nativeName)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if language.code == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color("Orange"))
                            }
                        }
                    }
                }
                .navigationTitle("Language")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showLanguageSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            NavigationView {
                List {
                    Section(header: Text("Account Information")) {
                        Text("Username: User123")
                        Text("Email: user@example.com")
                    }
                    Section(header: Text("Preferences")) {
                        Text("Last Login: Today")
                        Text("Account Type: Standard")
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showProfileSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            NavigationView {
                List(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        showCategorySheet = false
                    }) {
                        HStack {
                            Text(category)
                            Spacer()
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color("Orange"))
                            }
                        }
                    }
                }
                .navigationTitle("Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showCategorySheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            NavigationView {
                List(detectionHistory) { detection in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(detection.objectName)
                            .font(.headline)
                        HStack {
                            Text("Confidence: \(Int(detection.confidence * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(detection.timestamp, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showHistorySheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showConfidenceSheet) {
            NavigationView {
                VStack {
                    Text("Confidence Threshold: \(Int(confidenceThreshold * 100))%")
                        .font(.headline)
                        .padding()
                    
                    Slider(value: $confidenceThreshold, in: 0...1, step: 0.1)
                        .padding()
                        .tint(Color("Orange"))
                    
                    Text("Adjust the minimum confidence level required for object detection")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("Confidence")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showConfidenceSheet = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
