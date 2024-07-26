//
//  PillboxApp.swift
//  Pillbox
//
//  Created by Max Pintchouk on 7/26/24.
//

import SwiftUI

@main
struct PillboxApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
    private func checkAndRefreshSchedule() {
        let calendar = Calendar.current
        let now = Date()
        
        let sixAM = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: now)!
        guard now > sixAM else { return }
        print("Resetting Schedule, it is past 6am")
        if let lastRefresh = UserDefaults.standard.object(forKey: "lastScheduleRefresh") as? Date {
            let isNewDay = !calendar.isDate(lastRefresh, inSameDayAs: now)
            if !isNewDay { return }
        }
        
        Logic.shared.resetSchedule { result in
            switch result {
            case .success:
                print("Schedule refreshed successfully")
                UserDefaults.standard.set(now, forKey: "lastScheduleRefresh")
                MedicationStore.shared.fetchMedications()
            case .failure(let error):
                print("Failed to refresh schedule: \(error.localizedDescription)")
            }
        }
    }
}
