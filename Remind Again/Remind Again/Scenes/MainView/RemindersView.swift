//
//  RemindersView.swift
//  Remind Again
//
//  Created by Yasin Cengiz on 26.07.2021.
//

import SwiftUI
import CoreData

struct ReminderSearchView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @StateObject private var viewModel = RemindersViewModel()
    @State private var showingEditScreen = false

    private var fetchRequest: FetchRequest<RemindItem>
    private var items: FetchedResults<RemindItem> {
        fetchRequest.wrappedValue
    }
    
    init(searchText: String, sortOption: SortOption) {
        var predicate: NSPredicate?
        if searchText.isEmpty == false {
            predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
        var sortDescriptor: NSSortDescriptor
        switch sortOption {
        case .aToZ:
            sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        case .zToA:
            sortDescriptor = NSSortDescriptor(key: "title", ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        case .firstCreated:
            sortDescriptor = NSSortDescriptor(keyPath: \RemindItem.createdAt, ascending: true)
        case .lastCreated:
            sortDescriptor = NSSortDescriptor(keyPath: \RemindItem.createdAt, ascending: false)
        }
        fetchRequest = FetchRequest(entity: RemindItem.entity(),
                                    sortDescriptors: [sortDescriptor],
                                    predicate: predicate)
    }
    
    var body: some View {
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
        .sheet(isPresented: $showingEditScreen) {
            if let e = viewModel.editItem {
                RemindItemView(remindItem: e, context: viewContext)
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


final class RemindersViewModel: ObservableObject {
    
    var editItem: RemindItem?
    
}

struct RemindersView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var showingAddScreen = false
    @State private var showingAboutScreen = false
    @State private var showingSortScreen = false
    @State private var sortOption: SortOption = .aToZ
    @State private var searchText = ""
        
    var body: some View {
        NavigationView {
            List {
                ReminderSearchView(searchText: searchText, sortOption: sortOption)
            }
            .searchable(text: $searchText) {
                ReminderSearchView(searchText: searchText, sortOption: sortOption)
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
                    .fullScreenCover(isPresented: $showingAboutScreen) {
                        AboutView()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSortScreen.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .sheet(isPresented: $showingSortScreen) {
                        SortDetailView(sortOption: $sortOption)
                    }
                }
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
