//
//  RemindItemView.swift
//  RemindItemView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import CoreData

struct RemindItemView: View {
    
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
                Section {
                    Button {
                        viewModel.save()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(viewModel.title.isEmpty && viewModel.registryDays.isEmpty && viewModel.registryHours.isEmpty)
                } footer: {
                    if viewModel.notificationDenied {
                        Text("Notifications must be allowed")
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
        }
        .onAppear {
            viewModel.checkNotificationPermission()
        }
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
            RemindItemView(context: context) // Add
            RemindItemView(remindItem: item, context: context) // Edit
        }
    }
}