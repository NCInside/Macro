import SwiftUI
import SwiftData

struct ReminderView: View {
    @StateObject private var viewModel: ReminderViewModel
    @State private var isEditing = false
    @State private var sheetMode: SheetMode? // Single state for sheet
    @State private var reminderToDelete: Reminder? // New state variable for deletion
    @State private var notifications: [Bool] = Array(repeating: false, count: 6) // Define notifications state here
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss // Add dismiss environment variable

    init(viewModel: ReminderViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                // Title for the section
                Text("KUNJUNGAN")
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.leading, 12)

                // Reminder list and Add Reminder button
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.reminders.indices, id: \.self) { index in
                            let reminder = viewModel.reminders[index]
                            ReminderListItemView(
                                reminder: reminder,
                                isEditing: isEditing,
                                onDelete: {
                                    reminderToDelete = reminder // Set the reminder to delete
                                    print("Delete button clicked for clinic: \(reminder.clinicName)")
                                },
                                action: {
                                    sheetMode = .edit(reminder) // Set sheet to edit mode for editing
                                    print("Edit button clicked for clinic: \(reminder.clinicName)")
                                },
                                isFirst: index == 0,
                                isLast: index == viewModel.reminders.count - 1
                            )
                        }

                        if !viewModel.reminders.isEmpty {
                            Text("Kontrol terdekat berada di posisi paling atas. Ketuk Edit untuk menghapus pengingat kunjungan")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                        }

                        AddReminderButton {
                            sheetMode = .add // Set sheet to add mode
                            print("Add Reminder button clicked")
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                Spacer()
            }
            .background(Color(.background).ignoresSafeArea())
            .navigationTitle("Pengingat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    print("Back button clicked")
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Jurnal")
                    }
                },
                trailing: Button(isEditing ? "Selesai" : "Edit") {
                    isEditing.toggle()
                    print("Edit mode toggled: \(isEditing)")
                }
            )
            .onAppear {
                viewModel.loadReminders(context: context)
                print("Reminders loaded on appear")
            }
            .sheet(item: $sheetMode, onDismiss: { sheetMode = nil }) { mode in
                switch mode {
                case .add:
                    AddReminderView(
                        notifications: $notifications,
                        onSave: { modelContext, newReminder in
                            viewModel.addReminder(context: modelContext, reminder: newReminder, notificationOptions: notifications)
                        }
                    )
                case .edit(let reminder):
                    // Load saved notifications into a temporary state variable
                    var editableNotifications = viewModel.getNotificationOptions(for: reminder)
                    
                    AddReminderView(
                        reminder: reminder,
                        notifications: Binding(
                            get: { editableNotifications },
                            set: { editableNotifications = $0 }
                        ),
                        onSave: { modelContext, updatedReminder in
                            viewModel.updateReminder(context: modelContext, reminder: updatedReminder, notificationOptions: editableNotifications)
                        },
                        onDelete: {
                            viewModel.removeReminder(reminder, context: context)
                        }
                    )
                }
            }




            .confirmationDialog(
                "Hapus Kunjungan",
                isPresented: Binding(
                    get: { reminderToDelete != nil },
                    set: { if !$0 { reminderToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let reminder = reminderToDelete {
                    Button("Hapus", role: .destructive) {
                        print("Delete confirmed for reminder: \(reminder.clinicName)")
                        viewModel.removeReminder(reminder, context: context)
                        reminderToDelete = nil
                    }
                }
                Button("Batal", role: .cancel) {
                    reminderToDelete = nil
                }
            } message: {
                if let reminder = reminderToDelete {
                    Text("Apakah Anda yakin ingin menghapus pengingat kunjungan ke klinik \(reminder.clinicName)?")
                }
            }
        }
    }
}


// Reminder List Item with Edit/Delete Button
struct ReminderListItemView: View {
    let reminder: Reminder
    let isEditing: Bool
    let onDelete: () -> Void
    let action: () -> Void
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack {
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .padding(.leading)
                }
                .accessibilityLabel("Hapus pengingat \(reminder.clinicName)")
            }
            ReminderItemView(reminder: reminder, action: action)
                .cornerRadius(8)
        }
        .background(Color.systemWhite)
        .cornerRadius(10, corners: getRoundedCorners())
        .padding(.horizontal)
        
        if !isLast {
                        Divider()
                .padding(.horizontal, 32)
                    }
    }
    
    // Determine which corners to round
    private func getRoundedCorners() -> UIRectCorner {
        if isFirst && isLast {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        } else if isFirst {
            return [.topLeft, .topRight]
        } else if isLast {
            return [.bottomLeft, .bottomRight]
        } else {
            return []
        }
    }
}

// Reminder Item View
struct ReminderItemView: View {
    let reminder: Reminder
    let action: () -> Void

    private var formattedVisitDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH.mm"
        return formatter.string(from: reminder.visitDate)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.clinicName)
                        .font(.body)
                        .foregroundColor(Color.systemBlack)
                    Text(formattedVisitDateTime) // Display both date and time
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.systemWhite)
        }
    }
}

// Separate view for the add reminder button
struct AddReminderButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("Tambah kunjungan")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.systemWhite)
            .cornerRadius(8)
        }
    }
}

// Rounded Corner Extension
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(corners: corners, radius: radius))
    }
}

// Define the SheetMode enum
enum SheetMode: Identifiable {
    case add
    case edit(Reminder)
    
    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let reminder):
            return reminder.id.uuidString
        }
    }
}


