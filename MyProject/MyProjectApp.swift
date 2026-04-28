//
//  MyProjectApp.swift
//  MyProject
//
//  Created by Simon Yang on 2025-02-28.
//

import SwiftUI

@main
struct MyProjectApp: App {
    @State var loggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if !loggedIn {
                FirstPage()
            }else{
                ContentView()
            }
        }
    }
}
