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

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let height = HKObjectType.quantityType(forIdentifier: .height)
        
        guard let sleep = sleepType, let birthDate = dateOfBirth, let sex = biologicalSex, let mass = bodyMass, let heightType = height else {
            print("HealthKit data is not available.")
            completion(false)
            return
        }
        
        let healthTypes: Set = [sleep, birthDate, sex, mass, heightType]
        
        healthStore.requestAuthorization(toShare: [], read: healthTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting health data authorization: \(error.localizedDescription)")
                    completion(false)
                } else {
                    if success {
                        let statuses = healthTypes.map { self.healthStore.authorizationStatus(for: $0) }
                        let allAuthorized = statuses.allSatisfy { $0 == .sharingAuthorized }
                        if allAuthorized {
                            print("User granted access to all requested HealthKit data.")
                            UserDefaults.standard.set(self.getUserAge(), forKey: "age")
                            UserDefaults.standard.set(self.getUserBiologicalSex(), forKey: "gender")
                            completion(true)
                        } else {
                            print("User denied access to some HealthKit data.")
                            completion(false)
                        }
                    } else {
                        print("User denied access to HealthKit data.")
                    }
                    completion(success)
                }
            }
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
}
