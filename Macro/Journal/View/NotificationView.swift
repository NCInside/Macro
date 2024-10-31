//
//  NotificationView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 25/10/24.
//

import SwiftUI

struct NotificationView: View {
    @State private var selectedDate = Date()
    let notify = NotificationViewModel()
    
    var body: some View {
        VStack(spacing : 20){
            Spacer()
            Button("Kirimkan notifikasi dalam 6 detik") {
                notify.sendNotification(
                    date: Date(),
                    type: "time",
                    timeInterval: 6,
                    title: "Zora",
                    body: "Jangan lupa untuk isi jurnalmu!")
            }
            
            DatePicker("Pilih Tanggal:", selection: $selectedDate, in: Date()...)
            Button("Jadwalkan Notifikasi") {
                notify.sendNotification(
                    date: selectedDate,
                    type: "date",
                    title: "Zora",
                    body: "Jangan lupa untuk isi jurnalmu!")
            }
            Spacer()
            
            Text("Not working?")
                .foregroundColor(.gray)
                .italic()
            
            Button("Request Permission") {
                notify.askPermission()
            }
        }
    }
}
#Preview {
    NotificationView()
}
