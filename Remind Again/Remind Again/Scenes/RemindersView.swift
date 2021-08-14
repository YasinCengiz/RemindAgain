//
//  RemindersView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import CoreData
import OrderedCollections

struct RemindersView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: RemindItem.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \RemindItem.title, ascending: true)])
    
    private var items: FetchedResults<RemindItem>
    @State private var showingAddScreen = false
    @State private var showingEditScreen = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    RemindItemRowView(remindItem: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteItems(item: item)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                showingEditScreen.toggle()
                            } label: {
                                Image(systemName: "gear")
                            }
                            .tint(.blue)
                        }
                        .sheet(isPresented: $showingEditScreen) {
                            RemindItemView(remindItem: item, context: viewContext)
                        }
                    
                }
            }
            .navigationTitle("Reminders")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddScreen.toggle()
            } ){
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddScreen) {
                RemindItemView(context: viewContext)
            }
            
        }
        
        
    }
    
    private func deleteItems(item: RemindItem) {
        withAnimation {
            item.removeNotifications()
            viewContext.delete(item)
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
        RemindersView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
