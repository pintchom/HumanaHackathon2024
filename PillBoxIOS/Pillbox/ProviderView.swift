import SwiftUI

struct ProviderView: View {
    let provider: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Provider: \(provider["name"] as? String ?? "Unknown")")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Pickups")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if let pickupsReady = provider["pickups-ready"] as? [String: [String: Any]] {
                        ForEach(Array(pickupsReady.keys), id: \.self) { key in
                            if let location = pickupsReady[key]?["location"] as? String {
                                HStack {
                                    Text(key)
                                        .font(.subheadline)
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.green)
                                    Text(location)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        Text("No pickups ready")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Refill Requests")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    if let refillRequests = provider["refill_requests"] as? [[String: Any]] {
                        ForEach(refillRequests.indices, id: \.self) { index in
                            let request = refillRequests[index]
                            if let name = request["name"] as? String,
                               let dosage = request["dosage"] as? String {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Medication: \(name)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Text("Dosage: \(dosage)")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        Text("No refill requests")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .navigationTitle("Provider Information")
    }
}

struct ProviderView_Previews: PreviewProvider {
    static var previews: some View {
        ProviderView(provider: [
            "name": "Health Provider",
            "pickups-ready": [
                "Medication A": ["location": "Pharmacy 1"],
                "Medication B": ["location": "Pharmacy 2"]
            ],
            "refill_requests": [
                ["name": "Medication X", "daily_schedule": ["Morning", "Evening"], "dosage": "2 pills", "instructions": "Take after meals"],
                ["name": "Medication Y", "daily_schedule": ["Night"], "dosage": "1 pill", "instructions": "Take before bedtime"]
            ]
        ])
    }
}
