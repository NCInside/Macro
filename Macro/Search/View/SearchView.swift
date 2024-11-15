//
//  SearchView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 14/10/24.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    @ObservedObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @Query private var journals: [Journal]
    @State var isAddFoodViewPresented = false
    @State var showingAlert = false
    
    var date: Date
    
    @Binding var isDetailViewPresented: Bool
    
    init(isDetailViewPresented: Binding<Bool>, date: Date) {
        self.date = date
        self._isDetailViewPresented = isDetailViewPresented
        if viewModel.defaults.object(forKey: "recent") == nil {
            viewModel.defaults.set([], forKey: "recent")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .onTapGesture {
                        dismiss()
                    }
                    .foregroundColor(.accentColor)
                
                Text("Search Menu")
                    .bold()
                    .padding(.bottom, 0)
                    .padding(.leading, 106)
                
                Spacer()
                
                Button(action: {
                    isAddFoodViewPresented = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
                
            }
            .padding(.horizontal)
            
            VStack {
                CustomSearchBar(text: $viewModel.input)
                    .onChange(of: viewModel.input) {
                        viewModel.autocomplete(viewModel.input)
                    }
                    .padding(.horizontal, 4)
                
                if viewModel.suggestions.isEmpty && viewModel.input.isEmpty {
                    VStack {
                        HStack {
                            Text("Baru Ditambahkan")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Hapus")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    viewModel.clearRecent()
                                }
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .padding(.top) // Add some space after the search bar
            
            // Content: List of Suggestions or "No Results Found"
            if !viewModel.suggestions.isEmpty {
                // Show list of suggestions
                List {
                    ForEach(viewModel.suggestions.reversed(), id: \.self) { suggestion in
                        SearchCard(suggestion: suggestion, onTap: {
                            viewModel.selectedSuggestion = suggestion
                            viewModel.isPresented.toggle()
                        })
                        .frame(height: 40)
                    }
                }
                .listStyle(.plain)
            } else if !viewModel.input.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        Text("Tidak ada hasil untuk \"\(viewModel.input)\"")
                            .font(.title2)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .bold()
                        
                        Text("Periksa ejaan atau coba pencarian baru")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                    }
                    Spacer()
                }
                Spacer()
            } else {
                List {
                    ForEach(viewModel.recent.reversed(), id: \.self) { suggestion in
                        SearchCard(suggestion: suggestion, onTap: {
                            viewModel.selectedSuggestion = suggestion
                            viewModel.isPresented.toggle()
                        })
                        .frame(height: 40)
                    }
                }
                .listStyle(.plain)
                .padding(.vertical)
            }
        }
        .padding(.top, 24)
        .background(Color.background)
        .fullScreenCover(isPresented: $viewModel.isPresented) {
            if viewModel.selectedSuggestion != nil {
                DetailSearchView(date: date, isDetailViewPresented: $isDetailViewPresented, name: viewModel.selectedSuggestion ?? "", journals: journals)
            }
        }
        .sheet(isPresented: $isAddFoodViewPresented) {
            AddFoodView(showingAlert: $showingAlert)
            
        }
        .alert("Makanan Baru Tersimpan", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
}

//#Preview {
//    SearchView()
//}
