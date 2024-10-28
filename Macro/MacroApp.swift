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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("All set!")
            } else if let error {
                print(error.localizedDescription)
            }
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo) // the payload that is attached to the push notification
        // you can customize the notification presentation options. Below code will show notification banner as well as play a sound. If you want to add a badge too, add .badge in the array.
        completionHandler([.alert,.sound])
    }
}
