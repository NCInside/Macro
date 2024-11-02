//
//  SleepDetailHistoryView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 16/10/24.
//

import SwiftUI

struct SleepDetailHistoryView: View {
    
    var sleep: Sleep
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text(parseSleepDuration(sleep: sleep))
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                }
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.background)
        .navigationTitle("Sleep")
    }
    
    private func parseSleepDuration(sleep: Sleep) -> String {
        let hour: Int = sleep.duration / 3600
        let minut: Int = (sleep.duration % 3600) / 60
        
        return "\(hour)hrs \(minut)min"
    }
    
}
