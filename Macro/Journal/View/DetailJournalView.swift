import SwiftUI
import SwiftData

struct DetailJournalView: View {
    @Binding var journalImage: JournalImage?
    let context: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditJournalViewPresented = false

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
                    
                    Spacer()
                    
                    Button(action: {
                        isEditJournalViewPresented = true
                    }) {
                        Text("Edit")
                            .font(.headline)
                            .foregroundColor(.blue)
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
                                .cornerRadius(10)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 240, height: 300)
                                .cornerRadius(10)
                        }
                        
                        Text("\(journalImage.timestamp, formatter: fullDateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.8), radius: 8, x: 2, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 18)
                            )
                    )
                    .padding(.bottom, 36)
                    
                    // Information Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Keterangan")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.leading, 10)

                        HStack {
                            Text("Breakout")
                            Spacer()
                            Image(systemName: journalImage.isBreakout ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(journalImage.isBreakout ? .red : .green)
                        }

                        HStack {
                            Text("Menstruasi")
                            Spacer()
                            Image(systemName: journalImage.isMenstrual ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(journalImage.isMenstrual ? .red : .green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Catatan Tambahan")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Text(journalImage.notes ?? "Tidak ada catatan tambahan")
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
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
                EditJournalView(viewModel: JournalImageViewModel(context: context), journalImage: journalImage)
            }
        }
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
