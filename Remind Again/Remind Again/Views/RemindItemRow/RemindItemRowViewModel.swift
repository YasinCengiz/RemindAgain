//
//  RemindItemRowViewModel.swift
//  RemindItemRowViewModel
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import Combine
import CoreData

class RemindItemRowViewModel: ObservableObject {
    
    let dayFormatter : DateFormatter
    @Published var remindItem: RemindItem
    @Published var registries: [RemindRegistry]
    private var cancellables: Set<AnyCancellable> = []
    private var observation: NSKeyValueObservation?
    
    init (remindItem : RemindItem) {
        dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.dateFormat = "EEEE"
     
        _remindItem = Published(wrappedValue: remindItem)
        
        _registries = Published(wrappedValue: registriesFrom(remindItem: remindItem))
        
        observation = remindItem.observe(\.remindRegistry) { [unowned self] item, change in
            self.registries = []
            self.registries = registriesFrom(remindItem: item)
        }
    }
    
    func weekday(from weekday: Int) -> String {
        if let date = Calendar.current.date(bySetting: .weekday, value: Int(weekday), of: Date()) {
            return dayFormatter.string(from: date)
        } else {
            return ""
        }
    }
}

private func registriesFrom(remindItem: RemindItem) -> [RemindRegistry] {
    let components = Calendar.current.dateComponents([.weekday], from: Date())
    guard let today = components.weekday else {
        return []
    }
    return (remindItem.remindRegistry?.allObjects as? [RemindRegistry] ?? [])
        .sorted { r1, r2 in
            if r1.weekday == r2.weekday {
                return r1.time! < r2.time!
            }
            return normalizedWeekday(for: Int(r1.weekday), today: today) < normalizedWeekday(for: Int(r2.weekday), today: today)
        }
        .reduce([RemindRegistry](), { result, reg in
            if let first = result.first {
                if first.weekday == reg.weekday {
                    return result + [reg]
                } else {
                    return result
                }
            } else {
//                return reg.weekday >= today ? [reg] : []
                let normalizedRegDay = normalizedWeekday(for: Int(reg.weekday), today: today)
                let normalizedToday = normalizedWeekday(for: today, today: today)
                return (normalizedRegDay >= normalizedToday) ? [reg] : []
            }
        })
}
// Set Today as 1
private func normalizedWeekday(for weekday: Int, today: Int) -> Int {
    let normalized = (7 + weekday - today + 1) % 7
    return normalized == 0 ? 7 : normalized
}
