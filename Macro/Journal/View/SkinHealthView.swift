//
//  SkinHealthView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 07/11/24.
//

import SwiftUI

struct SkinHealthView: View {
    @State private var selectedDate = Date()
    @State var isAddJournalViewPresented = false
    
    let normalDays: [Int] = [1, 2, 3, 5]
    let breakoutDays: [Int] = [4]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Kesehatan Kulit")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    isAddJournalViewPresented = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .bold()
                }
                .sheet(isPresented: $isAddJournalViewPresented) {
                    AddJournalView()
                }
            }
            .padding(.bottom, 10)
            
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                
                //                .overlay(calendarOverlay)
                
                Divider()
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Normal")
                    
                    Triangle()
                        .fill(Color.yellow)
                        .frame(width: 10, height: 10)
                    Text("Breakout")
                }
                .padding(.vertical, 16)
            }
            .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                )
            
            Button(action: {
                
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(width: 372, height: 50)
                        .background(.white)
                        .cornerRadius(12)
                    Text("Riwayat")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding()
    }
    
//    private var calendarOverlay: some View {
//        GeometryReader { geometry in
//            let cellSize = geometry.size.width / 7
//            VStack {
//                ForEach(1..<32, id: \.self) { day in
//                    let dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
//                    let date = Calendar.current.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: day))
//                    
//                    if let date = date,
//                       Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
//                        let dayOfWeek = Calendar.current.component(.weekday, from: date)
//                        let row = (day + dayOfWeek - 2) / 7
//                        let column = (dayOfWeek - 1) % 7
//                        
//                        // Position each marker precisely within each cell
//                        Group {
//                            if normalDays.contains(day) {
//                                Circle()
//                                    .fill(Color.green)
//                                    .frame(width: 8, height: 8)
//                                    .position(x: cellSize * CGFloat(column) + cellSize / 2, y: cellSize * CGFloat(row) + cellSize * 0.7)
//                            } else if breakoutDays.contains(day) {
//                                Triangle()
//                                    .fill(Color.yellow)
//                                    .frame(width: 10, height: 10)
//                                    .position(x: cellSize * CGFloat(column) + cellSize / 2, y: cellSize * CGFloat(row) + cellSize * 0.7)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SkinHealthView()
    }
}
