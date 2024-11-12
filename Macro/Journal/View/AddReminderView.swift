import SwiftUI
import SwiftData

struct AddReminderView: View {
    @State var clinicName: String
    @State var visitDate: Date
    @State var visitTime: Date = Date()
    @Binding var notifications: [Bool]
    @State private var showDeleteConfirmation = false
    @State private var showErrorDialog = false
    @State private var errorMessage = ""
    let isEditMode: Bool
    var reminderToEdit: Reminder?
    var onSave: (ModelContext, Reminder) -> Void
    var onDelete: (() -> Void)?
    
    // Reminder dropdown states
    @State private var selectedFirstReminder = "Tidak ada"
    @State private var selectedSecondReminder = "Tidak ada"
    @State private var selectedThirdReminder = "Tidak ada"
    let reminderOptions = ["Tidak ada", "15 Menit Sebelum", "1 Jam Sebelum", "3 Jam Sebelum", "1 Hari Sebelum", "3 Hari Sebelum"]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(reminder: Reminder? = nil,
         notifications: Binding<[Bool]> = .constant([true, false, false, false, false, false]),  // Set "Pada Waktunya" notification to true by default
         onSave: @escaping (ModelContext, Reminder) -> Void,
         onDelete: (() -> Void)? = nil) {
        if let reminder = reminder {
            _clinicName = State(initialValue: reminder.clinicName)
            _visitDate = State(initialValue: reminder.visitDate)
            _visitTime = State(initialValue: reminder.visitDate)
            self.isEditMode = true
            self.reminderToEdit = reminder
        } else {
            _clinicName = State(initialValue: "")
            _visitDate = State(initialValue: Date())
            self.isEditMode = false
            self.reminderToEdit = nil
        }
        
        self._notifications = notifications
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("PENGINGAT KUNJUNGAN KONTROL")
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.leading, 12)
                    
