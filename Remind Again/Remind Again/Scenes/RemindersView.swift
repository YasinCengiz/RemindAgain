//
//  RemindersView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import CoreData

final class RemindersViewModel: ObservableObject {
    
    var editItem: RemindItem?
    
}

struct RemindersView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: RemindItem.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \RemindItem.title, ascending: true)])
    private var items: FetchedResults<RemindItem>
    
    @State private var showingAddScreen = false
    @State private var showingEditScreen = false
    @State private var showingAboutScreen = false
    @StateObject private var viewModel = RemindersViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.reminderID) { item in
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
                                viewModel.editItem = item
                                showingEditScreen.toggle()
                            } label: {
                                Image(systemName: "gear")
                                
                            }
                            .tint(.blue)
                        }
                }
            }
            .sheet(isPresented: $showingEditScreen) {
                if let e = viewModel.editItem {
                    RemindItemView(remindItem: e, context: viewContext)
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddScreen.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showingAddScreen) {
                        RemindItemView(context: viewContext)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAboutScreen.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .sheet(isPresented: $showingAboutScreen) {
                        AboutView()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAboutScreen.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .sheet(isPresented: $showingAboutScreen) {
                        //SortView
                        //Name A-Z
                        //Name Z-A
                        //First Created
                        //Last Created
                    }
                }
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
