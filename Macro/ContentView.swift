//
//  ContentView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 03/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context: ModelContext
    var body: some View {
        
        TabView {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
            
            SkinHealthView(context: context)
                .tabItem {
                    Label("Journal", systemImage: "face.smiling.inverse")
                }
            
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
