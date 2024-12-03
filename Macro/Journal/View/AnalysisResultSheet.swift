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
                        .foregroundColor(Color.systemWhite)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 48)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Analisis Breakout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var kandunganView: some View {
        let topFoods = viewModel.topFoodsBasedOnPeakConsumption()
        let peak = viewModel.peakConsumption
        
        // Construct the paragraph text
        let paragraphContent: [Text] = {
            guard let peak = peak else { return [] }
            var factors: [Text] = []
            
            if topFoods.contains(where: { $0.glycemicIndex >= peak.highestGlycemicIndex }) {
                factors.append(Text("Indeks Glikemik Tinggi").foregroundColor(.red))
            }
            if topFoods.contains(where: { $0.fat >= peak.highestFat }) {
                factors.append(Text("Lemak Jenuh Tinggi").foregroundColor(.red))
            }
            if topFoods.contains(where: { $0.dairies >= peak.highestDairy }) {
                factors.append(Text("Mengandung Susu Tinggi").foregroundColor(.red))
            }
            
            guard !factors.isEmpty else {
                return [Text("Tidak ada kandungan yang signifikan selama seminggu terakhir.")
                            .foregroundColor(.gray)]
            }
            
            // Build paragraph with separators
            let combinedFactors = factors.enumerated().map { index, factor in
                if index == factors.count - 1 && index > 0 {
                    return Text(" dan ") + factor
                } else if index > 0 {
                    return Text(" - ") + factor
                } else {
                    return factor
                }
            }
            
            return [Text("Berdasarkan data Anda, konsumsi makanan yang mengandung ")]
                + combinedFactors
                + [Text(" mungkin adalah penyebab jerawat Anda "), Text("(dengan kondisi tidak ada faktor lain yang mempengaruhi). ").italic().foregroundColor(.gray)]
        }()
        
        return Group {
            if topFoods.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Tidak ada analisis breakout berdasarkan kandungan.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analisis Berdasarkan Kandungan:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Construct the paragraph dynamically with colors
                        paragraphContent.reduce(Text(""), +)
                            .font(.subheadline)
                            .foregroundColor(.black) // Default color
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Text("Berikut makanan yang mungkin perlu Anda kurangi:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // List of foods
                    ForEach(topFoods, id: \.foodName) { food in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(food.foodName)
                                .font(.body)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Display Index Glikemik as Low, Mid, High
                                Text("Indeks Glikemik: \(mapGlycemicIndex(food.glycemicIndex))")
                                    .font(.subheadline)
                                // Rename Fat to Lemak Jenuh
                                Text("Lemak Jenuh: \(String(format: "%.2f", food.fat)) g")
                                    .font(.subheadline)
                                // Rename Dairies to Mengandung Susu and map 0/1 to Tidak/Ya
                                Text("Mengandung Susu: \(mapDairies(food.dairies))")
                                    .font(.subheadline)
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

    // Helper functions to map values
    private func mapGlycemicIndex(_ index: Int) -> String {
        switch index {
        case 0:
            return "Rendah"
        case 1:
            return "Sedang"
        case 2:
            return "Tinggi"
        default:
            return "Tidak Diketahui"
        }
    }

    private func mapDairies(_ value: Int) -> String {
        return value == 1 ? "Ya" : "Tidak"
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
                    Text("Makanan Yang Sering Kamu Makan Sebelum Breakout:")
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
                            
                            
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                    }
                    Text("Pertimbangkan makanan di atas sebagai penyebab jerawat Anda, telusuri lebih lanjut dengan dokter jika diperlukan.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
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
                    Text("Tidak ada data makanan selama 7 hari sebelum breakout.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Makanan Selama 7 Hari Sebelum Dari Breakout:")
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
