//
//  ColorMatchApp.swift
//  ColorMatch
//
//  Created by Esther Ramos on  17/10/25.
//

import SwiftUI


@main
struct ColorMatchApp: App {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraManager)
        }
    }
}
