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
    @ObservedObject var viewModel = JournalViewModel()
    @StateObject private var icViewModel = FoodClassificationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()  // Add SearchViewModel to fetch food details
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var navigateToMenuPage = false
    @State var isAddSleepViewPresented = false
    @State var navigateToHistoryView = false
    @State var classificationTitle: String = ""
    @State var classificationProb: Double = 0.0
    @State var protein: Double = 0.0
    @State var fat: Double = 0.0
    @State var dairy: Bool = false
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
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Ringkasan")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        
                        Spacer()
                    }
                    .padding()
                    
                    VStack{
                        HStack{
                            Text(viewModel.getMonthInIndonesian())
                                .font(.title2)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding()
                        .padding(.top, 12)
                        
                        HStack {
                            ForEach(viewModel.days, id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.systemMint)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        
                        HStack {
                            ForEach(viewModel.daysInCurrentWeek(), id: \.self) { date in
                                VStack {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.body)
                                        .frame(width: 18, height: 16)
                                        .multilineTextAlignment(.center)
                                        .padding(12)
                                        .background(viewModel.isSelected(date: date) ? Color.gray.opacity(0.3) : Color.clear)
                                        .clipShape(Circle())
                                }
                                .onTapGesture {
                                    viewModel.selectDate(date: date)
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                    .frame(width: 360, height: 170,  alignment: .topLeading)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    
                    HStack{
                        Text("Durasi Tidur")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        
                        Button(action: {
                            isAddSleepViewPresented = true
                        }) {
                            Text("Tambah")
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 4)
                    }
                    .padding()
                    .padding(.top, 10)
                    
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.getSleep(journals: journals))
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                                    .padding()
                                Spacer()
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                            HStack {
                                Button(action: {
                                    
                                }) {
                                    Text("Edit Data")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                        .padding(.bottom, 16)
                                        .padding(.top, 4)
                                }
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Diet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                        
                        Button(action: {
                            viewModel.presentActionSheet()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
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
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                HStack {
                                    Text(String(format: "%.2f", viewModel.calcProtein(journals: journals))+" gr")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: -24) {
                                HStack {
                                    Text("Fat")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                HStack {
                                    Text(String(format: "%.2f", viewModel.calcFat(journals: journals))+" gr")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        }
                        
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: -24) {
                                HStack {
                                    Text("Diaries")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                HStack {
                                    Text(String(viewModel.calcDairy(journals: journals))+" product(s)")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: -24) {
                                HStack {
                                    Text("Glycemic")
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                HStack {
                                    Text(String(viewModel.calcGI(journals: journals)))
                                        .padding()
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, -60)
                    
                    HStack{
                        Text("More")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {
                        Button(action: {
                            navigateToHistoryView = true
                        }) {
                            HStack {
                                Text("Tampilkan Semua Data")
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        .padding(.top, -12)
                    }
                    
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
        }
    }
    // Function to classify the image and fetch food details
        private func classifyImageAndFetchDetails(image: UIImage) {
            // Run the classification model
            icViewModel.FoodClassificationModel(uiImage: image)
            
            // Delay to allow model to update (adjust timing as needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Get the classification result and set the title and probability
                if let title = icViewModel.imageClassificationText.first,
                   let prob = icViewModel.imageClassificationProb.first {
                    self.classificationTitle = title
                    self.classificationProb = prob
                    print("Title: \(title), Probability: \(prob)")  // Print the result
                    
                    // Fetch the food details using the classification title
                    searchViewModel.detailDiet(name: title)
                    
                    // Set the nutritional information if available
                    if let food = searchViewModel.food {
                        protein = food.protein
                        fat = food.fat
                        dairy = food.dairy
                        glycemicIndex = food.glycemicIndex
                    }
                } else {
                    print("No classification result available")
                }
                
                // Navigate to MenuView after classification and fetching food details
                navigateToMenuPage = true
            }
        }
    
}



#Preview {
    ContentView()
}
