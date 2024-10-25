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

    var container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Food.self, Sleep.self, Journal.self)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(manager)
                .modelContainer(container)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationViewModel = NotificationViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set delegate untuk menampilkan notifikasi di foreground
        UNUserNotificationCenter.current().delegate = notificationViewModel
        return true
    }
}
