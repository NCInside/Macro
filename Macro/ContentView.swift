//
//  ContentView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 03/10/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabView {
//            JournalView()
//                .tabItem {
//                    Label("Journal", systemImage: "book.pages.fill")
//                }
            NotificationView()
            
            SummaryView()
                .tabItem {
                    Label("Ringkasan", systemImage: "book")
                }
        }

    }

}

#Preview {
    ContentView()
}
