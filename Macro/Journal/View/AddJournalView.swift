//
//  AddJournalView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 07/11/24.
//
import SwiftUI

struct AddJournalView : View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedDate = Date()
    @State private var breakOut = false
    @State private var praMens = false
    @State private var inputNote: String = ""
    
    var body: some View {
        VStack {
            HStack {
                HStack (spacing: 4) {
                    Image(systemName: "chevron.left")
                    
                    Text("Kesehatan")
                    
                }.onTapGesture {
                    dismiss()
                }
                
                Spacer()
                Text("Pengaturan")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.leading, -24)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Selesai")
                        .font(.headline)
                        .foregroundColor(.mainLight)
                        .padding(.leading, 6)
                }
            }
            .padding(.bottom, 34)
            .foregroundColor(.accentColor)
            
            VStack {
                Button(action: {
                    isImagePickerPresented.toggle()
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
                                .frame(width: 180, height: 280)
                        } else {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                        
                        
                    }
                    
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
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
            
            HStack {
                Text("Keterangan")
                    .font(.footnote)
                    .padding(.leading, 10)
                
                Spacer()
            }
            
            VStack (spacing: 0){
                HStack {
                    VStack(alignment: .leading){
                        Text("Apakah Sedang Breakout?")
                        Text("Kulit iritasi, kemerahan, dan berjerawat")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, -40)
                    .padding(.leading, 6)
                    
                    Toggle("", isOn: $breakOut)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    VStack(alignment: .leading){
                        Text("Apakah Sedang PMS?")
                            .padding(.leading, 10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Toggle("", isOn: $praMens)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            HStack {
                Text("Catatan Tambahan")
                    .font(.footnote)
                    .padding(.leading, 10)
                
                Spacer()
            }
            
            VStack (spacing: 0){
                HStack {
                    TextField("Makanan, minuman, stress", text: $inputNote)
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            Spacer()
            
        }
        .padding()
        .background(Color.background)
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
        
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
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
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AddJournalView()
}
