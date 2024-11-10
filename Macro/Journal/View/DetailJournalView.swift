import SwiftUI
import SwiftData

struct DetailJournalView: View {
    @Binding var journalImage: JournalImage?
    let context: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditJournalViewPresented = false
    @State private var isImageSheetPresented = false
    @ObservedObject var viewModel: JournalImageViewModel
    
    @Binding var isDetailJournalViewPresented: Bool

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Kesehatan")
                    }
                    .onTapGesture {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Text("Detail Jurnal")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.trailing,54)
                    
                    Spacer()
                    
                    Button(action: {
                        isEditJournalViewPresented = true
                    }) {
                        Text("Edit")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .padding(.leading, 6)
                    }
                }
                .padding(.bottom, 34)
                .foregroundColor(.accentColor)
                
                if let journalImage = journalImage {
                    // Image Display
                    VStack {
                        if let imageData = journalImage.image, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 300)
                                .onTapGesture {
                                                                    isImageSheetPresented = true
                                                                }
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 240, height: 300)
                        }
                        
                        Text("\(journalImage.timestamp, formatter: fullDateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.8), radius: 8, x: 2, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white, lineWidth: 18)
                            )
                    )
                    .padding(.bottom, 36)
                    
                    // Information Section
                    HStack {
                        Text("Keterangan")
                            .font(.footnote)
                        Spacer()
                    }
                    .padding(.leading, 10)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Breakout")
                            Spacer()
                            Image(systemName: journalImage.isBreakout ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(journalImage.isBreakout ? .red : .green)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Menstruasi")
                            Spacer()
                            Image(systemName: journalImage.isMenstrual ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(journalImage.isMenstrual ? .red : .green)
                        }
                    }
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(10)
                    .padding(.horizontal, 4)
                    
                    HStack{
                        Text("Catatan Tambahan")
                            .font(.footnote)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 10)
                    
                    VStack(spacing: 0) {
                        HStack{
                        Text(journalImage.notes ?? "Tidak ada catatan tambahan")
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(maxWidth: 350, alignment: .leading)
                    }
                        .padding(.vertical, 14)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 14)
                    
                    
                    
                } else {
                    Text("Data tidak ditemukan")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Kesehatan")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditJournalViewPresented = true
                }) {
                    Text("Edit")
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $isEditJournalViewPresented) {
            if let journalImage = journalImage {
                EditJournalView(viewModel: viewModel, journalImage: journalImage, isDetailJournalViewPresented: $isDetailJournalViewPresented)
            }
        }
        .sheet(isPresented: $isImageSheetPresented) { // Enlarged image sheet
            if let imageData = journalImage?.image, let uiImage = UIImage(data: imageData) {
                VStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.8))
                        .edgesIgnoringSafeArea(.all)
                    
                    Button("Tutup Foto") {
                        isImageSheetPresented = false
                    }
                    .font(.headline)
                    .padding()
                }
            }
        }
        .background(Color.background.ignoresSafeArea())
    }
        
}

// Date formatter for displaying the full date
private let fullDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
}()


