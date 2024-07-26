//
//  MedicationStorage.swift
//  Pillbox
//
//  Created by Max Pintchouk on 7/26/24.
//

import SwiftUI
import Combine

class MedicationStore: ObservableObject {
    
    static let shared = MedicationStore()
        
    @Published var medications: [String: Any] = [:]
    
    private init() {}
    
    func fetchMedications() {
        Logic.shared.getUserData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    if let medications = userData["Medication"] as? [String: Any] {
                        self.medications = medications
                    }
                case .failure(let error):
                    print("Failed to fetch medications: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addMedication(name: String, dailySchedule: [String], dosage: String, instructions: String) {
        Logic.shared.addMedication(name: name, dailySchedule: dailySchedule, dosage: dosage, instructions: instructions) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchMedications()
                case .failure(let error):
                    print("Failed to add medication: \(error.localizedDescription)")
                }
            }
        }
    }
}
