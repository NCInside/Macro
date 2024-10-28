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
    
    init() {
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
            .padding(.top, 28)
            
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
                        .sheet(isPresented: $viewModel.isPresented) {
                            if viewModel.selectedSuggestion != nil {
                                DetailSearchView(name: viewModel.selectedSuggestion ?? "", journals: journals)
                            }
                        }
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
                        
                        Button(action: {
                            isAddFoodViewPresented = true
                        }) {
                            Text("Tambah Menu Baru")
                                .foregroundColor(.accentColor)
                                .padding(.top, 2)
                        }
                        
                        
                        
                    }
                    Spacer()
                }
                Spacer()
            } else {
                Spacer()
                
                HStack {
                    Spacer()
                    VStack (alignment: .center){
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 20)
                            .foregroundColor(.gray)
                        
                        Text("Cari menu makanan")
                            .font(.title2)
                            .foregroundColor(.black)
                            .bold()
                    }
                    Spacer()
                }
                Spacer()                           }
        }
        .background(Color.background)
        .sheet(isPresented: $isAddFoodViewPresented) {
            AddFoodView()
            
        }
    }
    
}

#Preview {
    SearchView()
}
