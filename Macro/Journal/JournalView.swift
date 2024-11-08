//
//  JournalView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel = JournalViewModel()
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var isMenuSheetPresented = false
    @State var navigateToMenuPage = false
    @State var isAddSleepViewPresented = false
    @State var navigateToReminderView = false
    @State var isSettingsViewPresented = false
    @State var navigateToHistoryView = false
    @State var classificationTitle: String = ""
    @State var classificationProb: Double = 0.0
    @State var protein: Double = 0.0
    @State var fat: Double = 0.0
    @State var dairy: Bool = false
    @State private var showToast = false
    @State private var toastMessage: String = ""
    @State var glycemicIndex: glycemicIndex = .low
    @Query var journals: [Journal]
    @State private var isReminderSheetPresented = false
    @State private var showDatePicker = false
    @State private var savedDate: Date? = nil
    
    @State private var isDataLoaded = false
    
    private var GIs: [glycemicIndex: Int]? {
        viewModel.calcGIDetail(journals: journals)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
    
    private var hourFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter
    }
    
    var body: some View {
        ZStack{
            NavigationStack {
                ScrollView {
                    if isDataLoaded {
                        VStack {
                            HStack{
                                Text("Jurnal Harian")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: {
                                    isReminderSheetPresented = true
                                }) {
                                    Image(systemName: "bell")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.trailing, 2)
                                
                                Button(action: {
                                    isSettingsViewPresented = true
                                }) {
                                    Image(systemName: "gearshape")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                }
                                .sheet(isPresented: $isSettingsViewPresented) {
                                    SettingsView( journalViewModel: viewModel,
                                                  journals: journals)
                                }
                                
                            }
                            .padding(.top, 10)
                            .padding(.horizontal)
                            
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                
                                HStack {
                                    Button(action: {
                                        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                            }) {
                                                Image(systemName: "chevron.left")
                                                    .foregroundColor(.accentColor)
                                            }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showDatePicker.toggle()
                                    }) {
                                        Text("Hari ini, \(dateFormatter.string(from: viewModel.selectedDate))")
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                            }) {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.accentColor)
                                            }
                                }
                                .padding(.horizontal)
                            }
                            
                            if showDatePicker {
                                DatePickerView(showDatePicker: $showDatePicker, savedDate: $savedDate, selectedDate: $viewModel.selectedDate)
                                    .animation(.linear)
                                    .transition(.opacity)
                                    .onChange(of: viewModel.selectedDate) {
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                    }
                            }
                            
                            HStack(alignment: .bottom){
                                Text("Waktu Tidur")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                Button(action: {
                                    isAddSleepViewPresented = true
                                }) {
                                    Text("Edit")
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.top, 10)
                                .padding(.trailing, 4)
                                
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $isAddSleepViewPresented) {
                                AddSleepView(date: viewModel.selectedDate)
                            }
                            
                            ZStack {
                                Image("BannerFix")
                                    .resizable()
                                    .scaledToFit()
                                
                                VStack(alignment: .leading){
                                    HStack(alignment: .bottom,spacing: 0) {
                                        Text(viewModel.getSleep(journals: journals).hour)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .bold()
                                        
                                        Text("jam ")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                        
                                        Text(viewModel.getSleep(journals: journals).minute)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .bold()
                                        
                                        Text("menit")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 30)
                                    .padding(.bottom, 2)
                                    
                                    HStack{
                                        Text(viewModel.sleepClassificationMessage(journals: journals))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.leading, 30)
                                }
                            }
                            .padding(.vertical, -20)
                            
                            HStack(alignment: .bottom) {
                                Text("Detail Makanan")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding()
                                Spacer()
                                
                                Button(action: {
                                    viewModel.isDietViewPresented = true
                                }) {
                                    Text("Tambah")
                                        .foregroundColor(.accentColor)
                                }
                                .padding()
                                .padding(.trailing, 4)
                            }
                            .sheet(isPresented: $viewModel.isDietViewPresented) {
                                SearchView(isDetailViewPresented: $viewModel.isDietViewPresented, date: viewModel.selectedDate)
                            }
                            
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Makanan Berlemak")
                                                .padding(.leading)
                                                .padding(.vertical)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            
                                            Spacer()
                                        }
                                        .background(
                                            Image("drumstick")
                                                .padding(.bottom, -42),
                                            alignment: .bottomTrailing
                                        )
                                        
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                                            Text(String(viewModel.calcFat(journals: journals)))
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .padding(.leading)
                                                .padding(.vertical)
                                            
                                            Text("porsi")
                                                .font(.callout)
                                            
                                            Spacer()
                                        }
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                    
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Produk Susu")
                                                .padding()
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            Spacer()
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                                            Text(String(viewModel.calcDairy(journals: journals)))
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .padding(.leading)
                                                .padding(.vertical)
                                            
                                            
                                            Text("porsi")
                                                .font(.callout)
                                            
                                            Spacer()
                                        }                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                }
                                
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Indeks Glikemik")
                                                .padding()
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 20)
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text("Rendah: ")
                                            if let low = GIs?[.low] {
                                                Text("\(String(low))")
                                                    .bold()
                                            } else {
                                                Text("0")
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                            Divider()
                                            Spacer()
                                            
                                            Text("Sedang: ")
                                            if let medium = GIs?[.medium] {
                                                Text("\(String(medium))")
                                                    .bold()
                                            } else {
                                                Text("0")
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                            Divider()
                                            Spacer()
                                            
                                            Text("Tinggi: ")
                                            if let high = GIs?[.high] {
                                                Text("\(String(high))")
                                                    .bold()
                                            } else {
                                                Text("0")
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                    }
                                    .padding(.bottom, 20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, -12)
                            
                            HStack(alignment: .bottom) {
                                Text("Riwayat Harian")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                //                                .padding()
                                
                                Spacer()
                                
                                NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {Button(action: {
                                    navigateToHistoryView = true
                                }) {
                                    Text("Lihat Semua")
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.top, 10)
                                .padding(.trailing, 4)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 16)
                            
                            VStack (spacing: 0){
                                if let foods = viewModel.hasEntriesFromDate(entries: journals, date: viewModel.selectedDate)?.foods.sorted(by: { $0.timestamp < $1.timestamp }).reversed() {
                                    ForEach(foods) { food in
                                        HStack {
                                            HStack{
                                                Text(food.name)
                                                Spacer()
                                                Text("\(hourFormatter.string(from: food.timestamp))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        Divider()
                                            .padding(.leading)
                                    }
                                }
                            }
                            .background(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                            
                            
                            
                        }
                        .padding(.top, 36)
                        .background(Color.background).edgesIgnoringSafeArea(.all)
                    }
                }
                .background(Color.background).edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                
                if !isDataLoaded {
                    isDataLoaded.toggle()
                }
                
                let content = UNMutableNotificationContent()
                content.title = "Zora - Sleep"
                content.subtitle = "Do not forget to input your sleep!"
                content.sound = UNNotificationSound.default
                
                var dateComponents = DateComponents()
                dateComponents.hour = 9
                dateComponents.minute = 30
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let notificationIdentifier = "uniqueNotificationId"
                
                // Cancel existing notification with the same identifier
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                
                let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification: \(error.localizedDescription)")
                    }
                }
                
            }
            if showToast {
                VStack {
                    Spacer()
                    ToastView(message: toastMessage)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: showToast)
            }
        }
        .sheet(isPresented: $isReminderSheetPresented) {
            ReminderView(viewModel: ReminderViewModel())
                .environment(\.modelContext, context)
        }
    }
    
}

#Preview {
    ContentView()
}
