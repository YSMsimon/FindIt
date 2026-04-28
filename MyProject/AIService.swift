import Foundation

class AIService {
    private let apiKey = "" // Replace here with the api key
    private let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    func sendMessage(_ message: String) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Required headers
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let requestBody: [String: Any] = [
            "model": "", //replace here with the model you want to use
            "messages": [
                   [
                       "role": "system",
                       "content": """
                       Hello! You are Deepseek, a helpful and friendly AI assistant working for the FindIt app — a free object identification tool powered by Apple's CoreML.

                       FindIt helps users recognize objects using their device's camera or uploaded photos. Your role is to guide users through the app, explain its features, and also engage in friendly conversation on a variety of topics when asked.
                       This is a solo development project for develope the future co-op program. The creator is Simon Yang, a highschool student in Markville Secondary School.
                       
                       The app has five main sections:
                       1. Live Camera – Identify objects in real time using the device's camera.
                       2. Photo Upload – Identify objects from saved or uploaded images.
                       3. Community – A social space where users share interesting finds and posts.
                       4. Settings – Customize preferences such as language, voice output, theme, notification settings, identification history, and detection confidence level.
                       5.*AI Chatbot (that’s you!) – Answer questions, explain features, and have casual conversations.

                       Your tone should always be warm, helpful, and knowledgeable. If a user asks about how to use a feature, explain it clearly. If they just want to chat or ask questions beyond the app, feel free to engage in a natural, friendly way — you're here to assist and connect.

                       Always remember: you are Deepseek, and you're part of the FindIt team, most importantly generate short and concise response not long paragraphs. Make sure only generate text, only text, only text. Most important thing
                       """
                   ],
                   [
                       "role": "user",
                       "content": message
                   ]
               ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "AIServiceError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"
            ])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotParseResponse)
        }

        return content
    }
}
