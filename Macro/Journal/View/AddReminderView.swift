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
    @State private var isDatePickerEnabled: Bool = false
    @State private var isDatePickerVisible: Bool = false
    @State private var isTimePickerEnabled: Bool = false
    @State private var isTimePickerVisible: Bool = false
    let isEditMode: Bool
    var reminderToEdit: Reminder?
    var onSave: (ModelContext, Reminder) -> Void
    var onDelete: (() -> Void)?
    var timeReminders = ["Tidak ada", "1 Jam Sebelum", "2 Jam Sebelum", "1 Hari Sebelum", "2 Hari Sebelum", "1 Minggu Sebelum"]
    @State private var selectedFisrtTimeReminder = "Tidak ada"
    @State private var selectedSecondTimeReminder = "Tidak ada"
    @State private var selectedThirdTimeReminder = "Tidak ada"
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(reminder: Reminder? = nil,
         notifications: Binding<[Bool]> = .constant([true, false, false, false, false, false]),
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
        
        // Ensure notifications array is passed in correctly
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
                    
                    // Satu baris untuk Tanggal dan Jam
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
                        Toggle("Pada Waktunya", isOn: $notifications[0])
                        Divider()
                        Toggle("3 Hari Sebelumnya", isOn: $notifications[1])
                        Divider()
                        Toggle("1 Hari Sebelumnya", isOn: $notifications[2])
                        Divider()
                        Toggle("3 Jam Sebelumnya", isOn: $notifications[3])
                        Divider()
                        Toggle("1 Jam Sebelumnya", isOn: $notifications[4])
                        Divider()
                        Toggle("15 Menit Sebelumnya", isOn: $notifications[5])
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
                        saveReminder()
                    }.disabled(clinicName.trimmingCharacters(in: .whitespaces).isEmpty)
                )
                .onAppear {
                    if !isEditMode {
                        notifications[0] = true
                    }
                }
            }
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


struct AddReminderView_Previews: PreviewProvider {
    @State static var notifications = [true, false, false, false, false, false] // Initial states for notification toggles
    
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
