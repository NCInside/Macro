import Foundation
import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, [String: Bool]) -> Void) {
        guard let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Date of birth or sleep type is not available in HealthKit.")
            completion(false, ["showAlert": true])
            return
        }
        
        let healthTypes: Set = [dateOfBirthType, sleepType]
        
        healthStore.requestAuthorization(toShare: [], read: healthTypes) { success, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
            
            var navigationStates: [String: Bool] = [
                "NameOnBoarding": true,
                "DateOfBirthOnBoarding": true,
                "showAlert": false
            ]
            
            if success {
                // Fetch and save the date of birth if available
                if let birthDate = self.getUserDateOfBirth() {
                    self.saveDateOfBirthToUserDefaults(birthDate)
                    navigationStates["DateOfBirthOnBoarding"] = false
                }
                
                // Fetch sleep data to check if there is any recent data
                self.fetchSleepDataForLast7Days { sleepData, count in
                    if count == 0 {
                        navigationStates["showAlert"] = true
                    }
                    completion(success, navigationStates)
                }
            } else {
                completion(false, navigationStates)
            }
        }
    }
    
    // Function to fetch date of birth from HealthKit
    func getUserDateOfBirth() -> DateComponents? {
        do {
            let dateOfBirth = try healthStore.dateOfBirthComponents()
            print("Fetched Date of Birth from HealthKit: \(dateOfBirth)")
            return dateOfBirth
        } catch {
            print("Error fetching date of birth: \(error)")
            return nil
        }
    }
    
    // Helper function to save date of birth to UserDefaults
    private func saveDateOfBirthToUserDefaults(_ dateOfBirth: DateComponents) {
        guard let year = dateOfBirth.year, let month = dateOfBirth.month, let day = dateOfBirth.day else { return }
        
        let birthDateString = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        UserDefaults.standard.set(birthDateString, forKey: "dateOfBirth")
        print("Date of Birth saved to UserDefaults: \(birthDateString)")
    }

    

    func fetchAge() -> Int? {
            guard let birthDateString = UserDefaults.standard.string(forKey: "dateOfBirth") else {
                return nil // Date of birth not found
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            // Convert the string to a Date object
            guard let birthDate = formatter.date(from: birthDateString) else {
                return nil // Invalid date format
            }
            
            let calendar = Calendar.current
            let now = Date()
            
            let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthDate, to: now)
            guard let age = ageComponents.year else {
                return nil
            }
            
            // Determine if birthday has occurred this year
            let birthdayThisYear = calendar.date(byAdding: .year, value: age, to: birthDate)!
            
            if now < birthdayThisYear {
                return age - 1
            }
            
            return age
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
    
    func getStoredBirthDate() -> DateComponents? {
        if let birthDateString = UserDefaults.standard.string(forKey: "dateOfBirth") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let date = formatter.date(from: birthDateString) {
                let calendar = Calendar.current
                return calendar.dateComponents([.year, .month, .day], from: date)
            }
        }
        return nil
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
