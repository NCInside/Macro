//
//  ContentView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 03/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationSplitView {
        } detail: {
            Text("Select an item")
                
        }
    }

}

#Preview {
    ContentView()
}
