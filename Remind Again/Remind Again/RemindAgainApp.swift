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
    let dataStackObserver: DataStackObserver
    let notificationScheduler: NotificationScheduler
    let doneStatusUpdater: DoneStatusUpdater

    init() {
        let observer = DataStackObserver()
        self.dataStackObserver = observer
        self.notificationScheduler = NotificationScheduler(remindersPublisher: observer.reminders)
        self.doneStatusUpdater = DoneStatusUpdater(context: persistenceController.container.viewContext,
                                                   registriesPublisher: observer.registries)
    }
    
    var body: some Scene {
        WindowGroup {
            RemindersView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