                    TextField("Nama Kunjungan", text: $clinicName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                        .padding(.leading)
                        .background(Color(UIColor.systemWhite))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Tanggal")
                                .font(.body)
                                .frame(width: 80, alignment: .leading)
                            DatePicker("", selection: $visitDate, displayedComponents: .date)
                                .labelsHidden()
                                .foregroundColor(.gray)
                        }
                        Divider()
                        HStack {
                            Text("Jam")
                                .font(.body)
                                .frame(width: 80, alignment: .leading)
                            DatePicker("", selection: $visitTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemWhite))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Text("PENGINGAT")
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    VStack {
                        ReminderPickerView(label: "Peringatan", selection: $selectedFirstReminder, options: availableOptions(exclude: [selectedSecondReminder, selectedThirdReminder]))
                        Divider()
                        ReminderPickerView(label: "Peringatan Kedua", selection: $selectedSecondReminder, options: availableOptions(exclude: [selectedFirstReminder, selectedThirdReminder]))
                        Divider()
                        ReminderPickerView(label: "Peringatan Ketiga", selection: $selectedThirdReminder, options: availableOptions(exclude: [selectedFirstReminder, selectedSecondReminder]))
                    }
                    .padding()
                    .background(Color(UIColor.systemWhite))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if isEditMode {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Hapus Kunjungan")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 1)
                        }
                        .confirmationDialog("Hapus Kunjungan", isPresented: $showDeleteConfirmation) {
                            Button("Hapus", role: .destructive) {
                                onDelete?()
                                dismiss()
                            }
                            Button("Batal", role: .cancel) { }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Tambah Kunjungan")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Pengingat")
                        }
                    },
                    trailing: Button("Simpan") {
                        updateNotifications()
                        saveReminder()
                    }.disabled(clinicName.trimmingCharacters(in: .whitespaces).isEmpty)
                )
                .onAppear {
                    if !isEditMode {
                        selectedFirstReminder = "15 Menit Sebelum"
                        selectedSecondReminder = "Tidak ada"
                        selectedThirdReminder = "Tidak ada"
                        notifications[0] = true // "Pada Waktunya" notification is always true
                    } else {
                        loadExistingReminder()
                    }
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
    
    private func availableOptions(exclude: [String]) -> [String] {
        return reminderOptions.filter { !exclude.contains($0) } + ["Tidak ada"]
    }
    
    private func saveReminder() {
        if let reminderToEdit = reminderToEdit {
            reminderToEdit.clinicName = clinicName.trimmingCharacters(in: .whitespaces)
            reminderToEdit.visitDate = combineDateAndTime()
            onSave(modelContext, reminderToEdit)
        } else {
            let newReminder = Reminder(clinicName: clinicName.trimmingCharacters(in: .whitespaces), visitDate: combineDateAndTime())
            onSave(modelContext, newReminder)
        }
        dismiss()
    }
    
    private func combineDateAndTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: visitDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: visitTime)
        return calendar.date(from: DateComponents(year: components.year, month: components.month, day: components.day, hour: timeComponents.hour, minute: timeComponents.minute))!
    }
    
    private func loadExistingReminder() {
        // Define each reminder option and its time interval in seconds
        let reminderIntervals: [String: TimeInterval] = [
            "15 Menit Sebelum": 15 * 60,
            "1 Jam Sebelum": 1 * 60 * 60,
            "3 Jam Sebelum": 3 * 60 * 60,
            "1 Hari Sebelum": 24 * 60 * 60,
            "3 Hari Sebelum": 3 * 24 * 60 * 60,
            "Tidak ada": Double.greatestFiniteMagnitude // Assign a large value for "Tidak ada"
        ]
        
        // Collect selected reminders based on notifications array
        var loadedReminders: [String] = []
        if notifications[5] { loadedReminders.append("15 Menit Sebelum") }
        if notifications[4] { loadedReminders.append("1 Jam Sebelum") }
        if notifications[3] { loadedReminders.append("3 Jam Sebelum") }
        if notifications[2] { loadedReminders.append("1 Hari Sebelum") }
        if notifications[1] { loadedReminders.append("3 Hari Sebelum") }
        
        // Fill remaining spots with "Tidak ada" if needed
        while loadedReminders.count < 3 {
            loadedReminders.append("Tidak ada")
        }
        
        // Sort reminders based on their time interval (closest first)
        loadedReminders.sort { reminderIntervals[$0, default: Double.greatestFiniteMagnitude] < reminderIntervals[$1, default: Double.greatestFiniteMagnitude] }
        
        // Assign sorted reminders to respective selectors
        selectedFirstReminder = loadedReminders[0]
        selectedSecondReminder = loadedReminders[1]
        selectedThirdReminder = loadedReminders[2]
    }


    
    private func updateNotifications() {
        // "Pada Waktunya" notification (exact time) is always enabled
        notifications[0] = true
        
        // Clear all other notifications before updating
        for i in 1..<notifications.count {
            notifications[i] = false
        }
        
        // Update notifications based on selected reminders
        if let index1 = getNotificationIndex(for: selectedFirstReminder) {
            notifications[index1] = true
        }
        if let index2 = getNotificationIndex(for: selectedSecondReminder) {
            notifications[index2] = true
        }
        if let index3 = getNotificationIndex(for: selectedThirdReminder) {
            notifications[index3] = true
        }
        
        print("Notifications updated:", notifications)
    }
    
    private func getNotificationIndex(for reminder: String) -> Int? {
        switch reminder {
        case "15 Menit Sebelum":
            return 5
        case "1 Jam Sebelum":
            return 4
        case "3 Jam Sebelum":
            return 3
        case "1 Hari Sebelum":
            return 2
        case "3 Hari Sebelum":
            return 1
        default:
            return nil
        }
    }
}


struct ReminderPickerView: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Picker(selection: $selection, label: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
    }
}

struct AddReminderView_Previews: PreviewProvider {
    @State static var notifications = [true, false, false, false, false, false] // Default "Pada Waktunya" to true
    
    static var previews: some View {
        AddReminderView(
            notifications: $notifications,
            onSave: { context, reminder in
                print("Saved Reminder: \(reminder.clinicName)")
            },
            onDelete: {
                print("Reminder Deleted")
            }
        )
    }
}
