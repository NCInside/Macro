//
//  SummaryView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                HStack {
                    Text("Ringkasan")
                        .bold()
                        .font(.largeTitle)
                    Spacer()
                }
                
                ScrollView {
                    VStack {
                        NavigationLink(destination: DetailSummaryView()) {
                            SummaryCard(
                                title: "Tidur",
                                caption: "Rerata waktu terlelap",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text("6")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("jam")
                                        .font(.caption2)
                                    Text("47")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("menit")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView()) {
                            SummaryCard(
                                title: "Protein",
                                caption: "Rerata konsumsi protein",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text("75")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("gram")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView()) {
                            SummaryCard(
                                title: "Lemak",
                                caption: "Rerata konsumsi lemak",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text("75")
                                        .font(.title)
                                        .bold()
                                    Text("gram")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView()) {
                            SummaryCard(
                                title: "Produk Susu",
                                caption: "Frekuensi",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text("10")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("x")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView()) {
                            SummaryCard(
                                title: "Indeks Glikemik",
                                caption: "Rerata indeks",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text("Tinggi")
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .padding(.horizontal)
            .background(.gray)
        }
    }
}

#Preview {
    SummaryView()
}
