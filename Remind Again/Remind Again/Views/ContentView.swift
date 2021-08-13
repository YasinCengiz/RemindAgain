//
//  ContentView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import CoreData
import OrderedCollections

class RemindItemViewModel: ObservableObject {
    
    let dayFormatter : DateFormatter
    let remindItem : RemindItem
    @State var registry: OrderedDictionary<Int, [RemindRegistry]>
    
    var title : String {
        remindItem.title!
    }
    
    func weekday(from weekday: Int) -> String {
        if let date = Calendar.current.date(bySetting: .weekday, value: Int(weekday), of: Date()) {
            return dayFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    init (remindItem : RemindItem) {
        self.remindItem = remindItem
        dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.dateFormat = "E"
        
        var result = OrderedDictionary<Int, [RemindRegistry]>()
        
        guard let r = remindItem.remindRegistry?.allObjects as? [RemindRegistry] else {
            _registry = State< OrderedDictionary<Int, [RemindRegistry]> >(wrappedValue: result)
            return
        }
        
        result = r.sorted { r1, r2 in
            if r1.weekday == r2.weekday {
                if r1.hour == r2.hour {
                    return r1.minute < r2.minute
                }
                return r1.hour < r2.hour
            }
            return r1.weekday < r2.weekday
        }
        .reduce(OrderedDictionary<Int, [RemindRegistry]>()) { partialResult, reg in
            var result = partialResult
            if var list = result[Int(reg.weekday)] {
                list.append(reg)
                result[Int(reg.weekday)] = list
            } else {
                result[Int(reg.weekday)] = [reg]
            }
            return result
        }
        
        _registry = State< OrderedDictionary<Int, [RemindRegistry]> >(wrappedValue: result)
    }
}

struct HourMinuteView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var registry: RemindRegistry
    let hourMinFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Button(action : {
            registry.done.toggle()
            do {
                try viewContext.save()
            } catch {
                fatalError("Unresolved error")
            }
        }, label: {
            Text(hourMinute(from: Int(registry.hour), Int(registry.minute)))
                .foregroundColor(.primary)
            Image(systemName: "checkmark")
                .foregroundColor(registry.done ? .accentColor : .gray)
        })
    }
    
    func hourMinute(from hour: Int, _ minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let hoursMinutes = Calendar.current.date(from: components) {
            return hourMinFormatter.string(from: hoursMinutes)
        } else {
            return ""
        }
    }
}


struct RemindItemView: View {
    
    @State var isExpanded = false
    @StateObject var viewModel : RemindItemViewModel
    @Environment(\.managedObjectContext) var viewContext
    
    init (remindItem : RemindItem) {
        _viewModel = StateObject(wrappedValue: RemindItemViewModel(remindItem: remindItem))
    }
    
    var body: some View {
        VStack {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(viewModel.title)
                    Spacer()
                    Button {
                        // Add Edit View
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                
            }
            
            if isExpanded {
                VStack {
                    ForEach(viewModel.registry.keys, id: \.self) { weekday in
                        HStack {
                            Text(viewModel.weekday(from: weekday))
                                .frame(width: 69, alignment: .leading)
                            ScrollView(.horizontal) {
                                HStack {
                                    if let registries = viewModel.registry[weekday] {
                                        ForEach(registries) { registry in
                                            HourMinuteView(registry: registry)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
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
