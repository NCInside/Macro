import SwiftData
import UserNotifications
import Foundation
import SwiftUI

class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var errorMessage: String? = nil

    func loadReminders(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Reminder>()
        do {
            reminders = try context.fetch(fetchDescriptor)
            print("Successfully loaded reminders.")
        } catch {
            print("Failed to fetch reminders: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load reminders."
            }
        }
    }

    func addReminder(context: ModelContext, reminder: Reminder, notificationOptions: [Bool]) {
        context.insert(reminder)
        do {
            try context.save()
            reminders.append(reminder)
            storeNotificationOptions(for: reminder, options: notificationOptions)
            scheduleNotifications(for: reminder, notificationOptions: notificationOptions)
        } catch {
            self.errorMessage = "Gagal menambahkan pengingat: \(error.localizedDescription)"
        }
    }

    func updateReminder(context: ModelContext, reminder: Reminder, notificationOptions: [Bool]) {
        removeNotificationRequests(for: reminder)  // Remove existing notifications

        do {
            try context.save()  // Save updated reminder in context
            storeNotificationOptions(for: reminder, options: notificationOptions)  // Update notification options
            scheduleNotifications(for: reminder, notificationOptions: notificationOptions)  // Schedule new notifications
            
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = reminder  // Update the reminder in the list
            }
        } catch {
            self.errorMessage = "Failed to update reminder: \(error.localizedDescription)"
        }
    }

    func removeReminder(_ reminder: Reminder, context: ModelContext) {
        print("Attempting to remove reminder: \(reminder.clinicName)")
        context.delete(reminder)
        
        do {
            try context.save()
            reminders.removeAll { $0.id == reminder.id }
            removeNotificationRequests(for: reminder) // Remove all notifications for this reminder
            print("Successfully removed reminder: \(reminder.clinicName)")
        } catch {
            print("Failed to remove reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Gagal menghapus pengingat: \(error.localizedDescription)"
            }
        }
    }

    func scheduleNotifications(for reminder: Reminder, notificationOptions: [Bool]) {
        let identifiers = [
            "\(reminder.id.uuidString)_exact",
            "\(reminder.id.uuidString)_3days",
            "\(reminder.id.uuidString)_1day",
            "\(reminder.id.uuidString)_3hours",
            "\(reminder.id.uuidString)_1hour",
            "\(reminder.id.uuidString)_15min"
        ]
        
        let intervals: [TimeInterval] = [
            0,                  // Exact time of the reminder
            -3 * 24 * 60 * 60,  // 3 days
            -24 * 60 * 60,      // 1 day
            -3 * 60 * 60,       // 3 hours
            -1 * 60 * 60,       // 1 hour
            -15 * 60            // 15 minutes
        ]
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized.")
                return
            }

            for (index, enabled) in notificationOptions.enumerated() {
                let identifier = identifiers[index]
                if enabled {
                    let triggerDate = reminder.visitDate.addingTimeInterval(intervals[index])
                    self.createNotification(for: reminder, identifier: identifier, triggerDate: triggerDate)
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                }
            }
        }
    }


    private func removeNotificationRequests(for reminder: Reminder) {
        // All identifiers for notifications associated with this reminder
        let identifiers = [
            "\(reminder.id.uuidString)_exact",
            "\(reminder.id.uuidString)_3days",
            "\(reminder.id.uuidString)_1day",
            "\(reminder.id.uuidString)_3hours",
            "\(reminder.id.uuidString)_1hour",
            "\(reminder.id.uuidString)_15min"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Removed all notifications for reminder: \(reminder.clinicName)")
    }

    func storeNotificationOptions(for reminder: Reminder, options: [Bool]) {
        let userDefaultsKey = "notificationOptions_\(reminder.id.uuidString)"
        UserDefaults.standard.set(options, forKey: userDefaultsKey)
    }
    func getNotificationOptions(for reminder: Reminder) -> [Bool] {
        let userDefaultsKey = "notificationOptions_\(reminder.id.uuidString)"
        if let savedOptions = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Bool] {
            return savedOptions // Return saved options if they exist
        }
        // Return a default array if no saved options exist
        return [false, false, false, false, false, false]
    }

    private func createNotification(for reminder: Reminder, identifier: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Zora - Pengingat Kunjungan"
        content.body = "Kunjungan ke \(reminder.clinicName)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled with identifier: \(identifier)")
            }
        }
    }
}
