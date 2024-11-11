//
//  DatePickerWithButtons.swift
//  Macro
//
//  Created by Vebrillia Santoso on 31/10/24.
//
import SwiftUI

struct DatePickerView: View {
    @Binding var showDatePicker: Bool
    @Binding var savedDate: Date?
    @Binding var selectedDate: Date
    
    @State private var selectedDateColor: Color = .black // Default color

    var body: some View {
        ZStack {
            Color.white.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                DatePicker("Pilih Tanggal", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onChange(of: selectedDate) { newDate in
                        selectedDateColor = .main
                        savedDate = newDate
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showDatePicker = false
                        }
                    }
                
                Divider()
                
                
            }
            .background(Color.white.cornerRadius(30))
        }
    }
    
    // Function to format the date as a string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "id_ID") // Set to Indonesian locale
        return formatter.string(from: date)
    }
}



//
//struct DatePickerView_Preview: PreviewProvider {
//    @State static var showDatePicker = true
//    @State static var savedDate: Date? = Date()
//
//    static var previews: some View {
//        DatePickerView(showDatePicker: $showDatePicker, savedDate: $savedDate)
//    }
//}


