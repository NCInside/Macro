//
//  AddSleepCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 25/10/24.
//

import SwiftUI

struct AddSleepCard: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var showStartPicker: Bool
    @Binding var showEndPicker: Bool
    
    var body: some View {
        
        VStack{
            HStack {
                Text("Mulai")
                    .font(.headline)
                    .padding(.leading, 12)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showStartPicker.toggle()
                        if showStartPicker {
                            showEndPicker = false
                        }
                    }
                }) {
                    HStack {
                        Text("\(startDate, formatter: dateFormatter)")
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 120, height: 40)
                    .background(Color.systemWhite)
                    .cornerRadius(10)
                    
                    HStack {
                        Text("\(startDate, formatter: timeFormatter)")
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 80, height: 40)
                    .background(Color.systemWhite)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                }
                
                
            }
            
            if showStartPicker {
                DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: startDate) { newStartDate in
                        if endDate < newStartDate {
                            endDate = newStartDate
                        }
                    }
            }
            
            HStack {
                Text("Berakhir")
                    .font(.headline)
                    .padding(.leading, 12)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showEndPicker.toggle()
                        if showEndPicker {
                            showStartPicker = false
                        }
                    }
                }) {
                    HStack {
                        Text("\(endDate, formatter: dateFormatter)")
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 120, height: 40)
                    .background(Color.systemWhite)
                    .cornerRadius(10)
                    
                    HStack {
                        Text("\(endDate, formatter: timeFormatter)")
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 80, height: 40)
                    .background(Color.systemWhite)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                }
                
                
            }
            
            if showEndPicker {
                           DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                               .datePickerStyle(WheelDatePickerStyle())
                               .labelsHidden()
                       }
            
        }
        .frame(width: 360)
        .background(Color.systemWhite)
        .cornerRadius(10)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
