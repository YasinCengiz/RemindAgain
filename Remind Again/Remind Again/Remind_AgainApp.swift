//
//  Remind_AgainApp.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI

@main
struct Remind_AgainApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
