import SwiftUI

struct SettingsView: View {
    @State private var inputName: String = UserDefaults.standard.string(forKey: "name") ?? "Unknown name"
    @State private var inputDayOfBirth: Date = {
        let birthDateString = UserDefaults.standard.string(forKey: "dateOfBirth") ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthDateString) ?? Date()
    }()
    
    @State private var showDatePicker = false
    
    // Notification toggles
    @State private var fatLimit = UserDefaults.standard.bool(forKey: "fatLimit")
    @State private var dairyLimit = UserDefaults.standard.bool(forKey: "dairyLimit")
    @State private var nutritionReminder = UserDefaults.standard.bool(forKey: "nutritionReminder")
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            // Navigation Bar
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Jurnal")
                }.onTapGesture {
                    saveSettings() // Save settings when dismissing
                    dismiss()
                }
                
                Spacer()
                
                Text("Pengaturan")
                    .foregroundColor(.black)
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
            
            VStack(spacing: 0) {
                // Name Field
                HStack {
                    Text("Nama")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Nama", text: $inputName)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .padding(.trailing, 16)
                        .onChange(of: inputName) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "name")
                        }
                }
                .background(Color(UIColor.systemBackground))
                
                Divider()
                    .padding(.leading)
                
                // Date of Birth Field
                HStack {
                    Text("Tanggal Lahir")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Text(dateFormatted(inputDayOfBirth))
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            DatePicker("Pilih Tanggal Lahir", selection: $inputDayOfBirth, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .padding()
                            
                            Button("Selesai") {
                                showDatePicker = false
                                saveBirthDate(inputDayOfBirth) // Save the new birthdate immediately
                            }
                            .padding()
                        }
                        .presentationDetents([.fraction(0.4)])
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
            
            VStack(spacing: 0) {
                // Fat Limit Toggle
                notificationToggle(title: "Batas Lemak Jenuh", description: "Jika melewati rekomendasi", isOn: $fatLimit)
                
                // Dairy Limit Toggle
                notificationToggle(title: "Batas Produk Susu", description: "Jika melebihi 1 porsi per hari", isOn: $dairyLimit)
                
                // Nutrition Reminder Toggle
                notificationToggle(title: "Pengingat Pengisian Nutrisi", description: "Diingatkan setiap jam 19.00", isOn: $nutritionReminder)
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            Spacer()
        }
        .padding()
        .background(Color.background.ignoresSafeArea())
        .onDisappear {
            saveSettings() // Save settings when the view disappears
        }
    }
    
    // Date formatting function
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    // Save the date of birth in UserDefaults
    private func saveBirthDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = formatter.string(from: date)
        UserDefaults.standard.set(birthDateString, forKey: "dateOfBirth")
    }
    
    // Save all settings to UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(inputName, forKey: "name")
        UserDefaults.standard.set(fatLimit, forKey: "fatLimit")
        UserDefaults.standard.set(dairyLimit, forKey: "dairyLimit")
        UserDefaults.standard.set(nutritionReminder, forKey: "nutritionReminder")
        saveBirthDate(inputDayOfBirth) // Ensure birth date is saved as well
    }
    
    // Reusable view for notification toggle rows
    private func notificationToggle(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { newValue in
                    UserDefaults.standard.set(newValue, forKey: title.lowercased().replacingOccurrences(of: " ", with: ""))
                }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SettingsView()
}
