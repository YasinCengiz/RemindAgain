//
//  RemindAgainApp.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI

@main
struct RemindAgainApp: App {
    let persistenceController = PersistenceController.shared
    let notificationCenterDelegate = NotificationCenterDelegate.shared

    var body: some Scene {
        WindowGroup {
            RemindersView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
