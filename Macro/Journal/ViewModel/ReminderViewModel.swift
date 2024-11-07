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

    func addReminder(context: ModelContext, reminder: Reminder) {
        print("Attempting to add reminder: \(reminder.clinicName)")
        context.insert(reminder)
        do {
            try context.save()
            reminders.append(reminder)
            print("Successfully added reminder: \(reminder.clinicName)")
            scheduleNotifications(for: reminder)
        } catch {
            print("Failed to add reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Gagal menambahkan pengingat: \(error.localizedDescription)"
            }
        }
    }

    func updateReminder(context: ModelContext, reminder: Reminder) {
        print("Attempting to update reminder: \(reminder.clinicName)")
        
        // Remove previous notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "\(reminder.id.uuidString)_3",
            "\(reminder.id.uuidString)_1",
            "\(reminder.id.uuidString)_0"
        ])
        
        do {
            try context.save()
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = reminder
                print("Successfully updated reminder: \(reminder.clinicName)")
                scheduleNotifications(for: reminder) // Schedule new notifications with updated times
            }
        } catch {
            print("Failed to update reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Gagal memperbarui pengingat: \(error.localizedDescription)"
            }
        }
    }


    func removeReminder(_ reminder: Reminder, context: ModelContext) {
        print("Attempting to remove reminder: \(reminder.clinicName)")
        context.delete(reminder)
        do {
            try context.save()
            reminders.removeAll { $0.id == reminder.id }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
                "\(reminder.id.uuidString)_3",
                "\(reminder.id.uuidString)_1",
                "\(reminder.id.uuidString)_0"
            ])
            print("Successfully removed reminder: \(reminder.clinicName)")
        } catch {
            print("Failed to remove reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Gagal menghapus pengingat: \(error.localizedDescription)"
            }
        }
    }
    
    private func scheduleNotifications(for reminder: Reminder) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized.")
                return
            }
            self.createNotification(for: reminder, daysBefore: 3, hour: 9)
            self.createNotification(for: reminder, daysBefore: 1, hour: 9)
            self.createNotification(for: reminder, daysBefore: 0, hour: 7)
        }
    }

    private func createNotification(for reminder: Reminder, daysBefore: Int, hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Zora - Pengingat Kunjungan"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: reminder.visitDate)
        content.body = "Kunjungan ke \(reminder.clinicName) pada \(formattedDate)"
        content.sound = .default

        var triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: reminder.visitDate) ?? Date()
        triggerDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: triggerDate) ?? triggerDate
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate), repeats: false)
        
        let identifier = "\(reminder.id.uuidString)_\(daysBefore)"
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
