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
}
