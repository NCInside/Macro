//
//  AddSleepCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 25/10/24.
//

import SwiftUI

struct AddSleepCard: View {
    @State var startDate = Date()
    @State var endDate = Date()
    @State var showStartPicker = false
    @State var showEndPicker = false
    
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
                    }
                }) {
                    HStack {
                        Text("\(startDate, formatter: dateFormatter)")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    HStack {
                        Text("\(startDate, formatter: timeFormatter)")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 40)
                    .background(Color.white)
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
                    }
                }) {
                    HStack {
                        Text("\(endDate, formatter: dateFormatter)")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    HStack {
                        Text("\(endDate, formatter: timeFormatter)")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                }
                
                
            }
            
            if showEndPicker {
                DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            }
            
        }
        .frame(width: 360)
        .background(Color.white)
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
