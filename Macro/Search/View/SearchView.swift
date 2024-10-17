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
                Text("Search Menu")
                    .bold()
                    .padding(.bottom, 0)
                    .padding(.leading, 106)
            }
            .padding(.horizontal)

            VStack {
                CustomSearchBar(text: $viewModel.input)
                    .onChange(of: viewModel.input) {
                        viewModel.autocomplete(viewModel.input)
                    }
                if (viewModel.suggestions.isEmpty) {
                    VStack {
                        HStack {
                            Text("Recently added")
                            Spacer()
                            Text("Clear")
                                .bold()
                                .onTapGesture {
                                    viewModel.clearRecent()
                                }
                        }
                        Divider()
                    }
                    .padding(.horizontal)
                }
            }

            List {
                ForEach((viewModel.suggestions.isEmpty ? viewModel.recent : viewModel.suggestions).reversed(), id: \.self) { suggestion in
                    SearchCard(suggestion: suggestion, onTap: {
                        viewModel.selectedSuggestion = suggestion
                        viewModel.isPresented.toggle()
                    })
                    .fullScreenCover(isPresented: $viewModel.isPresented) {
                        if viewModel.selectedSuggestion != nil {
                            DetailSearchView(name: viewModel.selectedSuggestion ?? "", journals: journals)
                       }
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(.gray)
    }
    
}

#Preview {
    SearchView()
}
