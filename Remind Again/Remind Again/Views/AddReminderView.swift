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
                        
                        var remindHourMinutes : Set<RemindHourMinute> = []
                        var remindDays : Set<RemindDay> = []
                        
                        for hourMinute in remindTimes {
                            
                            var components = Calendar.current.dateComponents([.hour, .minute],
                                                                             from: hourMinute)
                            let hourAndMinute = RemindHourMinute(context: viewContext)
                            hourAndMinute.hour = Int16(components.hour!)
                            hourAndMinute.minute = Int16(components.minute!)
                            remindHourMinutes.insert(hourAndMinute)
                            
                        }
                        
                        for day in repeatTime {
                            
                            let remindDay = RemindDay(context: viewContext)
                            remindDay.weekday = Int16(day.weekday)
                            remindDays.insert(remindDay)
                            //print("DEBUG: \(day)")
                            
                        }
                        
                        for remindDay in remindDays{
                            
                            for remindHourMinute in remindHourMinutes {
                                
                                var components = DateComponents()
                                components.weekday = Int(remindDay.weekday)
                                components.hour = Int(remindHourMinute.hour)
                                components.minute = Int(remindHourMinute.minute)
                                
                                let content = UNMutableNotificationContent()
                                content.body = title
                                let trigger = UNCalendarNotificationTrigger(
                                    dateMatching: components, repeats: true)
                                // Create the request
                                let uuidString = UUID().uuidString
                                let request = UNNotificationRequest(identifier: uuidString,
                                                                    content: content, trigger: trigger)
                                // Schedule the request with the system.
                                let notificationCenter = UNUserNotificationCenter.current()
                                notificationCenter.add(request) { (error) in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "Error at Notification Request")
                                    }
                                }
                                
                            }
                            
                            
                        }
                        
                        let newItem = RemindItem(context: viewContext)
                        newItem.title = title
                        newItem.remindDays = remindDays as NSSet
                        newItem.remindHourMinutes = remindHourMinutes as NSSet
                        
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
