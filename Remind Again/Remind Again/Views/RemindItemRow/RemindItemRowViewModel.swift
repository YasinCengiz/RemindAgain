//
//  RemindItemRowViewModel.swift
//  RemindItemRowViewModel
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import Combine
import CoreData
import OrderedCollections

class RemindItemRowViewModel: ObservableObject {
    
    let dayFormatter : DateFormatter
    @Published var remindItem : RemindItem
    @Published var registry: OrderedDictionary<Int, [RemindRegistry]>
    private var cancellable: AnyCancellable?
    
    func weekday(from weekday: Int) -> String {
        if let date = Calendar.current.date(bySetting: .weekday, value: Int(weekday), of: Date()) {
            return dayFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    init (remindItem : RemindItem) {
        _remindItem = Published(wrappedValue: remindItem)
        dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.dateFormat = "E"
        
        var result = OrderedDictionary<Int, [RemindRegistry]>()
        
        guard let r = remindItem.remindRegistry?.allObjects as? [RemindRegistry] else {
            _registry = Published(wrappedValue: result)
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
        
        _registry = Published(wrappedValue: result)
        
        cancellable = NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didSaveObjectsNotification)
            .sink { _ in
                self.objectWillChange.send()
            }
    }
}


// Expand after adding new object doesn't work
