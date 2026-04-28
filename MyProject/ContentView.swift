import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
                .tag(0)
            PhotoView()
                .tabItem {
                    Label("Photos", systemImage: "photo.fill")
                }
                .tag(1)
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "globe")
                }
                .tag(2)
            SettingView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
            ChatBot()
                .tabItem {
                    Label("ChatBot", systemImage: "message")
                }
                .tag(4)
        }
        .tint(Color("Orange")) 
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(named: "Grey")
            UITabBar.appearance().backgroundColor = .black
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
}

extension View {
    func setBackgroundColor() -> some View {
        self
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
