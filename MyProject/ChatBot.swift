//
//  ChatBot.swift
//  MyProject
//
//  Created by Simon Yang on 2025-05-14.
//

import SwiftUI

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    
    init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}

struct ChatBot: View {
    @State private var myMessage = ""
    @State private var isGeneratingResponse = false
    @State private var messages: [ChatMessage] = []
    @State private var showHelp = false
    @FocusState private var isFocused: Bool
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    init() {
        if let savedMessages = UserDefaults.standard.data(forKey: "chatMessages"),
           let decodedMessages = try? JSONDecoder().decode([ChatMessage].self, from: savedMessages) {
            _messages = State(initialValue: decodedMessages)
        } else {
            _messages = State(initialValue: [
                ChatMessage(text: "Hello! How can I help you today?", isUser: false)
            ])
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("ChatBot Powered By")
                        .bold()
                        .foregroundColor(.white)
                    Image("deepseek")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 30)
                }
                Spacer()
                
                Menu {
                    Button("Delete History") {
                        if messages.count > 1 {
                            messages = [messages[0]]
                            saveMessages()
                        }
                    }.disabled(isGeneratingResponse)
                    
                    Button("Help") {
                        showHelp = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .offset(y: -5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            
            VStack {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isUser {
                                    Spacer()
                                    Text(msg.text)
                                        .padding(12)
                                        .background(Color("Orange"))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                    Image("default")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image("whale")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    Text(msg.text)
                                        .padding(12)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemBackground))
                
                HStack {
                    TextField("Type a message...", text: $myMessage)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .focused($isFocused)
                    Button(action: {
                        if !myMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isGeneratingResponse = true
                            let userMessage = myMessage
                            messages.append(ChatMessage(text: userMessage, isUser: true))
                            myMessage = ""
                            isFocused = false
                            let placeholder = ChatMessage(text: "Generating response...", isUser: false)
                            messages.append(placeholder)
                            saveMessages()
                            
                            Task {
                                do {
                                    let reply = try await AIService().sendMessage(userMessage)
                                    await MainActor.run {
                                        if let index = messages.firstIndex(where: { $0.id == placeholder.id }) {
                                            messages[index] = ChatMessage(id: placeholder.id, text: reply, isUser: false)
                                            isGeneratingResponse = false
                                            saveMessages()
                                        }
                                    }
                                } catch {
                                    await MainActor.run {
                                        if let index = messages.firstIndex(where: { $0.id == placeholder.id }) {
                                            messages[index] = ChatMessage(id: placeholder.id, text: "Failed to get response: \(error.localizedDescription)", isUser: false)
                                            isGeneratingResponse = false
                                            saveMessages()
                                        }
                                    }
                                }
                            }
                        }
                    }) {
                        if isGeneratingResponse {
                            Image(systemName: "hourglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 22, weight: .bold))
                        } else {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color("Orange"))
                                .font(.system(size: 22, weight: .bold))
                        }
                    }
                    .disabled(isGeneratingResponse)
                    .padding(.leading, 4)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .preferredColorScheme(colorScheme)
        .sheet(isPresented: $showHelp) {
            NavigationView {
                Help()
                    .navigationTitle("Help")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showHelp = false
                            }
                        }
                    }
            }
        }
        .onTapGesture {
            isFocused = false
        }
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "chatMessages")
        }
    }
}

#Preview {
    ChatBot()
}
