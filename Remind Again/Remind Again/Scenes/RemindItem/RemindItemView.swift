//
//  RemindItemView.swift
//  RemindItemView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import CoreData

struct RemindItemView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: RemindItemViewModel
    
    init(remindItem: RemindItem? = nil, context: NSManagedObjectContext) {
        _viewModel = StateObject<RemindItemViewModel>(
            wrappedValue: RemindItemViewModel(remindItem: remindItem, context: context)
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach($viewModel.registryHours, id: \.self) { $registry in
                        DatePicker("Remind Again", selection: $registry, displayedComponents: .hourAndMinute)
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let index = viewModel.registryHours.firstIndex(of: registry) {
                                        viewModel.registryHours.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                    }
                    Button("Add Time") {
                        viewModel.registryHours.append(Date())
                    }
                }
                Section {
                    TextField("Title", text: $viewModel.title)
                    NavigationLink {
                        RepeatSelectionView(repeatTime: $viewModel.registryDays)
                    } label: {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text(viewModel.registryDays.map({ $0.shortenedDay }).joined(separator: " "))
                        }
                    }
                }
                if viewModel.notificationDenied {
                    Section {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "info.circle")
                            Text("Notifications must be enabled to recieve alerts.")
                                .font(.footnote)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.save()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.registryDays.isEmpty || viewModel.registryHours.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewContext.rollback()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            viewModel.checkNotificationPermission()
        }
        .onDisappear(perform: {
            viewContext.rollback()
        })
    }
}

struct RemindItemView_Previews: PreviewProvider {
    static var context: NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }
    static var item: RemindItem {
        let request = RemindItem.fetchRequest()
        return (try! context.fetch(request)).first!
    }
    static var previews: some View {
        Group {
            RemindItemView(context: context)
                .preferredColorScheme(.light) // Add
            RemindItemView(remindItem: item, context: context) // Edit
        }
    }
}
