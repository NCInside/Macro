//
//  AddSleepView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI

struct AddSleepView: View {
    @ObservedObject var viewModel = AddSleepViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button("Batalkan") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Selesai") {
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            ZStack{
                Rectangle()
                    .foregroundColor(.background)
                    .frame(width: 360, height: 560)
                    .cornerRadius(12)
                
                VStack{
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("WAKTU TIDUR")
                                    .foregroundColor(.black)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                
                            } icon: {
                                Image(systemName: "bed.double.fill")
                                    .foregroundColor(Color.main)
                            }
                            .font(.callout)
                            
                            HStack {
                                Spacer()
                                Text(viewModel.getTime(angle: viewModel.startAngle).formatted(.dateTime.hour().minute()))
                                    .font(.largeTitle.bold())
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("WAKTU BANGUN")
                                    .foregroundColor(.black)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            } icon: {
                                Image(systemName: "alarm.waves.left.and.right.fill")
                                    .foregroundColor(Color.main)
                            }
                            .font(.callout)
                            
                            HStack {
                                Spacer()
                                Text(viewModel.getTime(angle: viewModel.toAngle).formatted(.dateTime.hour().minute()))
                                    .font(.largeTitle.bold())
                                Spacer()
                            }
                            
                            
                        }
                        .padding(.leading, -10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    
                    SleepTimeSlider()
                        .padding(.top, 20)
                    
                    Text("\(viewModel.getTimeDifference().0) jam \(viewModel.getTimeDifference().1) menit")
                        .font(.title.bold())
                        .padding(.top, 40)
                    
                    Text("Total Tidur")
                    
                }
                
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
    
    @ViewBuilder
    func SleepTimeSlider() -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            
            ZStack {
                ZStack {
                    ForEach(1...60, id: \.self) { index in
                        Rectangle()
                            .fill(index % 5 == 0 ? .black : .gray)
                            .frame(width: 2, height: index % 5 == 0 ? 10 : 5)
                            .offset(y: (width - 60) / 2)
                            .rotationEffect(.init(degrees: Double(index) * 6))
                    }
                    let texts = [12, 14, 16, 18, 20, 22,0, 2, 4, 6, 8, 10, ]
                    ForEach(texts.indices, id: \.self) { index in
                        Text("\(texts[index])")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .rotationEffect(.init(degrees: Double(index) * -30))
                            .offset(y: (width - 90) / 2)
                            .rotationEffect(.init(degrees: Double(index) * 30))
                    }
                    
                    Image(systemName: "sun.max.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .offset(y: (width - 130) / 2)
                    
                    
                    Image(systemName: "moon.fill")
                        .font(.callout)
                        .foregroundColor(.black)
                        .offset(y: -(width - 130) / 2)
                    
                }
                
                Circle()
                    .stroke(.black.opacity(0.06), lineWidth: 40)
                
                let reverseRotation = (viewModel.startProgress > viewModel.toProgress) ? -Double((1 - viewModel.startProgress) * 360) : 0
                Circle()
                    .trim(from: viewModel.startProgress > viewModel.toProgress ? 0 : viewModel.startProgress, to: viewModel.toProgress + (-reverseRotation / 360))
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
                    .rotationEffect(.init(degrees: reverseRotation))
                
                Image(systemName: "bed.double.fill")
                    .font(.callout)
                    .foregroundColor(.main)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -viewModel.startAngle))
                    .background(.white, in: Circle())
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: viewModel.startAngle))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.onDrag(value: value, fromSlider: true)
                            }
                    )
                    .rotationEffect(.init(degrees: -90))
                
                Image(systemName: "sunrise.fill")
                    .font(.callout)
                    .foregroundColor(.main)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -viewModel.toAngle))
                    .background(.white, in: Circle())
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: viewModel.toAngle))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.onDrag(value: value)
                            }
                    )
                    .rotationEffect(.init(degrees: -90))
                
                
            }
            
            
        }
        .frame(width: screenBounds().width / 1.6, height: screenBounds().width / 1.6)
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        AddSleepView()
    }
}

extension View {
    func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
