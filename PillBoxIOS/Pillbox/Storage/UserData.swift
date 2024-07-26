//
//  UserData.swift
//  Pillbox
//
//  Created by Max Pintchouk on 7/26/24.
//

import Foundation

import SwiftUI
import Combine

class UserDataViewModel: ObservableObject {
    static let shared = UserDataViewModel()

    @Published var userData: [String: Any]?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var takenMedications: Set<Int> = []

    private init() {}

    func loadUserData() {
        isLoading = true
        errorMessage = nil
        
        Logic.shared.getUserData { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.userData = data
                    MedicationStore.shared.medications = self.userData?["Medication"] as! [String : Any]
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func takeMedication(at index: Int) {
        Logic.shared.takeMed(index: index) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Medication taken successfully")
                    self.updateMedicationStore()
                case .failure(let error):
                    print("Failed to take medication: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateMedicationStore() {
        Logic.shared.getUserData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.userData = data
                    if let medications = data["Medication"] as? [String: Any] {
                        MedicationStore.shared.medications = medications
                    }
                case .failure(let error):
                    print("Failed to update medication store: \(error.localizedDescription)")
                }
            }
        }
    }
}
