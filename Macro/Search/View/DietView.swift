//
//  DietView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import SwiftUI

struct DietView: View {
    
    @ObservedObject private var viewModel = DietViewModel()

    var body: some View {
        VStack {
            TextField("", text: $viewModel.input)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: viewModel.input) { newValue in
                    viewModel.autocomplete(viewModel.input)
                }
        }
        List(viewModel.suggestions, id: \.self) { suggestion in
            ZStack {
                Text(suggestion)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .onTapGesture {
                viewModel.input = suggestion
            }
        }
    }
    
}

#Preview {
    DietView()
}
