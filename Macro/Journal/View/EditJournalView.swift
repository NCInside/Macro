import SwiftUI

struct EditJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalImageViewModel
    var journalImage: JournalImage

    @State private var selectedImage: UIImage? = nil
    @State private var isActionSheetPresented = false
    @State private var isImagePickerPresented = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedDate: Date
    @State private var breakOut: Bool
    @State private var praMens: Bool
    @State private var inputNote: String

    init(viewModel: JournalImageViewModel, journalImage: JournalImage) {
        self.viewModel = viewModel
        self.journalImage = journalImage
        _selectedImage = State(initialValue: journalImage.image.flatMap { UIImage(data: $0) })
        _selectedDate = State(initialValue: journalImage.timestamp)
        _breakOut = State(initialValue: journalImage.isBreakout)
        _praMens = State(initialValue: journalImage.isMenstrual)
        _inputNote = State(initialValue: journalImage.notes ?? "")
    }

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
                    
                    Text("Edit Jurnal")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        updateJournalImage()
                    }) {
                        Text("Selesai")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.leading, 6)
                    }
                }
                .padding(.bottom, 34)
                .foregroundColor(.accentColor)
                
                // Image Picker Section
                VStack {
                    Button(action: {
                        isActionSheetPresented = true
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 240, height: 300)
                                .shadow(radius: 5)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 240, height: 300)
                                    .clipped()
                            } else {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .actionSheet(isPresented: $isActionSheetPresented) {
                        ActionSheet(title: Text("Pilih gambar melalui"), buttons: [
                            .default(Text("🖼 Pilih Foto dari Album")) {
                                imagePickerSource = .photoLibrary
                                isImagePickerPresented = true
                            },
                            .default(Text("📷 Ambil Gambar")) {
                                imagePickerSource = .camera
                                isImagePickerPresented = true
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSource)
                    }
                    
                    Text(selectedDate, style: .date)
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
                
                // Breakout and PMS Toggles
                HStack {
                    Text("Keterangan")
                        .font(.footnote)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    // Breakout Toggle
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Apakah Sedang Breakout?")
                            Text("Kulit iritasi, kemerahan, dan berjerawat")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 6)
                        
                        Toggle("", isOn: $breakOut)
                            .labelsHidden()
                            .padding(.trailing, 10)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                    
                    Divider()
                        .padding(.leading)
                    
                    // PMS Toggle
                    HStack {
                        VStack(alignment: .leading){
                            Text("Apakah Sedang PMS?")
                                .padding(.leading, 10)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Toggle("", isOn: $praMens)
                            .labelsHidden()
                            .padding(.trailing, 10)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 14)
                
                // Notes Section
                HStack {
                    Text("Catatan Tambahan")
                        .font(.footnote)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        TextField("Makanan, minuman, stress", text: $inputNote)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground))
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 14)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .frame(maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var sourceType: UIImagePickerController.SourceType = .photoLibrary
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
                parent.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.dismiss()
            }
        }
    }

    private func updateJournalImage() {
        let imageData = selectedImage?.jpegData(compressionQuality: 1.0)

        viewModel.updateJournalImage(
            journalImage: journalImage,
            newImage: selectedImage,
            isBreakout: breakOut,
            isMenstrual: praMens,
            notes: inputNote.isEmpty ? nil : inputNote
        )

        dismiss()
    }
}
