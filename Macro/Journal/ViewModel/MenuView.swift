//
//  MenuView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//
import SwiftUI
import SwiftData

struct MenuView: View {
    
    @ObservedObject private var viewModel = JournalViewModel()
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query var journals: [Journal]
    
    var image: UIImage?
    var title: String
    var prob: Double
    var protein: Double
    var fat: Double
    var dairy: Bool
    var glycemicIndex: Int  // Change this to Int, as the enum is handled inside

    var body: some View {
        VStack {
            if let image = image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360, height: 300)
                        .cornerRadius(12)
                    
                    HStack {
                        Text(viewModel.parseFoodName(food: title))  // Display the name of the food
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(width: 360)
                    
                    // Display the nutritional information passed from JournalView
                    VStack {
                        HStack {
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.trailing, 10)
                                
                                VStack(alignment: .leading) {  // Use VStack to stack the texts vertically
                                    Text("Protein")  // Label
                                        .fontWeight(.medium)
                                    
                                    Text("\(protein, specifier: "%.2f")g")  // Result below the label
                                        .font(.body)
                                        .fontWeight(.regular)
                                }
                                .padding()
                            }

                            
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading) {  // Use VStack to stack the texts vertically
                                    Text("Dairy")  // Label
                                        .fontWeight(.medium)
                                    
                                    Text("\(dairy ? "Yes" : "No")")  // Result below the label
                                        .font(.body)
                                        .fontWeight(.regular)
                                }
                                .padding()
                                
                            }
                        }
//                        TEST
                        HStack {
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.trailing, 10)
                                
                                VStack(alignment: .leading) {  // Use VStack to stack the texts vertically
                                    Text("Fat")  // Label
                                        .fontWeight(.medium)
                                    
                                    Text("\(fat, specifier: "%.2f")g")  // Result below the label
                                        .font(.body)
                                        .fontWeight(.regular)
                                }
                                .padding()
                                
                            }
                            
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading) {
                                    Text("Glycemic Index")
                                        .fontWeight(.medium)
                                    
                                    if let glycemicEnum = GlycemicLevel(rawValue: glycemicIndex) {  // Convert Int to GlycemicLevel enum
                                        Text(glycemicEnum.rawValue)  // Display 'Low', 'Mid', or 'High' based on the enum value
                                            .font(.body)
                                            .fontWeight(.regular)
                                    } else {
                                        Text("Unknown")  // Handle any unexpected values
                                            .font(.body)
                                            .fontWeight(.regular)
                                    }
                                }
                                .padding()
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            } else {
                Text("No Image Selected")
                    .font(.title)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
        
        // Submit Button (non-functional for now)
        Button(action: {
            viewModel.addDiet(context: context, name: viewModel.parseFoodName(food: title), entries: journals)
            dismiss()
        }) {
            ZStack{
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: 353, height: 50)
                    .background(.white)
                    .cornerRadius(12)
                Text("Submit")
                    .foregroundColor(.white)
                    .bold()
                    .font(.title2)
                
            }
                
        }
        .padding(.top, 20)
    }
    
    enum GlycemicLevel: String {
        case low = "Low"
        case mid = "Mid"
        case high = "High"
        
        // Custom initializer to convert from Int to GlycemicLevel
        init?(rawValue: Int) {
            switch rawValue {
            case 0:
                self = .low
            case 1:
                self = .mid
            case 2:
                self = .high
            default:
                return nil
            }
        }
    }
}

#Preview {
    MenuView(
        image: UIImage(named: "exampleImage"),
        title: "Example Title",
        prob: 0.85,
        protein: 12.5,
        fat: 8.0,
        dairy: true,
        glycemicIndex: 0  // Use Int here, e.g., 0, 1, or 2
    )
}

