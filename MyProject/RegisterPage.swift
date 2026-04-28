//
//  RegisterPage.swift
//  MyProject
//
//  Created by Simon Yang on 2025-05-14.
//

import SwiftUI

struct RegisterPage: View {
    @State private var isRotating = 0.0
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isAnimating = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
        
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
            HStack(spacing: 1) {
                Text("Find")
                    .font(.custom("HelveticaNeue-Bold", size: 50))
                    .foregroundStyle(Color.white)
                Text("It")
                    .foregroundStyle(Color("Orange"))
                    .font(.custom("HelveticaNeue-Bold", size: 50))
            }
            
            Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 80))
                .foregroundStyle(Color.white)
                .rotationEffect(.degrees(isRotating))
                .onAppear {
                    withAnimation(
                        .linear(duration: 5.0)
                        .repeatForever(autoreverses: false)
                    ) {
                        isRotating = 360.0
                    }
                }
                }
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
            
                // Register Form
                VStack(spacing: 25) {
                    Text("Create Your Account")
                        .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundStyle(Color.white)
                    
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundStyle(Color.white)
                            
                            TextField("", text: $username)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundStyle(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("Orange"), lineWidth: 1)
                                )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundStyle(Color.white)
                            
                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundStyle(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("Orange"), lineWidth: 1)
                                )
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                                .foregroundStyle(Color.white)
                            
                            SecureField("", text: $confirmPassword)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundStyle(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("Orange"), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Register Button
                    Button(action: {
                        // Register action will be implemented later
                    }) {
                        Text("Register")
                            .font(.custom("HelveticaNeue-Bold", size: 20))
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color("Orange"))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .offset(y: isAnimating ? 0 : 50)
                .opacity(isAnimating ? 1 : 0)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    RegisterPage()
}
