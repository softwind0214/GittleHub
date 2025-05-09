//
//  GittleHubApp.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/7.
//

import SwiftUI

@main
struct GittleHubApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FaceIDAuthenticator())
                .environmentObject(LoginVM())
                .environmentObject(A)
        }
    }
}
