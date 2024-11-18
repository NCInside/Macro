//
//  ToastView.swift
//  Macro
//
//  Created by WanSen on 18/10/24.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.systemWhite)
            .padding()
            .background(Color.systemBlack.opacity(0.8))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.5), value: message)
    }
}
