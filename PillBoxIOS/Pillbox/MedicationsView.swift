import SwiftUI
import ConfettiSwiftUI

// Wrapper struct to make String identifiable
struct IdentifiableString: Identifiable {
    var id: String { value }
    let value: String
}

struct MedicationsView: View {
    @ObservedObject var store: MedicationStore = MedicationStore.shared
    @State var userData: [String: Any]?
    @State private var isRefreshing = false
    @State private var counter: Int = 0
    @State private var refillRequestStatus: IdentifiableString?

    var body: some View {
        VStack(spacing: 15) {
            medicationsSection
            dailyMedicationScheduleSection
            navigationButtonsSection
        }
        .padding(.vertical)
        .navigationTitle("Medications")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshSchedule) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isRefreshing)
            }
        }
        .overlay(
            Group {
                if isRefreshing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        )
        .confettiCannon(counter: $counter)
        .alert(item: $refillRequestStatus) { status in
            Alert(title: Text("Refill Request"), message: Text(status.value), dismissButton: .default(Text("OK")))
        }
    }
    
    private var medicationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medications")
                .font(.headline)
                .padding(.leading)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(store.medications.keys.sorted()), id: \.self) { medicationName in
                        if let medicationInfo = store.medications[medicationName] as? [String: Any] {
                            MedicationItemRow(medicationName: medicationName, medicationInfo: medicationInfo) {
                                requestRefill(medicationName: medicationName, medicationInfo: medicationInfo)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 5)
    }
    
    private var dailyMedicationScheduleSection: some View {
        VStack(alignment: .leading) {
            Text("Daily Medication Schedule")
                .font(.headline)
                .padding(.leading)
            ScrollView {
                if let staticSchedule = userData?["static_schedule"] as? [[String: Any]] {
                    ForEach(staticSchedule.indices, id: \.self) { index in
                        ScheduleItemView(item: staticSchedule[index])
                        if index < staticSchedule.count - 1 {
                            Divider()
                        }
                    }
                } else {
                    Text("No static schedule available")
                }
            }
            .padding(.horizontal)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 5)
    }
    
    private var navigationButtonsSection: some View {
        HStack {
            NavigationLink(destination: AddMedicationView()) {
                Text("Add Medication")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: HistoryView()) {
                Text("History")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private func refreshSchedule() {
        isRefreshing = true
        Logic.shared.resetSchedule { result in
            DispatchQueue.main.async {
                isRefreshing = false
                switch result {
                case .success(let data):
                    print("Schedule refreshed successfully")
                    self.userData = data
                    MedicationStore.shared.medications = data["Medication"] as? [String: Any] ?? [:]
                case .failure(let error):
                    print("Failed to refresh schedule: \(error.localizedDescription)")
                    // You might want to show an alert here
                }
            }
        }
    }
    
    private func requestRefill(medicationName: String, medicationInfo: [String: Any]) {
        guard let dailySchedule = medicationInfo["daily-schedule"] as? [String],
              let dosage = medicationInfo["dosage"] as? String,
              let instructions = medicationInfo["instructions"] as? String else {
            refillRequestStatus = IdentifiableString(value: "Invalid medication information")
            return
        }

        Logic.shared.requestRefill(name: medicationName, dailySchedule: dailySchedule, dosage: dosage, instructions: instructions) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    refillRequestStatus = IdentifiableString(value: "Refill requested successfully for \(medicationName)")
                    counter += 1
                case .failure(let error):
                    refillRequestStatus = IdentifiableString(value: "Failed to request refill: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MedicationItemRow: View {
    let medicationName: String
    let medicationInfo: [String: Any]
    let requestRefillAction: () -> Void

    var body: some View {
        HStack {
            MedicationItemView(medicationName: medicationName, medicationInfo: medicationInfo)
            
            Spacer()
            
            Button(action: requestRefillAction) {
                Text("Request Refill")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MedicationItemView: View {
    let medicationName: String
    let medicationInfo: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(medicationName)
                .font(.headline)
            
            if let dosage = medicationInfo["dosage"] as? String {
                Text("Dosage: \(dosage)")
                    .font(.subheadline)
            }
            
            if let instructions = medicationInfo["instructions"] as? String {
                Text("Instructions: \(instructions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let dailySchedule = medicationInfo["daily-schedule"] as? [String] {
                ForEach(dailySchedule, id: \.self) { time in
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ScheduleItemView: View {
    let item: [String: Any]
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item["time"] as? String ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text(item["medication"] as? String ?? "")
                    .font(.subheadline)
                Text("Dosage: " + (item["dosage"] as? String ?? ""))
                    .font(.caption)
                Text("Instructions: " + (item["instructions"] as? String ?? ""))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView(userData: [:])
    }
}
