//
//  RemindItemViewModel.swift
//  RemindItemViewModel
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import Foundation
import SwiftUI
import CoreData
import RxSwift

class RemindItemViewModel: ObservableObject {
    
    @Published var registryHours: [Date]
    @Published var registryDays: [RepeatedDay]
    @Published var title: String
    @Published var notificationDenied = false
    
    private var disposeBag = DisposeBag()
    private let alertManager = AlertManager(id: "REMINDER_ALERTS")
    
    var context: NSManagedObjectContext
    var remindItem: RemindItem
    let navigationTitle: String
    
    init(remindItem: RemindItem? = nil, context: NSManagedObjectContext) {
        self.context = context
        let item: RemindItem
        if remindItem == nil {
            // ADD MODE
            item = RemindItem(context: context)
            item.reminderID = UUID()
            item.createdAt = Date()
            navigationTitle = "Add Reminder"
        } else {
            // EDIT MODE
            item = remindItem!
            navigationTitle = "Edit Reminder"
        }
        self.remindItem = item
        _registryHours = Published<[Date]>(
            wrappedValue: {
                guard let registries = item.remindRegistry?.allObjects as? [RemindRegistry] else {
                    return [Date()]
                }
                guard let weekday = registries.first?.weekday else {
                    return [Date()]
                }
                return registries
                    .filter({ registry in
                        registry.weekday == weekday
                    })
                    .compactMap({ registry in
                        registry.time
                    })
            }()
        )
        _registryDays = Published<[RepeatedDay]>(
            wrappedValue: {
                guard let registries = item.remindRegistry?.allObjects as? [RemindRegistry] else {
                    return []
                }
                let weekdays = registries
                    .map { registry in
                        return Int(registry.weekday)
                    }
                return RepeatedDay.repeatedDays(from: Set<Int>(weekdays).sorted())
            }()
        )
        _title = Published<String>(wrappedValue: remindItem?.title ?? "")
    }
    
    func save() {
        clearExistingRegistries()
        remindItem.title = title
        var registries: Set<RemindRegistry> = []
        registryDays.forEach { day in
            registryHours.forEach { hour in
                let registry = RemindRegistry(context: context)
                registry.weekday = Int16(day.weekday)
                registry.time = hour
                registry.registryID = UUID()
                registries.insert(registry)
            }
        }
        alertManager.scheduleAlerts(alerts: Set<Alert>(registries.map({ reg -> Alert in
            var components = Calendar.current.dateComponents([.hour, .minute], from: reg.time!)
            components.weekday = Int(reg.weekday)
            return Alert(title: title, registryID: reg.registryID!, dateComponents: components, sound: "sound", repeats: true)
        })))
            .subscribe(onSuccess: {}, onFailure: { _ in }, onDisposed: {})
            .disposed(by: disposeBag)
        remindItem.remindRegistry = registries as NSSet
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearExistingRegistries() {
        remindItem.removeNotifications()
        (remindItem.remindRegistry as? Set<RemindRegistry>)?.forEach({ registry in
            context.delete(registry)
        })
    }
}
