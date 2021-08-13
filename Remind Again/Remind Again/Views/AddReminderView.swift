//
//  AddReminderView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import UserNotifications



struct AddReminderView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var remindTimes : [Date] = [Date()]
    @State var repeatTime: [RepeatedDay] = []
    @State private var notificationDenied = true

    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach($remindTimes, id: \.self ) { $remindTime in
                        DatePicker("Remind Again", selection: $remindTime, displayedComponents: .hourAndMinute)
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { idx in
                            remindTimes.remove(at: idx)
                        }
                    })
                    Button("Add Time") {
                        remindTimes.append(Date())
                    }
                }
                
                Section {
                    TextField("Title", text: $title)
                    NavigationLink {
                        RepeatSelectionView(repeatTime: $repeatTime)
                    } label: {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text(repeatTime.map({
                                $0.shortenedDay
                            }).joined(separator: " "))
                        }
                    }
                }
                Section(content: {
                    Button("Save") {
                        
                        var registries : Set<RemindRegistry> = []
                        
                        for day in repeatTime {
                            for hour in remindTimes {
                                let components = Calendar.current.dateComponents([.hour, .minute],
                                                                                 from: hour)
                                let registry = RemindRegistry(context: viewContext)
                                registry.weekday = Int16( day.weekday )
                                registry.hour = Int16( components.hour! )
                                registry.minute = Int16 ( components.minute! )
                                registry.id = UUID()
                                registries.insert(registry)
                                print("DEBUG: \(registry)")
                                
                                var dateComponents = DateComponents()
                                dateComponents.weekday = Int(registry.weekday)
                                dateComponents.hour = Int(registry.hour)
                                dateComponents.minute = Int(registry.minute)
                                
                                let content = UNMutableNotificationContent()
                                content.body = title
//                                content.body = "\(dateComponents.weekday) + (dateComponents.hour), dateComponents.minute) "
//                                content.body = String(registry.hour) + " " + String(registry.minute)
//                                content.title = title
                                content.sound = UNNotificationSound.default
                                
                                let done = UNNotificationAction(identifier: "done", title: "Done", options: .foreground)
                                let cancel = UNNotificationAction(identifier: "cancel", title: "Cancel", options: .destructive)
//                                let categories = UNNotificationCategory(identifier: "action", actions: [done, cancel], intentIdentifiers: [])
                                let categories = UNNotificationCategory(identifier: "action", actions: [done, cancel], intentIdentifiers: [])
                                
                                let trigger = UNCalendarNotificationTrigger(
                                    dateMatching: dateComponents, repeats: true)
                                // Create the request
                                let request = UNNotificationRequest(identifier: registry.id!.uuidString,
                                                                    content: content, trigger: trigger)
                                // Schedule the request with the system.
                                let notificationCenter = UNUserNotificationCenter.current()
                                notificationCenter.setNotificationCategories([categories])
                                content.categoryIdentifier = "action"
                                
                                notificationCenter.add(request) { error in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "Error at Notification Request")
                                    }
                                }
                                
                            }
                        }
                        
                        let newItem = RemindItem(context: viewContext)
                        newItem.id = UUID()
                        newItem.title = title
                        newItem.remindRegistry = registries as NSSet
                        
                        do {
                            try viewContext.save()
                            print("Data Saved")
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                    .disabled(notificationDenied)
                }, footer: {
                    if notificationDenied {
                        Text("Notifications must be allowed")
                        
                    }
                })
                
                
                
            }
            .onChange(of: remindTimes) { newValue in
                print("DEBUG: \(newValue)")
            }
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized: notificationDenied = false
                    case .denied: notificationDenied = true
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            notificationDenied = !success
                            if success {
                                print("All set!")
                            } else if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    default : break
                    }
                }
                
            }
        }
        .navigationTitle("Add Reminder")
        .listStyle(GroupedListStyle())
    }
    
}


struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView()
    }
}
