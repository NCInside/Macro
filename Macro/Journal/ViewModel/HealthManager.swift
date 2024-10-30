//
//  HealthManager.swift
//  Macro
//
//  Created by Vebrillia Santoso on 08/10/24.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, [String: Bool]) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let height = HKObjectType.quantityType(forIdentifier: .height)
        
        guard let sleep = sleepType, let birthDate = dateOfBirth, let sex = biologicalSex, let mass = bodyMass, let heightType = height else {
            print("HealthKit data is not available.")
            completion(false, ["HealthKitDataUnavailable": true])
            return
        }
        
        let healthTypes: Set = [sleep, birthDate, sex, mass, heightType]
        
        healthStore.requestAuthorization(toShare: [], read: healthTypes) { success, error in
            DispatchQueue.main.async {
                var navigationStates: [String: Bool] = [
                    "NameOnBoarding": true,
                    "AgeOnBoarding": true,
                    "HeightOnBoarding": true,
                    "WeightOnBoarding": true,
                    "GenderOnBoarding": true,
                    "ActivityOnBoarding": true,
                    "showAlert": true
                ]
                
                if let error = error {
                    print("Error requesting health data authorization: \(error.localizedDescription)")
                    completion(false, navigationStates)
                    return
                }
                
                if success {
                    // Check if name is available in UserDefaults
                    if let userName = UserDefaults.standard.string(forKey: "Name"), !userName.isEmpty {
                        print("Name data found: \(userName)")
                        navigationStates["NameOnBoarding"] = false
                    } else {
                        print("No name data available.")
                    }

                    // Check for other data availability
                    if let age = self.getUserAge() {
                        print("Age data found: \(age)")
                        navigationStates["AgeOnBoarding"] = false
                    } else {
                        print("No age data available.")
                    }
                    
                    if self.getUserBiologicalSex() != nil {
                        navigationStates["GenderOnBoarding"] = false
                    }
                    
                    self.getUserWeight { bodyMass in
                        if bodyMass != nil {
                            navigationStates["WeightOnBoarding"] = false
                        }
                        self.getUserHeight { height in
                            if height != nil {
                                navigationStates["HeightOnBoarding"] = false
                            }
                            self.fetchSleepDataForLast7Days { sleepData, count in
                                if count != 0 {
                                    navigationStates["showAlert"] = false
                                }
                                self.finalizeNavigation(navigationStates, completion)
                            }
                        }
                    }
                } else {
                    print("User denied access to HealthKit data.")
                    completion(false, navigationStates)
                }
            }
        }
    }


    private func finalizeNavigation(_ navigationStates: [String: Bool], _ completion: @escaping (Bool, [String: Bool]) -> Void) {
        DispatchQueue.main.async {
            completion(!navigationStates.contains(where: { $0.value }), navigationStates)
        }
    }

    
    
    func fetchSleepData(completion: @escaping ([HKCategorySample]?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep type is no longer available in HealthKit.")
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 10, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, result, error in
            guard let result = result as? [HKCategorySample], error == nil else {
                completion(nil)
                return
            }
            completion(result)
        }
        
        healthStore.execute(query)
    }
    
    func getUserAge() -> Int? {
        do {
            let dateOfBirth = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let age = currentYear - dateOfBirth.year!
            print("\(age)")
            return age
            
        } catch {
            print("Error fetching date of birth: \(error)")
            return nil
        }
    }
    
    func getUserBiologicalSex() -> Bool? {
        do {
            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            switch biologicalSex {
            case .female:
                return false
            case .male:
                return true
            case .other:
                return false
            case .notSet:
                return nil
            @unknown default:
                return nil
            }
        } catch {
            print("Error fetching biological sex: \(error)")
            return nil
        }
    }
    
    func getUserHeight(completion: @escaping (Double?) -> Void) {
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, result, error in
            guard let sample = result?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let height = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            completion(height)
        }
        healthStore.execute(query)
    }
    
    func getUserWeight(completion: @escaping (Double?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, result, error in
            guard let sample = result?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weight)
        }
        healthStore.execute(query)
    }
    
    func fetchSleepDataForLast7Days(completion: @escaping ([HKCategorySample]?, Int) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep type is no longer available in HealthKit.")
            return
        }
        
        let now = Date()
        let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, result, error in
            guard let result = result as? [HKCategorySample], error == nil else {
                completion(nil, 0)
                return
            }
            completion(result, result.count)
        }
        
        healthStore.execute(query)
    }
    
    
}
