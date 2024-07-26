import SwiftUI
import ConfettiSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = UserDataViewModel.shared
    @State private var counter: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if let userData = viewModel.userData {
                    VStack(alignment: .leading) {
                        if let name = userData["name"] as? String {
                            Text("Hello, " + name)
                                .font(.title)
                                .padding(.leading)
                        }
                        VStack(alignment: .leading) {
                            Text("Today's Medication Schedule")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ScrollView {
                                if let dailySchedule = userData["daily_schedule"] as? [[String: Any]] {
                                    ForEach(Array(dailySchedule.enumerated()), id: \.offset) { index, item in
                                        if !viewModel.takenMedications.contains(index) {
                                            HStack(alignment: .top) {
                                                Button(action: {
                                                    viewModel.takeMedication(at: index)
                                                    counter += 1
                                                }) {
                                                    Image(systemName: "circle")
                                                        .foregroundColor(.gray)
                                                        .font(.title2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(item["time"] as? String ?? "")
                                                        .font(.title)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.blue)
                                                    Text(item["medication"] as? String ?? "")
                                                        .font(.headline)
                                                    Text("Dosage: " + (item["dosage"] as? String ?? ""))
                                                        .font(.headline)
                                                    Text("Instructions: " + (item["instructions"] as? String ?? ""))
                                                        .font(.headline)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 5)
                                            
                                            if index < dailySchedule.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                } else {
                                    Text("No daily schedule available")
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink {
                            if userData["Medication"] is [String: Any] {
                                MedicationsView(userData: userData)
                            } else {
                                Text("No medications data available")
                            }
                        } label: {
                            Text("Medications")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink {
                            if let provider = userData["provider"] as? [String: Any] {
                                ProviderView(provider: provider)
                            } else {
                                Text("No provider data available")
                            }
                        } label: {
                            Text("Provider")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    Text("No data available")
                }
            }
            .onAppear(perform: viewModel.loadUserData)
        }
        .confettiCannon(counter: $counter)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
