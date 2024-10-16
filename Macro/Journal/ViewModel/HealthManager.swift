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
            print("Data HealthKit tidak tersedia.")
            completion(false)
            return
        }
        
        let healthTypes: Set = [sleep, birthDate, sex, mass, heightType]
        
        healthStore.requestAuthorization(toShare: [], read: healthTypes) { success, error in
            if let error = error {
                print("Error requesting health data authorization: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(success)
            }
        }
    }
    
    func fetchSleepData(completion: @escaping (HKCategorySample?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType!, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, result, error in
            guard let result = result?.first as? HKCategorySample else {
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
    
    func getUserBiologicalSex() -> String? {
        do {
            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            switch biologicalSex {
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .other:
                return "Other"
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
