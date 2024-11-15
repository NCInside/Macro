import SwiftUI
import SwiftData

struct SkinHealthView: View {
    @State private var selectedDate = Date()
    @State var isAddJournalViewPresented = false
    @State var isDetailJournalViewPresented = false
    @StateObject private var viewModel: JournalImageViewModel
    @State private var selectedJournalImage: JournalImage? // Track selected journal
    @State private var isPickerPresented: Bool = false
    let context: ModelContext
    @State private var showAlert = false
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // Track selected month
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    
    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: JournalImageViewModel(context: context))
        self.context = context
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4), count: 3) // 3-column grid without spacing
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("Kesehatan Kulit")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        handleAddButtonTapped()
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                            .bold()
                    }
                    .sheet(isPresented: $isAddJournalViewPresented) {
                        AddJournalView(viewModel: viewModel)
                    }
                    .alert(isPresented: $showAlert) { // Display alert
                        Alert(
                            title: Text("Pengingat"),
                            message: Text("Anda sudah menambahkan foto hari ini"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal)
                
                HStack {
                    Menu {
                        Picker("Select Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                            }
                        }
                        .pickerStyle(InlinePickerStyle())
                    } label: {
                        Text(Calendar.current.monthSymbols[selectedMonth - 1])
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .cornerRadius(8)
                        
                        Image(systemName: "chevron.down")
                            .padding(.leading, -18)
                            .bold()
                    }
                    
                    Spacer()
                    
                    HStack{
                        Image(systemName: "triangle.fill")
                            .foregroundColor(.yellow)
                            .font(.callout)
                        
                        Text("Breakout")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.leading, -4)
                    }
                    .padding(.trailing, 8)
                    
                    HStack{
                        Image(systemName: "circle.fill")
                            .foregroundColor(.red)
                            .font(.callout)
                        
                        Text("PMS")
                            .padding(.leading, -4)
                            .fontWeight(.medium)
                            .font(.subheadline)
                    }
                    .padding(.trailing)
                }
                .padding(.leading, 2)
                .padding(.top, -10)
                .padding(.bottom, -10)
                
                if viewModel.journalImages.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.bottom, 6)
                        Text("Kamu belum menambahkan foto")
                            .foregroundColor(.gray)
                            .font(.body)
                    }
                    .padding(.top, 240)
                } else {
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.journalImages.filter { image in
                                let imageDate = Calendar.current.dateComponents([.year, .month], from: image.timestamp)
                                return imageDate.year == currentYear && imageDate.month == selectedMonth
                            }.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { journalImage in
                                ZStack(alignment: .topLeading) {
                                    if let imageData = journalImage.image, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                                            .clipped()
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .center, spacing: 4) {
                                            VStack (spacing: 0) {
                                                Text("\(journalImage.timestamp, formatter: dateFormatter)")
                                                
                                            }
                                            .font(.subheadline)
                                            .bold()
                                            .multilineTextAlignment(.center)
                                            .frame(width: 28, height: 20)
                                            .background(Color.black.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                            
                                        }
                                        .padding(6)
                                        
                                        Spacer()
                                        
                                        
                                        if journalImage.isBreakout || journalImage.isMenstrual {
                                            HStack {
                                                if journalImage.isBreakout {
                                                    Image(systemName: "triangle.fill")
                                                        .foregroundColor(.yellow)
                                                        .font(.footnote)
                                                }
                                                
                                                if journalImage.isMenstrual {
                                                    Image(systemName: "circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.footnote)
                                                }
                                            }
                                            .frame(width: .infinity, height: 20)
                                            .padding(.horizontal, 4)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .padding(6)
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    .padding(.top, 1)
                                }
                                .onTapGesture {
                                    selectedJournalImage = journalImage
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Button to add dummy data
//                Button(action: {
//                    viewModel.addDummyData()
//                }) {
//                    Text("Add Dummy Data for Testing")
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(8)
//                }
//                .padding(.bottom, 16)
            }
            .padding(.horizontal, 0)
            .onChange(of: selectedJournalImage) { _ in
                if selectedJournalImage != nil {
                    isDetailJournalViewPresented = true
                }
            }
            .sheet(isPresented: $isDetailJournalViewPresented, onDismiss: {
                selectedJournalImage = nil // Reset after the sheet is dismissed
            }) {
                if let journalImage = selectedJournalImage {
                    DetailJournalView(journalImage: .constant(journalImage), context: context, viewModel: viewModel, isDetailJournalViewPresented: $isDetailJournalViewPresented)
                }
            }
        }
        .background(Color.background)
    }
    
    
    private func handleAddButtonTapped() {
        // Check if there is a journal entry for today's date
        let today = Calendar.current.startOfDay(for: Date())
        if viewModel.journalImages.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }) {
            showAlert = true // Show alert if there is already an entry today
        } else {
            isAddJournalViewPresented = true // Present AddJournalView if no entry for today
        }
    }
}


// Define the Triangle shape if it is missing
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// DateFormatter for displaying date
private let dateFormatter: DateFormatter = {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "d"
    dateformatter.locale = Locale(identifier: "id_ID") // Set locale to Indonesian
    return dateformatter
}()

private let monthFormatter: DateFormatter = {
    let monthformatter = DateFormatter()
    monthformatter.dateFormat = "MMM"
    monthformatter.locale = Locale(identifier: "id_ID")
    return monthformatter
}()


#Preview {
    ContentView()
}
