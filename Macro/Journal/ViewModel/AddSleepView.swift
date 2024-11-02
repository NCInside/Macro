//
//  AddSleepView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

struct AddSleepView: View {
    @State private var isHeartDataFetched = false
    @ObservedObject var viewModel = AddSleepViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @Query var journals: [Journal]
    @State private var showAlert = false
    @State private var showAddSleepCard = false
    
    var body: some View {
        VStack {
            HStack {
                Button("Batalkan") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mainLight)
                Spacer()
                Text("TIDUR")
                    .bold()
                Spacer()
                
                Button("Tambah") {
                    viewModel.addSleep(context: context, journals: journals)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mainLight)
                .bold()
            }
            .padding()
            
            Button(action: {
                showAlert = true
            }) {
                HStack{
                    Image("HealthIcon")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.systemGray4, lineWidth: 1)
                        )
                        .padding(.leading, 14)
                    
                    Text("Ambil Data Tidur")
                        .foregroundColor(Color.accentColor)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .frame(width: 360, height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom, 10)
            }
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Hubungkan ke Kesehatan"),
                    message: Text("Untuk aktivasi data tidur di Zora, buka Pengaturan di perangkat Anda → Aplikasi → Kesehatan → Akses Data & Perangkat → Zora → Nyalakan semua.")
                )
            }
            
            
            AddSleepCard()
            
            Button(action: {
                withAnimation {
                    showAddSleepCard.toggle()
                }
            }) {
                HStack{
                    Image(systemName: "plus")
                        .padding(.leading, 8)
                    
                    Text("Tambah Tidur")
                        .foregroundColor(Color.accentColor)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
            }
            if showAddSleepCard {
                            AddSleepCard()
//
                        }
        }
        
        
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
}

struct SleepInputView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView()
    }
}

extension View {
    func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
