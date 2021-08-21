//
//  RemindItemViewModel.swift
//  RemindItemViewModel
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

class RemindItemViewModel: ObservableObject {
    
    @Published var registryHours: [Date]
    @Published var registryDays: [RepeatedDay]
    @Published var title: String
    @Published var notificationDenied = false
    
    var context: NSManagedObjectContext
    var remindItem: RemindItem
    let navigationTitle: String
//    let alertManager: AlertManager
    
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
                        return registry.weekday == weekday
                    })
                    .map({ registry -> Date in
                        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
                        components.hour = Int(registry.hour)
                        components.minute = Int(registry.minute)
                        return Calendar.current.date(from: components)!
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
                let components = Calendar.current.dateComponents([.hour, .minute], from: hour)
                let registry = RemindRegistry(context: context)
                registry.weekday = Int16(day.weekday)
                registry.hour = Int16(components.hour!)
                registry.minute = Int16(components.minute!)
                registry.registryID = UUID()
                registries.insert(registry)
                
                scheduleNotification(weekday: day.weekday,
                                     hour: components.hour!,
                                     minute: components.minute!,
                                     id: registry.registryID!.uuidString)
            }
        }
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
    
    func scheduleNotification(weekday: Int, hour: Int, minute: Int, id: String) {
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.body = title
        content.sound = UNNotificationSound.default
        
        // Define the custom actions.
        let doneAction = UNNotificationAction(identifier: "DONE_ACTION",
                                              title: "Done",
                                              options: [])
        // Define the notification type
        let actionCategory = UNNotificationCategory(identifier: "DONE_ACTION_NOTIFIER",
                                                        actions: [doneAction],
                                                        intentIdentifiers: [],
                                                        hiddenPreviewsBodyPlaceholder: "",
                                                        options: .customDismissAction)
        content.userInfo = ["REGISTRY_ID": id]
        content.categoryIdentifier = "DONE_ACTION_NOTIFIER"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: true)
        // Create the request
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        // Register the notification type.
        notificationCenter.setNotificationCategories([actionCategory])
        
        notificationCenter.add(request) { error in
            if error != nil {
                print(error?.localizedDescription ?? "Error at Notification Request")
            }
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.notificationDenied = false
            case .denied:
                self.notificationDenied = true
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    self.notificationDenied = !success
                    if success {
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            default:
                break
            }
        }
    }
}
