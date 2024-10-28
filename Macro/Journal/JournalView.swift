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
    @StateObject private var icViewModel = FoodClassificationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()  // Add SearchViewModel to fetch food details
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var isMenuSheetPresented = false
    @State var navigateToMenuPage = false
    @State var isAddSleepViewPresented = false
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
    
    private var todayJournal: Journal? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        return journals.first { journal in
            calendar.isDate(journal.timestamp, inSameDayAs: todayStart)
        }
    }
    
    var body: some View {
        ZStack{
            NavigationStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Jurnal")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            
                            Spacer()
                            
                            NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {
                                Button(action: {
                                    navigateToHistoryView = true
                                }) {
                                    Image(systemName: "book.pages")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                        .bold()
                                }
                                .padding(.horizontal)
                            }
                            
                            
                        }
                        .padding()
                        
                        VStack{
                            HStack{
                                Text(viewModel.getMonthInIndonesian())
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding()
                            .padding(.top, 12)
                            
                            HStack {
                                ForEach(viewModel.days, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(day == "Min" ? .red : .accentColor)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                            
                            HStack {
                                ForEach(viewModel.daysInCurrentWeek(), id: \.self) { date in
                                    VStack {
                                        Text("\(Calendar.current.component(.day, from: date))")
                                            .font(.body)
                                            .frame(width: 24, height: 16)
                                            .multilineTextAlignment(.center)
                                            .padding(12)
                                            .background(viewModel.isSelected(date: date) ? Color.accentColor : Color.clear)
                                            .clipShape(Circle())
                                            .foregroundColor(viewModel.isSelected(date: date) ? Color.white : Color.black)
                                    }
                                    .onTapGesture {
                                        viewModel.selectDate(date: date)
                                    }
                                }
                            }
                            .padding(.top, 6)
                            
                        }
                        .frame(width: .infinity, height: 170,  alignment: .topLeading)
                        .cornerRadius(12)
                        .background(Color.white)
                        
                        
                        HStack{
                                                Text("Tidur")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
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
                                            .padding(.top, 28)
                        
                        VStack {
                                                HStack() {
                                                    VStack{
                                                        
                                                        HStack{
                                                            Text("Waktu di Tempat Tidur")
                                                                .padding(.horizontal)
                                                                .padding(.top, 20)
                                                                .foregroundColor(.gray)
                                                                .font(.callout)
                                                            
                                                            Spacer()
                                                        }
                                                        
                                                        HStack {
                                                            Text(viewModel.getSleep(journals: journals))
                                                                .font(.system(size: 18))
                                                                .foregroundColor(.gray)
                                                                .padding(.horizontal)
                                                                .padding(.top, 2)
                                                                .padding(.bottom, 20)
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                    Image(systemName: "moon.zzz.fill")
                                                        .foregroundColor(.systemGray2)
                                                        .font(.system(size: 80 ))
                                                        .padding(.bottom, -24)
                                                    
                                                }
                                                .frame(maxWidth: .infinity)
                                                .background(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .padding(.horizontal)
                        
                        HStack {
                                               Text("Nutrisi")
                                                   .font(.title2)
                                                   .fontWeight(.bold)
                                                   .padding()
                                               Spacer()
                                               
                                               Button(action: {
                                                   viewModel.presentActionSheet()
                                               }) {
                                                   Text("Tambah")
                                                       .foregroundColor(.accentColor)
                                               }
                            .padding(.top, 10)
                            .padding()
                            .padding(.trailing, 4)
                            .actionSheet(isPresented: $viewModel.isImagePickerPresented) {
                                ActionSheet(title: Text("Pilih gambar melalui"), buttons: [
                                    .default(Text("🖼 Pilih Foto dari Album")) {
                                        isPickerShowing = true
                                        viewModel.sourceType = .photoLibrary
                                    },
                                    .default(Text("📷 Ambil Gambar")) {
                                        isPickerShowing = true
                                        viewModel.sourceType = .camera
                                    },
                                    .default(Text("🔍 Cari Menu Makanan")) {
                                        viewModel.isDietViewPresented = true
                                    },
                                    .cancel()
                                ])
                            }
                        }
                        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                            ImagePickerViewModel(
                                selectedImage: $selectedImage,
                                isPickerShowing: $isPickerShowing,
                                sourceType: viewModel.sourceType,
                                onImagePicked: {
                                    if let image = selectedImage {
                                        classifyImageAndFetchDetails(image: image)  // Classify and fetch food details
                                    }
                                }
                            )
                        }
                        
                        // Sheet to display the MenuView after classification
                        .sheet(isPresented: $isMenuSheetPresented, onDismiss: {
                        }) {
                            MenuView(
                                image: selectedImage,
                                title: classificationTitle,
                                prob: classificationProb,
                                protein: protein,
                                fat: fat,
                                dairy: dairy,
                                glycemicIndex: glycemicIndex.rawValue
                            )
                        }
                        
                        .fullScreenCover(isPresented: $viewModel.isDietViewPresented, content: SearchView.init)
                        // Navigation to MenuView with the classified image, title, and probability
                        NavigationLink(
                            destination: MenuView(
                                image: selectedImage,
                                title: classificationTitle,
                                prob: classificationProb,
                                protein: protein,
                                fat: fat,
                                dairy: dairy,
                                glycemicIndex: glycemicIndex.rawValue
                            ),
                            isActive: $navigateToMenuPage
                        ) {
                            EmptyView()
                        }
                        .padding()
                        .padding(.top, 10)
                        
                        
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Protein")
                                                                                    .padding()
                                                                                    .fontWeight(.semibold)
                                                                                    .foregroundColor(.systemGray3)
                                                                                
                                                                                Spacer()
                                                                            }
                                                                            .background(
                                                                                Image("DrumStick")
                                                                                
                                                                                    .padding(.bottom, -30),
                                                                                alignment: .bottomTrailing)
                                                                                
                                                                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                                                                Text(String(format: "%.2f", viewModel.calcProtein(journals: journals)))
                                                                                    .font(.title)
                                                                                    .fontWeight(.bold)
                                                                                    .padding(.leading)
                                                                                    .padding(.vertical)
                                                                                
                                                                                Text("gram")
                                                                                    .font(.callout)
                                                                                    .foregroundColor(.systemGray3)
                                                                                
                                                                                Spacer()
                                                                            }
                                                                        
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Lemak")
                                                                                   .padding()
                                                                                   .fontWeight(.semibold)
                                                                                   .foregroundColor(.systemGray3)
                                                                               Spacer()
                                                                           }
                                                                           .background(
                                                                               Image("Burger")
                                                                               
                                                                                   .padding(.bottom, -30),
                                                                               alignment: .bottomTrailing)
                                                                           
                                                                           HStack {
                                                                               Text(String(format: "%.2f", viewModel.calcFat(journals: journals)))
                                                                                   .font(.title)
                                                                                   .fontWeight(.bold)
                                                                                   .padding(.leading)
                                                                                   .padding(.vertical)
                                                                               
                                                                               Text("gram")
                                                                                   .font(.callout)
                                                                                   .foregroundColor(.systemGray3)
                                                                                   .padding(.leading, -8)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                            }
                            
                            HStack(spacing: 10) {
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
                                                                                
                                                                                Text("kali")
                                                                                    .font(.callout)
                                                                                    .foregroundColor(.systemGray3)
                                                                                Spacer()
                                                                            }
                                                                            .background(
                                                                                Image("Milk")
                                                                                
                                                                                    .padding(.bottom, -20),
                                                                                alignment: .bottomTrailing
                                                                                )
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Indeks Glikemik")
                                                                                   .padding()
                                                                                   .fontWeight(.semibold)
                                                                                   .foregroundColor(.systemGray3)
                                        
                                    }
                                    .background(
                                                                           Image("Donut")
                                                                               .padding(.trailing, -10)
                                                                           
                                                                               .padding(.bottom, -50),
                                                                           alignment: .bottomTrailing
                                                                           )
                                    
                                    HStack {
                                        Text(String(viewModel.calcGI(journals: journals)))
                                                                                   .padding()
                                                                                   .fontWeight(.bold)
                                                                                   .font(.title)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, -60)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 40)
                    .padding(.bottom, 96)
                    .sheet(isPresented: $isAddSleepViewPresented) {
                        AddSleepView()
                        
                    }
                }
                .background(Color.background).edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                viewModel.fetchSleepData(context: context, journals: journals)
                
                let content = UNMutableNotificationContent()
                content.title = "Sleep"
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
    }
    
    func classifyImageAndFetchDetails(image: UIImage) {
        // Show toast when classification begins
        showToastMessage("Classifying image...")
        
        icViewModel.FoodClassificationModel(uiImage: image)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let title = icViewModel.imageClassificationText.first,
               let prob = icViewModel.imageClassificationProb.first {
                classificationTitle = title
                classificationProb = prob
                
                // Fetch the food details using the classification title
                searchViewModel.detailDiet(name: title)
                
                if let food = searchViewModel.food {
                    protein = food.protein
                    fat = food.fat
                    dairy = food.dairy
                    glycemicIndex = food.glycemicIndex
                }
                
                // Hide toast and present MenuView as a sheet
                hideToast()
                isMenuSheetPresented = true
            } else {
                // Show toast if no classification result is available
                print("Failed to classify image")
                showToastMessage("No classification result available")
            }
        }
    }
    // Reset classification state after the sheet is dismissed
    func resetClassificationState() {
        classificationTitle = ""
        classificationProb = 0.0
        protein = 0.0
        fat = 0.0
        dairy = false
        glycemicIndex = .low
        selectedImage = nil  // Reset the selected image to trigger new image classification properly
    }
    
    // Function to show a toast message
    func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Hide the toast after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hideToast()
        }
    }
    
    // Function to hide the toast
    func hideToast() {
        showToast = false
    }
    
}



#Preview {
    ContentView()
}
