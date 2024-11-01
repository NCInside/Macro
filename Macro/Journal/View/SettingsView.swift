//
//  SettingsView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 31/10/24.
//

import SwiftUI

struct SettingsView: View {
    let age = UserDefaults.standard.string(forKey: "age") ?? "Unknown age"
    @State private var gender: String = UserDefaults.standard.string(forKey: "gender") ?? "Unknown gender"
    @State private var weight: String = UserDefaults.standard.string(forKey: "weight") ?? "Unknown weigth"
    @State private var height: String = UserDefaults.standard.string(forKey: "height") ?? "Unknown heigth"
    @State private var activityLevel: String =  UserDefaults.standard.string(forKey: "activityLevel") ?? "Unknown activity level"
    
    @Environment(\.dismiss) private var dismiss
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    @State private var selectedHeight: String = "cm"
    @State private var selectedWeight: String = "kg"
    @State private var inputName: String = ""
    @State private var inputDayOfBirth: String = ""
    @State private var fatLimit = false
    @State private var dairyLimit = false
    @State private var nutritionReminder = false
    
    let genderOptions = ["Perempuan", "Laki-Laki"]
    let activityOptions = ["Tidak Terlalu Aktif", "Sedikit Aktif", "Aktif", "Sangat Aktif"]
    let heights = (120...250).map { "\($0)" }
    let weights = (30...200).map { "\($0)" }
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                HStack (spacing: 4) {
                    Image(systemName: "chevron.left")
                    
                    Text("Jurnal")
                    
                }.onTapGesture {
                    dismiss()
                }
                
                Spacer()
                Text("Pengaturan")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Selesai")
                        .font(.headline)
                        .foregroundColor(.mainLight)
                        .padding(.leading, 6)
                }
            }
            .padding(.bottom, 12)
            .foregroundColor(.accentColor)
            
            Text("DATA DIRI")
                .font(.caption)
                .padding(.horizontal, 4)
                .padding(.top, 10)
            
            VStack (spacing: 0){
                HStack {
                    Text("Nama")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    TextField("Nama",  text: $inputName)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, -40)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Tanggal Lahir")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    TextField("Tanggal Lahir",  text: $inputDayOfBirth)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, -40)
                    
                }
                .background(Color(UIColor.systemBackground))
                
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            Text("PROFIL TUBUH")
                .font(.caption)
                .padding(.horizontal, 4)
                .padding(.top, 10)
            
            VStack (spacing: 0){
                HStack {
                    Text("Tinggi Badan")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Button(action: {
                        showHeightPicker.toggle()
                    }) {
                        Text(height)
                            .foregroundColor(.mainLight)
                            .frame(width: 40)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Picker("Unit", selection: $selectedHeight) {
                        Text("cm").tag("cm")
                        Text("ft").tag("ft")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 100)
                    .padding(.trailing, 10)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                if showHeightPicker {
                    Picker("Pilih Tinggi", selection: $height) {
                        ForEach(heights, id: \.self) { height in
                            Text(height).tag(height)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .onChange(of: height) { newHeight in
                        UserDefaults.standard.set(newHeight, forKey: "height")
                    }
                }
                
                HStack {
                    Text("Berat Badan")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Button(action: {
                        showWeightPicker.toggle()
                    }) {
                        Text(weight)
                            .foregroundColor(.mainLight)
                            .frame(width: 40)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Picker("Unit", selection: $selectedWeight) {
                        Text("kg").tag("kg")
                        Text("lb").tag("lb")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 100)
                    .padding(.trailing, 10)
                    
                }
                Divider()
                    .padding(.leading)
                    .background(Color(UIColor.systemBackground))
                
                if showWeightPicker {
                    Picker("Pilih Tinggi", selection: $weight) {
                        ForEach(weights, id: \.self) { weight in
                            Text(weight).tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .onChange(of: weight) { newWeight in
                        UserDefaults.standard.set(newWeight, forKey: "weight")
                    }
                }
                
                HStack{
                    Text("Jenis Kelamin")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Picker("", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                        }
                    }
                    .accentColor(.gray)
                    .onChange(of: gender) { newGender in
                        UserDefaults.standard.set(newGender, forKey: "gender")
                    }
                }
                
                HStack{
                    Text("Aktivitas")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Picker("", selection: $activityLevel) {
                        ForEach(activityOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                        }
                    }
                    .accentColor(.gray)
                    .onChange(of: activityLevel) { newActivityLevel in
                        UserDefaults.standard.set(newActivityLevel, forKey: "activityLevel")
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 10)
            
            Text("NOTIFIKASI")
                .font(.caption)
                .padding(.horizontal, 4)
                .padding(.top, 10)
            
            
            VStack (spacing: 0){
                HStack {
                    VStack(alignment: .leading){
                        Text("Diatas Lemak Jenuh")
                        Text("Jika melewati rekomendasi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, -40)
                    
                    Toggle("", isOn: $fatLimit)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    VStack(alignment: .leading){
                        Text("Batas Produk Susu")
                        Text("Jika melebihi 1 porsi per hari")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, -48)
                    
                    Toggle("", isOn: $dairyLimit)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    VStack(alignment: .leading){
                        Text("Pengingat Pengisian Nutrisi")
                        Text("Diingatkan setiap jam 19.00")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, -66)
                    
                    Toggle("", isOn: $nutritionReminder)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 14)
            
            Spacer()
        }
        .padding()
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .background(Color.background)
    }
    
}

#Preview {
    SettingsView()
}
