import SwiftUI

struct AnalysisResultSheet: View {
    @ObservedObject var viewModel: JournalImageViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedView: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedView) {
                    Text("Kandungan").tag(0)
                    Text("Frekuensi").tag(1)
                    Text("7 Hari Terakhir").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    Group {
                        if selectedView == 0 {
                            kandunganView
                        } else if selectedView == 1 {
                            frekuensiView
                        } else if selectedView == 2 {
                            makanan7HariView
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Tutup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Analisa Breakout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var kandunganView: some View {
        let topFoods = viewModel.topFoodsBasedOnPeakConsumption()
        let peak = viewModel.peakConsumption
        
        return Group {
            if topFoods.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Tidak ada analisa breakout berdasarkan kandungan.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analisa Berdasarkan Kandungan:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if let peak = peak {
                        // Cek apakah ada kandungan yang perlu diperhatikan
                        let hasHighGlycemicIndex = topFoods.contains { $0.glycemicIndex >= peak.highestGlycemicIndex }
                        let hasHighFat = topFoods.contains { $0.fat >= peak.highestFat }
                        let hasHighDairies = topFoods.contains { $0.dairies >= peak.highestDairy }
                        
                        if hasHighGlycemicIndex || hasHighFat || hasHighDairies {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Berdasarkan data Anda, berikut adalah kandungan yang mungkin perlu diperhatikan:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if hasHighGlycemicIndex {
                                    Text("• Glycemic Index tinggi.")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                if hasHighFat {
                                    Text("• Kandungan Fat yang signifikan.")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                if hasHighDairies {
                                    Text("• Kandungan Dairies yang tinggi.")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    Text("Berikut makanan yang mungkin perlu Anda kurangi:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Daftar makanan
                    ForEach(topFoods, id: \.foodName) { food in
                        VStack(alignment: .leading, spacing: 8) {
                            // Teks utama makanan
                            HStack(alignment: .top) {
                                Text(food.foodName)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                            }
                            
                            // Detail kandungan
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Glycemic Index: \(food.glycemicIndex)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                                Text("Fat: \(String(format: "%.2f", food.fat)) g")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                                Text("Dairies: \(food.dairies)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                    }
                    
                    Text("Pertimbangkan untuk mengurangi konsumsi makanan di atas untuk membantu mencegah breakout.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
    }
    
    private var frekuensiView: some View {
        let frequentFoods = viewModel.frequentFoodsForBreakouts()
        return Group {
            if frequentFoods.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Tidak ada makanan yang memiliki frekuensi tinggi selama breakout.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Makanan Yang Biasanya Ada Ketika Breakout Selama 7 Hari Terakhir:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    ForEach(frequentFoods, id: \.foodName) { food in
                        VStack(alignment: .leading, spacing: 8) {
                            // Teks utama makanan
                            HStack(alignment: .top) {
                                Text(food.foodName)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                            }
                            
                            // Detail frekuensi
                            Text("Frekuensi: \(String(format: "%.2f", food.frequency))%")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                    }
                }
                .padding()
            }
        }
    }
    
    private var makanan7HariView: some View {
        let recentFoods = viewModel.fetchFoodsByDayForLast7DaysFromBreakout()
        return Group {
            if recentFoods.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Tidak ada data makanan selama 7 hari terakhir dari breakout.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Makanan Selama 7 Hari Terakhir dari Breakout:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    ForEach(recentFoods, id: \.date) { data in
                        VStack(alignment: .leading, spacing: 8) {
                            // Tanggal
                            Text("Tanggal: \(data.date, formatter: viewModel.dateFormatter)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                            
                            // Daftar makanan
                            ForEach(data.foodNames, id: \.self) { foodName in
                                Text("- \(foodName)")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Rata kiri
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                    }
                }
                .padding()
            }
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
