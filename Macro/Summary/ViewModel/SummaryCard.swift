//
//  SummaryCard.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import SwiftUI

struct SummaryCard<DetailView: View>: View {
    
    var title: String
    var caption: String
    var detail: DetailView
    var showChevron: Bool = true
    var icon: String?
    var iconSize: CGSize = CGSize(width: 24, height: 24)
    var iconPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                if showChevron {
                    Image(systemName: "chevron.right")
                        .onTapGesture {
                            //
                        }
                }
            }
            .padding(.bottom, 24)
            HStack {
                VStack {
                    HStack {
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    HStack {
                        detail
                        Spacer()
                    }
                    
                    
                }
                Spacer()
                VStack {
                    if let icon = icon {
                        Text("")
                            .background(
                                Image(icon)
                                    .resizable()
                                    .frame(width: iconSize.width, height: iconSize.height)
                                    .padding(iconPadding),
                                alignment: .bottomTrailing)
                    }
                }
            }
        }
        //        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding()
        .background(.white)
    }
}

#Preview {
    //    SummaryCard(
    //        title: "Tidur",
    //        caption: "Rerata waktu terlelap",
    //        detail: HStack (alignment: .bottom,spacing: 0) {
    //            Text("75")
    //                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
    //                .bold()
    //            Text("gram")
    //                .font(.caption2)
    //        },
    //        icon: "Sleep")
    SummaryView()
}
