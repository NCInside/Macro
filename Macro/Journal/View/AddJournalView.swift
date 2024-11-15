import SwiftUI
import SwiftData

struct AddJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalImageViewModel
    
    @State private var selectedImage: UIImage? = nil
    @State private var isActionSheetPresented = false
    @State private var isImagePickerPresented = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedDate = Date()
    @State private var breakOut = false
    @State private var praMens = false
    @State private var inputNote: String = ""
    
    var body: some View {
        VStack (spacing : 0) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Kesehatan")
                    }
                    .onTapGesture {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Text("Tambah Foto")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 32)
                    
                    Spacer()
                    
                    Button(action: {
                        saveJournalImage()
                    }) {
                        Text("Selesai")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .padding(.leading, 6)
                    }
                }
                .padding(.top, 16)
                .foregroundColor(.accentColor)
                .padding(.horizontal)
                .zIndex(1)
                
                ScrollView {
                // Image Picker Section
                VStack {
                    Button(action: {
                        isActionSheetPresented = true
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(selectedImage == nil ? Color.gray.opacity(0.2) : Color.systemWhite)
                                .frame(width: 240, height: 300)
                                .shadow(radius: selectedImage == nil ? 5 : 0)
                            
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
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    Text(selectedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.systemWhite)
                        .shadow(color: Color.black.opacity(0.8), radius: 8, x: 2, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.systemWhite, lineWidth: 18)
                        )
                )
                .padding(.bottom, 36)
                .padding(.top, 20)
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
                    .padding(.vertical, 6)
                    .background(Color.systemWhite)
                    
                    Divider()
                        .padding(.leading)
                    
                    HStack {
                        Text("Apakah Sedang PMS?")
                            .padding(.leading, 16)
                            
                        Spacer()
                        
                        Toggle("", isOn: $praMens)
                            .labelsHidden()
                            .padding(.trailing, 10)
                    }
                    .padding(.top, 4)
                    .padding(.vertical, 6)
                    .background(Color.systemWhite)
                }
                .padding(.vertical, 8)
                .background(Color.systemWhite)
                .cornerRadius(10)
                
                // Notes Section
                HStack {
                    Text("Catatan Tambahan")
                        .font(.footnote)
                        
                    Spacer()
                }
                .padding(.leading, 10)
                .padding(.top, 10)
                
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
            .background(Color(.background).ignoresSafeArea())
            .frame(maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Selesai") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .background(Color(.background).ignoresSafeArea())
        
    }
    
    // ImagePicker Implementation
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
    
    private func saveJournalImage() {
        let imageData = selectedImage?.jpegData(compressionQuality: 1.0)
        
        viewModel.addJournalImage(
            timestamp: selectedDate,
            image: imageData,
            isBreakout: breakOut,
            isMenstrual: praMens,
            notes: inputNote.isEmpty ? nil : inputNote
        )
        
        dismiss()
    }
}

#Preview{
    ContentView()
}



