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
    
    init(){
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        
        guard let sleep = sleepType else {
                    print("Sleep data is not available.")
                    return
                }
        
        let healthTypes: Set = [sleep]
        
        Task{
            do{
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch{
                print("error fetching health data")
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
}
