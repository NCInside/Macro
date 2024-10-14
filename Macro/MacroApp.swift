//
//  MacroApp.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 03/10/24.
//

import SwiftUI
import SwiftData

@main
struct MacroApp: App {
    @StateObject var manager = HealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
