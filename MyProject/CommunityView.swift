//
//  CommunityView.swift
//  MyProject
//
//  Created by Simon Yang on 2025-03-16.
//

import SwiftUI

struct CommunityPost: Identifiable {
    let id = UUID()
    let username: String
    let avatar: String
    let identified: String
    let year: String
    let description: String
    let likes: Int
    let comments: Int
    let image: UIImage
    let prob: String
}

struct CommunityView: View {
    @State private var showPost = false
    @State private var posts: [CommunityPost] = []
    
    func addPost(description: String, image: UIImage, identified: String, probability: String) {
        let newPost = CommunityPost(
            username: "Current User",
            avatar: "person.circle.fill",
            identified: identified,
            year: "2025",
            description: description,
            likes: 0,
            comments: 0,
            image: image,
            prob: probability
        )
        posts.insert(newPost, at: 0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Community")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    NavigationLink(destination: Post(onPost: addPost), isActive: $showPost) {
                        Button(action: {
                            withAnimation(.spring()) {
                                showPost = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("Orange"))
                        }
                    }
                }
                .padding()
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PostCard: View {
    let post: CommunityPost
    
    private var shareText: String {
        """
        Check out this \(post.identified) I found!
        Identified with \(post.prob) confidence.
        \(post.description)
        """
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: post.avatar)
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(post.username)
                        .font(.headline)
                    Text(post.year)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                HStack {
                    Text(post.identified)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("Orange").opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(post.prob)
                        .font(.caption)
                        .foregroundColor(Color("Orange"))
                }
            }
            
            // Post image
            Image(uiImage: post.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
            
            // Post description
            Text(post.description)
                .font(.body)
            
            // Interaction buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Like action
                }) {
                    HStack {
                        Image(systemName: "heart")
                        Text("\(post.likes)")
                    }
                    .foregroundColor(.gray)
                }
                
                Button(action: {
                    // Comment action
                }) {
                    HStack {
                        Image(systemName: "message")
                        Text("\(post.comments)")
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                ShareLink(
                    item: shareText,
                    subject: Text("Check out this \(post.identified)!"),
                    message: Text("Shared from MyProject")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CommunityView()
}
