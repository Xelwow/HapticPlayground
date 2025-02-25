//
//  HapticPlaygroundApp.swift
//  HapticPlayground
//
//  Created by Nikita Komarov on 24.02.2025.
//

import SwiftUI

@main
struct HapticPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            HapticView(haptic: exampleHaptic)
        }
    }
}
