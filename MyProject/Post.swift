//
//  Post.swift
//  MyProject
//
//  Created by Simon Yang on 2025-06-08.
//

import SwiftUI
import PhotosUI

struct Post: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var identifiedSpecies = ""
    @State private var probability = ""
    
    let onPost: (String, UIImage, String, String) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Selection
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                        } else {
                            Button(action: {
                                isImagePickerPresented = true
                            }) {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                    Text("Add Photo")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.headline)
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Identification
                    VStack(alignment: .leading) {
                        Text("Identified Species")
                            .font(.headline)
                        TextField("Enter species name", text: $identifiedSpecies)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Probability
                    VStack(alignment: .leading) {
                        Text("Confidence")
                            .font(.headline)
                        TextField("Enter probability (e.g., 95%)", text: $probability)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        if let image = selectedImage {
                            onPost(description, image, identifiedSpecies, probability)
                            dismiss()
                        }
                    }) {
                        Text("Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedImage != nil ? Color("Orange") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedImage == nil)
                }
                .padding()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    Post(onPost: { _, _, _, _ in })
}
