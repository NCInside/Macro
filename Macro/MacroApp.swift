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
            // Configure the ModelContainer with the necessary models
            container = try ModelContainer(for: Food.self, Sleep.self, Journal.self, Reminder.self, JournalImage.self, FoodBreakout.self, PeakConsumption.self)
        } catch {
            fatalError("Failed to configure SwiftData container: \(error.localizedDescription)")
        }

        // Initialize PeakConsumption in the main context
        initializePeakConsumptionAsync()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(manager)
                .modelContainer(container)
        }
    }

    /// Asynchronously initializes PeakConsumption in the main context
    private func initializePeakConsumptionAsync() {
        Task {
            let context = container.mainContext
            await initializePeakConsumption(context: context)
        }
    }

    /// Function to initialize PeakConsumption in the database
    @MainActor
    private func initializePeakConsumption(context: ModelContext) async {
        let fetchRequest = FetchDescriptor<PeakConsumption>()
        do {
            if try context.fetch(fetchRequest).isEmpty {
                let initialPeak = PeakConsumption()
                context.insert(initialPeak)
                try context.save()
                print("PeakConsumption initialized successfully.")
            }
        } catch {
            print("Failed to initialize PeakConsumption: \(error.localizedDescription)")
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
