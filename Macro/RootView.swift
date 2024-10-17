//
//  RootView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 16/10/24.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
        
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            PrivacyOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}

#Preview {
    RootView()
}
