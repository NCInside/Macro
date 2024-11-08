import SwiftUI
import SwiftData

struct SkinHealthView: View {
    @State private var selectedDate = Date()
    @State var isAddJournalViewPresented = false
    @State var isDetailJournalViewPresented = false
    @StateObject private var viewModel: JournalImageViewModel
    @State private var selectedJournalImage: JournalImage? // Track selected journal
    let context: ModelContext

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: JournalImageViewModel(context: context))
        self.context = context
    }

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3) // 3-column grid without spacing

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("Kesehatan Kulit")
                        .font(.title)
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
                }
                .padding(.bottom, 10)
                
                if viewModel.journalImages.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Kamu belum menambahkan foto")
                            .foregroundColor(.gray)
                            .font(.body)
                    }
                    .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(viewModel.journalImages.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { journalImage in
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
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("\(journalImage.timestamp, formatter: dateFormatter)")
                                            .font(.caption2)
                                            .bold()
                                            .multilineTextAlignment(.center)
                                            .frame(width: 36, height: 36)
                                            .background(Color.black.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                        
                                        if journalImage.isBreakout {
                                            Triangle()
                                                .fill(Color.yellow)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    .padding(6)
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
                Button(action: {
                    viewModel.addDummyData()
                }) {
                    Text("Add Dummy Data for Testing")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.bottom, 16)
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
    }

    
    private func handleAddButtonTapped() {
        // Check if there is a journal entry for the current date
        if let todayEntry = viewModel.journalImages.first(where: { Calendar.current.isDateInToday($0.timestamp) }) {
            // If a journal entry for today exists, show the detail view of the latest entry
            selectedJournalImage = todayEntry
            isDetailJournalViewPresented = true
        } else {
            // Otherwise, open the add journal view
            isAddJournalViewPresented = true
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
    let formatter = DateFormatter()
    formatter.dateFormat = "d\nMMM" // Display day and short month in Indonesian format, split into two lines
    formatter.locale = Locale(identifier: "id_ID") // Set locale to Indonesian
    return formatter
}()
