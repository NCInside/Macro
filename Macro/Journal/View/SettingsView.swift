import SwiftUI
import UserNotifications

struct SettingsView: View {
    // User information
    @State private var inputName: String = UserDefaults.standard.string(forKey: "name") ?? "Unknown name"
    @State private var inputDayOfBirth: Date = {
        let birthDateString = UserDefaults.standard.string(forKey: "dateOfBirth") ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthDateString) ?? Date()
    }()
    
    // Notification toggles
    @State private var nutritionReminder = UserDefaults.standard.bool(forKey: "nutritionReminder")
    @State private var reminderTime: Date = {
        let storedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date
        return storedTime ?? Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
    }()
    
    @StateObject var journalViewModel: JournalViewModel
    var journals: [Journal]
    
    @State private var showDatePicker = false
    @Environment(\.dismiss) private var dismiss
    @State private var  isDatePickerEnabled = false
    @State private var isDatePickerVisible = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Navigation Bar
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Jurnal")
                }.onTapGesture {
                    saveSettings()
                    dismiss()
                }
                .foregroundColor(.accentColor)
                
                Spacer()
                
                Text("Profil")
                    .foregroundColor(Color.systemBlack)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    saveSettings()
                    dismiss()
                }) {
                    Text("Selesai")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .padding(.leading, 6)
                }
            }
            .padding(.bottom, 12)
            
            // Data Diri Section
            Text("DATA DIRI")
                .font(.caption)
                .padding(.horizontal, 4)
                .padding(.top, 10)
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                HStack{
                    Text("Nama")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(width: 140, alignment: .leading)
                    
                    TextField("Nama", text: $inputName)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                                    .padding(.vertical, 10)
                                    .padding(.trailing, 18)
                                    .onChange(of: inputName) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "name")
                                    }
                    
                }
                .background(Color(UIColor.systemBackground))
                
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Tanggal Lahir")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(width: 140, alignment: .leading)
                    
                    HStack {
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            Text(dateFormatted(inputDayOfBirth))
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $showDatePicker) {
                            VStack {
                                DatePicker("Pilih Tanggal Lahir", selection: $inputDayOfBirth, in: ...Date(), displayedComponents: .date)
                                    .datePickerStyle(.wheel)
                                    .environment(\.locale, Locale(identifier: "id_ID"))
                                    .labelsHidden()
                                    .padding()
                                
                                Button("Selesai") {
                                    showDatePicker = false
                                    saveBirthDate(inputDayOfBirth)
                                }
                                .padding()
                            }
                            .presentationDetents([.fraction(0.4)])
                        }
                        
                        Spacer()
                    }
                }
                .background(Color(UIColor.systemBackground))
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            // Notifications Section
            Text("NOTIFIKASI")
                .font(.caption)
                .padding(.horizontal, 4)
                .padding(.top, 10)
                .padding(.leading, 10)
            
            VStack(spacing: 0) {
                // Nutrition Reminder Toggle with Time Picker
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Pengingat Pengisian Jurnal")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $nutritionReminder)
                                .labelsHidden()
                                .onChange(of: nutritionReminder) { isEnabled in
                                    toggleNutritionReminderNotification(isEnabled: isEnabled)
                                }
                                .frame(maxHeight: 20)
                        }
                        
                        if nutritionReminder {
                            Text(reminderTime, style: .time)
                                .padding(.top, -6)
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    withAnimation {
                                        isDatePickerVisible.toggle()
                                    }
                                }
                                
                            if isDatePickerVisible {
                                                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                                    .datePickerStyle(.wheel)
                                                    .labelsHidden()
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.top, 4)
                                                    .onChange(of: reminderTime) { newTime in
                                                        UserDefaults.standard.set(newTime, forKey: "reminderTime")
                                                        rescheduleNutritionReminderNotification()
                                                        
                                                    }
                                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            
            Spacer()
        }
        .padding()
        .background(Color.background.ignoresSafeArea())
    }
    
    // Notification Toggle and Scheduling Functions
    private func toggleNutritionReminderNotification(isEnabled: Bool) {
        if isEnabled {
            rescheduleNutritionReminderNotification()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["nutritionReminder"])
        }
    }
    
    private func rescheduleNutritionReminderNotification() {
        // Remove any existing reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["nutritionReminder"])
        
        // Check if there’s data entered for today; schedule only if none exists
        if journalViewModel.hasEntriesFromToday(entries: journals) == nil {
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            var dailyTrigger = DateComponents()
            dailyTrigger.hour = components.hour
            dailyTrigger.minute = components.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dailyTrigger, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = "Zora - Nutrition Reminder"
            content.body = "No food or drink entries logged today."
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: "nutritionReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Daily nutrition reminder notification successfully scheduled for hour: \(components.hour ?? 0) minute: \(components.minute ?? 0)")
                }
            }
        } else {
            print("Entries found for today; no notification scheduled.")
        }
    }


    // Helper functions
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private func saveBirthDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = formatter.string(from: date)
        UserDefaults.standard.set(birthDateString, forKey: "dateOfBirth")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(inputName, forKey: "name")
        UserDefaults.standard.set(nutritionReminder, forKey: "nutritionReminder")
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
        saveBirthDate(inputDayOfBirth)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
       
        let journalViewModel = JournalViewModel()
        let sampleJournals: [Journal] = []

        SettingsView(journalViewModel: journalViewModel, journals: sampleJournals)
            .environment(\.locale, .init(identifier: "id"))
    }
}
