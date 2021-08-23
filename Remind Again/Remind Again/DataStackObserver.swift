//
//  DataStackObserver.swift
//  DataStackObserver
//
//  Created by Yasin Cengiz on 23/8/21.
//

import Foundation
import CoreData
import Combine

class DataStackObserver {
    
    var reminders: AnyPublisher<[RemindItem], Never> {
        remindersSubject.eraseToAnyPublisher()
    }
    private let remindersSubject = PassthroughSubject<[RemindItem], Never>()
    var registries: AnyPublisher<[RemindRegistry], Never> {
        registriesSubject.eraseToAnyPublisher()
    }
    private let registriesSubject = PassthroughSubject<[RemindRegistry], Never>()
    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didSaveObjectsNotification, object: context)
            .sink { [unowned self] _ in
                self.publishChanges()
            }
            .store(in: &cancellables)
    }
    
    func publishChanges() {
        do {
            let items = try context.fetch(RemindItem.fetchRequest())
            let registries = items.map { item -> [RemindRegistry] in
                return (item.remindRegistry?.allObjects as? [RemindRegistry]) ?? []
            }
            .flatMap { $0 }
            remindersSubject.send(items)
            registriesSubject.send(registries)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

