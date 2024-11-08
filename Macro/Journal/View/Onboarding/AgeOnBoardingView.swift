import SwiftUI

struct AgeOnBoardingView: View {
    @State private var selectedDate: Date = Date()
    @Binding var hasCompletedOnboarding: Bool
    var navigationStates: [String: Bool]
    @State private var isDatePickerPresented = false
    @ObservedObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Kapan tanggal lahirmu?")
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                
                // Custom date display and date picker button
                Button(action: {
                    isDatePickerPresented.toggle()
                }) {
                    VStack {
                        Text(selectedDateFormatted())
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                        
                        Divider()
                            .background(Color.white)
                            .padding(.horizontal, 50)
                    }
                }
                .sheet(isPresented: $isDatePickerPresented) {
                    VStack {
                        DatePicker("Pilih Tanggal Lahir", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                        
                        Button("Selesai") {
                            isDatePickerPresented = false
                        }
                        .padding()
                        .font(.headline)
                    }
                    .presentationDetents([.fraction(0.4)]) // Customize the modal height
                }.padding(.top, 140)
                
                Spacer()

                Button(action: {
                    saveBirthDate()
                    hasCompletedOnboarding = true // Complete onboarding and go to JournalView
                }) {
                    Text("Selanjutnya")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.main.ignoresSafeArea())
            .onAppear {
                viewModel.subscribeToKeyboardEvents()
            }
            .onDisappear {
                viewModel.unsubscribeFromKeyboardEvents()
            }
        }
    }
    
    private func selectedDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func saveBirthDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Save in yyyy-MM-dd format
        let birthDateString = formatter.string(from: selectedDate)
        UserDefaults.standard.set(birthDateString, forKey: "dateOfBirth")
    }
}
