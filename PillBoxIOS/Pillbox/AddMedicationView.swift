//
//  AddMedicationView.swift
//  Pillbox
//
//  Created by Max Pintchouk on 7/26/24.
//

import SwiftUI

struct AddMedicationView: View {
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var dailySchedule: [String] = [""]
    @State private var instructions: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    TextField("Instructions", text: $instructions)
                }
                
                Section(header: Text("Daily Schedule")) {
                    ForEach(dailySchedule.indices, id: \.self) { index in
                        HStack {
                            TextField("Time (e.g., 09:00)", text: $dailySchedule[index])
                            
                            if index == dailySchedule.count - 1 {
                                Button(action: {
                                    dailySchedule.append("")
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    saveMedication()
                }) {
                    Text("Save Medication")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Medication")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Medication Add Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveMedication() {
        let filteredSchedule = dailySchedule.filter { !$0.isEmpty }
        
        MedicationStore.shared.addMedication(name: name, dailySchedule: filteredSchedule, dosage: dosage, instructions: instructions)
        alertMessage = "Medication added successfully"
        showAlert = true
        name = ""
        dosage = ""
        dailySchedule = [""]
    }
}

#Preview {
    AddMedicationView()
}
