//
//  ContentView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import CoreData

class RemindItemViewModel: ObservableObject {
    
    let dayFormatter : DateFormatter
    let hourMinFormatter : DateFormatter
    let remindItem : RemindItem
    
    var title : String {
        remindItem.title!
    }

    var days : [String] {
        guard let days = remindItem.remindDays?.allObjects as? [RemindDay] else {
            return []
        }
        return days.sorted(by: {
            return $0.weekday < $1.weekday
        }).compactMap({ day in
            if let date = Calendar.current.date(bySetting: .weekday, value: Int(day.weekday), of: Date()) {
                return dayFormatter.string(from: date)
            } else {
                return nil
            }
        })
    }
    
    var hourAndMinutes : [String] {
        guard let hours = remindItem.remindHourMinutes?.allObjects as? [RemindHourMinute] else {
            return []
        }
        return hours.compactMap({ hourMinute in
            var components = DateComponents()
            components.hour = Int(hourMinute.hour)
            components.minute = Int(hourMinute.minute)
            
            if let hoursMinutes = Calendar.current.date(from: components) {
                return hourMinFormatter.string(from: hoursMinutes)
            } else {
                return nil
            }
        })

    }
    
    init (remindItem : RemindItem) {
        self.remindItem = remindItem
        dayFormatter = DateFormatter()
        
        dayFormatter.locale = .current
        dayFormatter.dateFormat = "E"

        hourMinFormatter = DateFormatter()
        hourMinFormatter.locale = .current
        hourMinFormatter.dateFormat = "HH:mm"
    }
    
    
    
}


struct RemindItemView: View {
    
    @State var isExpanded = false
    @StateObject var viewModel : RemindItemViewModel
    
    init (remindItem : RemindItem) {
        _viewModel = StateObject(wrappedValue: RemindItemViewModel(remindItem: remindItem))
        
    }
    
    
    var body: some View {
        
        
        Button(action: {
            isExpanded.toggle()
        }) {
            Text(viewModel.title)
        }
        if isExpanded {
            
            VStack {
                
                ForEach(viewModel.days, id: \.self, content: { day in
                    HStack {
                        Text(day)
                            .frame(width: 69, alignment: .leading)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(viewModel.hourAndMinutes, id: \.self, content: {
                                    Text($0)
                                    Image(systemName: "checkmark")
                                })
                            }
                        }
                    }
                })
                
                
                
            }
        }
        
        
        
        
        
    }
}


struct ContentView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: RemindItem.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \RemindItem.title, ascending: true)])
    
    private var items: FetchedResults<RemindItem>
    @State private var showingAddScreen = false
    
    var body: some View {
        NavigationView {
            List {
                
                ForEach(items) { item in
                    RemindItemView(remindItem: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Reminders")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddScreen.toggle()
            } ){
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddScreen) {
                AddReminderView().environment(\.managedObjectContext, self.viewContext)
            }
            
            
        }
        
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
