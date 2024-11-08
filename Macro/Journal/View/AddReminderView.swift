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
    @State private var showReminderOptions = false // Controls dropdown visibility
    let isEditMode: Bool
    var reminderToEdit: Reminder?
    var onSave: (ModelContext, Reminder) -> Void
    var onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(reminder: Reminder? = nil,
         notifications: Binding<[Bool]>,
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
        
        if notifications.wrappedValue.count >= 6 {
            self._notifications.wrappedValue[0] = true
        }

    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("PENGINGAT KUNJUNGAN KONTROL")
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Klinik")
                            .font(.body)
                            .frame(width: 80, alignment: .leading)
                        TextField("Nama Klinik", text: $clinicName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    Divider()
                    HStack {
                        Text("Kunjungan")
                            .font(.body)
                            .frame(width: 80, alignment: .leading)
                        DatePicker("", selection: $visitDate, displayedComponents: .date)
                            .labelsHidden()
                            .foregroundColor(.gray)
                    }
                    Divider()
                    HStack {
                        Text("Waktu")
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
                
                // Dropdown for time reminders
                Button(action: {
                    withAnimation {
                        showReminderOptions.toggle()
                    }
                }) {
                    HStack {
                        Text("Pilih pengingat waktu:")
                            .font(.caption)
                        Spacer()
                        Image(systemName: showReminderOptions ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                
                if showReminderOptions {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Pada Waktunya", isOn: $notifications[0])
                        Toggle("3 Hari Sebelumnya", isOn: $notifications[1])
                        Toggle("1 Hari Sebelumnya", isOn: $notifications[2])
                        Toggle("3 Jam Sebelumnya", isOn: $notifications[3])
                        Toggle("1 Jam Sebelumnya", isOn: $notifications[4])
                        Toggle("15 Menit Sebelumnya", isOn: $notifications[5])
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                if isEditMode {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Hapus Kunjungan")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity) // Fill the entire width
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
                    .padding(.horizontal) // Add horizontal padding to give some space on the sides
                }

            }
            .navigationBarItems(
                leading: Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Pengingat")
                    }
                },
                trailing: Button("Simpan") {
                    saveReminder()
                }.disabled(clinicName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
    
    private func saveReminder() {
        if let reminderToEdit = reminderToEdit {
            // Update existing reminder with new values
            reminderToEdit.clinicName = clinicName.trimmingCharacters(in: .whitespaces)
            reminderToEdit.visitDate = combineDateAndTime()
            
            // Call onSave to update the reminder in the model context
            onSave(modelContext, reminderToEdit)
        } else {
            // Create a new reminder
            let newReminder = Reminder(clinicName: clinicName.trimmingCharacters(in: .whitespaces), visitDate: combineDateAndTime())
            onSave(modelContext, newReminder)
        }
        
        // Dismiss the view after saving
        dismiss()
    }

    
    private func combineDateAndTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: visitDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: visitTime)
        return calendar.date(from: DateComponents(year: components.year, month: components.month, day: components.day, hour: timeComponents.hour, minute: timeComponents.minute))!
    }
}
