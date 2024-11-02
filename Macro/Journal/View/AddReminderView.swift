import SwiftUI
import SwiftData

struct AddReminderView: View {
    @State var clinicName: String
    @State var visitDate: Date
    @State private var showDeleteConfirmation = false
    @State private var showErrorDialog = false
    @State private var errorMessage = ""
    let isEditMode: Bool
    var reminderToEdit: Reminder?
    var onSave: (ModelContext, Reminder) -> Void
    var onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Custom initializer to handle both add and edit modes
    init(reminder: Reminder? = nil,
         onSave: @escaping (ModelContext, Reminder) -> Void,
         onDelete: (() -> Void)? = nil) {
        if let reminder = reminder {
            _clinicName = State(initialValue: reminder.clinicName)
            _visitDate = State(initialValue: reminder.visitDate)
            self.isEditMode = true
            self.reminderToEdit = reminder
            print("Initialized in Edit Mode with clinic: \(reminder.clinicName)")
        } else {
            _clinicName = State(initialValue: "")
            _visitDate = State(initialValue: Date())
            self.isEditMode = false
            self.reminderToEdit = nil
            print("Initialized in Add Mode")
        }
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("PENGINGAT KUNJUNGAN KONTROL")
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Klinik")
                            .font(.body)
                            .frame(width: 80, alignment: .leading) // Ensure consistent alignment for label and input
                        TextField("Nama Klinik", text: $clinicName)
                            .multilineTextAlignment(.leading)
                            .textFieldStyle(PlainTextFieldStyle()) // Make TextField borderless
                            .foregroundColor(.gray)
                    }
                    Divider()
                    HStack {
                        Text("Kunjungan")
                            .font(.body)
                            .frame(width: 80, alignment: .leading) // Ensure consistent alignment for label and input
                        DatePicker("", selection: $visitDate, displayedComponents: .date)
                            .labelsHidden()
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(UIColor.systemWhite))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Text("Aplikasi akan mengingatkan Anda tiga hari dan sehari sebelum kunjungan, pada jam 09.00 pagi. Anda juga akan mendapatkan pengingat pada hari kunjungan di jam 07.00 pagi.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                if isEditMode {
                    Button(action: {
                        
                            print("Hapus Pengingat button clicked")
                            
                        
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                        Text("Hapus Kunjungan")
                            .foregroundColor(.red)
                        Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                    .padding(.horizontal)
                    .confirmationDialog("Hapus Kunjungan", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                        Button("Hapus", role: .destructive) {
                            print("Delete confirmed for clinic: \(reminderToEdit?.clinicName ?? "Unknown")")
                            onDelete?() // Trigger deletion in the parent view
                            dismiss()   // Dismiss view after deletion
                        }
                        Button("Batal", role: .cancel) {
                            print("Delete cancelled for clinic: \(reminderToEdit?.clinicName ?? "Unknown")")
                        }
                    } message: {
                        Text("Apakah Anda yakin ingin menghapus pengingat kunjungan ke klinik \(reminderToEdit?.clinicName ?? "ini") ")
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    print("Back button clicked")
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Pengingat")
                    }
                },
                trailing: Button("Simpan") {
                    print("Simpan button clicked")
                    saveReminder()
                }
                    .disabled(clinicName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .confirmationDialog("Error", isPresented: $showErrorDialog, titleVisibility: .visible) {
                Button("OK", role: .cancel) {
                    print("Error dialog dismissed")
                }
            } message: {
                Text(errorMessage)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
    
    // Function to handle saving the reminder
    private func saveReminder() {
        print("Attempting to save reminder...")
        if isEditMode, let reminder = reminderToEdit {
            print("Editing reminder: \(reminder.clinicName)")
            reminder.clinicName = clinicName
            reminder.visitDate = visitDate
            do {
                try modelContext.save()
                print("Successfully saved edited reminder.")
            } catch {
                print("Failed to save edited reminder: \(error.localizedDescription)")
                showError(message: "Gagal menyimpan pengingat. Silakan coba lagi.")
                return
            }
        } else {
            let trimmedClinicName = clinicName.trimmingCharacters(in: .whitespaces)
            guard !trimmedClinicName.isEmpty else {
                print("Clinic name is empty.")
                showError(message: "Nama Klinik tidak boleh kosong.")
                return
            }
            let newReminder = Reminder(clinicName: trimmedClinicName, visitDate: visitDate)
            print("Creating new reminder: \(newReminder.clinicName) on \(newReminder.visitDate)")
            onSave(modelContext, newReminder)
            print("onSave called for new reminder.")
        }
        dismiss()
        print("Dismissed AddReminderView.")
    }
    
    // Function to show error dialogs
    private func showError(message: String) {
        errorMessage = message
        showErrorDialog = true
        print("Error: \(message)")
    }
}
