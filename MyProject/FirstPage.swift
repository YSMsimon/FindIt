import SwiftUI

struct FirstPage: View {
    @State private var isRotating = 0.0
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
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
                    .font(.system(size: 100))
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
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 20) {
                    NavigationLink(destination: LoginPage(), isActive: $showLogin) {
                            Button(action: {
                                withAnimation(.spring()) {
                            showLogin = true
                        }
                            }) {
                                Text("Login")
                                    .font(.custom("HelveticaNeue-Bold", size: 20))
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color("Orange"))
                                    .cornerRadius(15)
                            }
                        }
                        
                        NavigationLink(destination: RegisterPage(), isActive: $showRegister) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showRegister = true
                                }
                            }) {
                                Text("Register")
                                    .font(.custom("HelveticaNeue-Bold", size: 20))
                        .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                        .background(Color("Orange"))
                                    .cornerRadius(15)
                    }
                        }
                    }
                    .padding(.horizontal, 40)
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                    
                    Spacer()
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    FirstPage()
}
