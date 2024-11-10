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
            ScrollView{
                VStack(alignment: .leading) {
                    Text("PENGINGAT KUNJUNGAN KONTROL")
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.leading, 12)
                    
                    HStack {
                        TextField("Nama Kunjungan", text: $clinicName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                    .padding(.leading)
                    .background(Color(UIColor.systemWhite))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Tanggal")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $isDatePickerEnabled)
                                    .labelsHidden()
                                    .disabled(isTimePickerVisible)
                            }
                            .padding(.horizontal)
                            
                            if isDatePickerEnabled {
                                Text(visitDate, style: .date)
                                    .padding(.top, -14)
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        withAnimation {
                                            isDatePickerVisible.toggle()
                                            
                                            if isDatePickerVisible {
                                                                                            isTimePickerVisible = false
                                                                                        }
                                        }
                                    }
                                
                                if isDatePickerVisible {
                                    DatePicker(
                                        "",
                                        selection: $visitDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 18)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Jam")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $isTimePickerEnabled)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            
                            if isTimePickerEnabled {
                                Text(visitTime, style: .time)
                                    .padding(.top, -14)
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        withAnimation {
                                            isTimePickerVisible.toggle()
                                            if isTimePickerVisible {
                                                                                            isDatePickerVisible = false
                                                                                        }
                                        }
                                    }
                                
                                if isTimePickerVisible {
                                    DatePicker(
                                        "",
                                        selection: $visitTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding(.horizontal)
                                    
                                    
                                }
                                
                                
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemWhite))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Text("PENGINGAT")
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
//                    VStack{
//                        HStack{
//                            Text("Peringatan")
//                            
//                            Spacer()
//                            
//                            Picker("", selection: $selectedFisrtTimeReminder) {
//                                ForEach(timeReminders, id: \.self) { reminder in
//                                    Text(reminder)
//                                }
//                            }
//                            .accentColor(.gray)
//                        }
//                        Divider()
//                        HStack{
//                            Text("Peringatan Kedua")
//                            
//                            Spacer()
//                            
//                            Picker("", selection: $selectedSecondTimeReminder) {
//                                ForEach(timeReminders, id: \.self) { reminder in
//                                    Text(reminder)
//                                }
//                            }
//                            .accentColor(.gray)
//                        }
//                        Divider()
//                        HStack{
//                            Text("Peringatan Ketiga")
//                            
//                            Spacer()
//                            
//                            Picker("", selection: $selectedThirdTimeReminder) {
//                                ForEach(timeReminders, id: \.self) { reminder in
//                                    Text(reminder)
//                                }
//                            }
//                            .accentColor(.gray)
//                            
//                        }
//                    }
//                    .padding()
//                    .padding(.vertical, -8)
//                    .background(Color(UIColor.systemWhite))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
                    
                    VStack{
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
                    .padding(.vertical, -8)
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
