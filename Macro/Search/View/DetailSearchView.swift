//
//  DetailSearchView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import SwiftUI

struct DetailSearchView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = SearchViewModel()
    
    var name: String
    var journals: [Journal]
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                HStack (spacing: 4) {
                    Image(systemName: "chevron.left")
                        .onTapGesture {
                            dismiss()
                        }
                    Text("Cari")
                }
                
                Spacer()
                Text("Tutup")
                    .onTapGesture {
                        dismiss()
                    }
            }
            .padding(.bottom, 12)
            .foregroundColor(.accentColor)
            
            Text("Detail")
                .bold()
                .font(.largeTitle)
                .padding(.horizontal, 4)
                .padding(.bottom, 30)
            
            Text("NAMA MENU")
                .font(.caption)
                .padding(.horizontal, 16)
            HStack {
                HStack {
                    Text(name)
                        .bold()
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 20)
            
            Text("KANDUNGAN NUTRISI")
                .font(.caption)
                .padding(.horizontal, 16)
            VStack(spacing: 0) {
                HStack {
                    Text("Protein")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text("0 gr")
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Lemak")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(String(viewModel.food?.fat ?? 0) + "gr")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Produk Susu")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(viewModel.food?.dairy ?? true ? "Ada" : "Tidak ada")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Indeks Glisemik")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(giToString(gi: viewModel.food?.glycemicIndex ?? .high))
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            Button(action: {
                viewModel.addDiet(context: context, name: name, entries: journals)
                viewModel.isPresented.toggle()
                dismiss()
            }) {
                Text("Simpan ke Jurnal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    
            }
            
        }
        .padding()
        .background(Color.background)
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .onAppear {
            viewModel.detailDiet(name: name)
        }
    }
    
    private func giToString(gi: glycemicIndex) -> String {
        switch gi {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
}

#Preview {
    DetailSearchView(name: "Abon", journals: [])
}
