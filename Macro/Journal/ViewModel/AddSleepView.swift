//
//  AddSleepView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

struct AddSleepView: View {
    @State private var isHeartDataFetched = false
    @ObservedObject var viewModel = JournalViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject var manager: HealthManager
    @Query var journals: [Journal]
    @State private var showAlert = false
    @State private var showAddSleepCard = false
    @State private var hasRecentSleepData = false
    
    var date: Date
    
    @State var startDate1: Date
    @State var endDate1: Date
    @State var showStartPicker1 = false
    @State var showEndPicker1 = false
    
    @State var startDate2: Date
    @State var endDate2: Date
    @State var showStartPicker2 = false
    @State var showEndPicker2 = false
    
    init (date: Date) {
        print("Date: \(date)")
        self.date = date
        _startDate1 = State(initialValue: date)
        _endDate1 = State(initialValue: date)
        _startDate2 = State(initialValue: date)
        _endDate2 = State(initialValue: date)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Batalkan") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mainLight)
                Spacer()
                Text("Tidur")
                    .bold()
                Spacer()
                
                Button("Simpan") {
                    viewModel.addSleep(context: context, journals: journals, start: startDate1, end: endDate1, mode: true)
                    if showAddSleepCard {
                        viewModel.addSleep(context: context, journals: journals, start: startDate2, end: endDate2, mode: false)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mainLight)
                .bold()
            }
            .padding()
            
            if !hasRecentSleepData {
                VStack {
                    Button(action: {
                        showAlert = true
                    }) {
                        HStack {
                            Image("HealthIcon")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.systemGray4, lineWidth: 1)
                                )
                                .padding(.leading, 14)
                            
                            Text("Ambil Data Tidur")
                                .foregroundColor(Color.accentColor)
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        .frame(width: .infinity, height: 50)
                        .background(Color.systemWhite)
                        .cornerRadius(10)
                        .padding(.bottom, 4)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Hubungkan ke Kesehatan"),
                            message: Text("Untuk aktivasi data tidur di Zora, buka Pengaturan di perangkat Anda → Aplikasi → Kesehatan → Akses Data & Perangkat → Zora → Nyalakan semua.")
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lihat cara mengatur pelacakan tidur di aplikasi kesehatan:")
                            .foregroundColor(Color.gray)
                            .font(.subheadline)

                        Text("https://support.apple.com/en-us/108906")
                            .foregroundColor(Color.blue)
                            .font(.subheadline)
                            .underline()
                            .onTapGesture {
                                if let url = URL(string: "https://support.apple.com/en-us/108906") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
                
            
            
            AddSleepCard(
                startDate: $startDate1,
                endDate: $endDate1,
                showStartPicker: Binding(
                    get: { showStartPicker1 },
                    set: { newValue in
                        showStartPicker1 = newValue
                        if newValue {
                            showEndPicker1 = false
                            showStartPicker2 = false
                            showEndPicker2 = false
                        }
                    }
                ),
                showEndPicker: Binding(
                    get: { showEndPicker1 },
                    set: { newValue in
                        showEndPicker1 = newValue
                        if newValue {
                            showStartPicker1 = false
                            showStartPicker2 = false
                            showEndPicker2 = false
                        }
                    }
                )
            )
            
            Button(action: {
                withAnimation {
                    showAddSleepCard.toggle()
                }
            }) {
                HStack{
                    Image(systemName: "plus")
                        .padding(.leading, 8)
                    
                    Text("Tambah Tidur")
                        .foregroundColor(Color.accentColor)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
            }
            if showAddSleepCard {
                AddSleepCard(
                    startDate: $startDate2,
                    endDate: $endDate2,
                    showStartPicker: Binding(
                        get: { showStartPicker2 },
                        set: { newValue in
                            showStartPicker2 = newValue
                            if newValue {
                                showStartPicker1 = false
                                showEndPicker1 = false
                                showEndPicker2 = false
                            }
                        }
                    ),
                    showEndPicker: Binding(
                        get: { showEndPicker2 },
                        set: { newValue in
                            showEndPicker2 = newValue
                            if newValue {
                                showStartPicker1 = false
                                showEndPicker1 = false
                                showStartPicker2 = false
                            }
                        }
                    )
                )
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.background)
        .onAppear {
            manager.fetchSleepDataForLast7Days { sleepData, count in
                // Update hasRecentSleepData based on the count
                DispatchQueue.main.async {
                    hasRecentSleepData = count > 0
                }
            }
            if let todayEntry = viewModel.hasEntriesFromToday(entries: journals) {
                startDate1 = todayEntry.sleep.start
                endDate1 = todayEntry.sleep.end
            }
        }
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
}

//struct SleepInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSleepView()
//    }
//}

extension View {
    func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
