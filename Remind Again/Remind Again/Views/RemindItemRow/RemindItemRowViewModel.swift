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
    
    func weekday(from weekday: Int) -> String {
        if let date = Calendar.current.date(bySetting: .weekday, value: Int(weekday), of: Date()) {
            return dayFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    init (remindItem : RemindItem) {
        dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.dateFormat = "EEEE"
     
        _remindItem = Published(wrappedValue: remindItem)
        
        _registries = Published(wrappedValue: {
            (remindItem.remindRegistry?.allObjects as? [RemindRegistry] ?? [])
                .sorted { r1, r2 in
                    if r1.weekday == r2.weekday {
                        if r1.hour == r2.hour {
                            return r1.minute < r2.minute
                        }
                        return r1.hour < r2.hour
                    }
                    return r1.weekday < r2.weekday
                }
                .reduce([RemindRegistry](), { result, reg in
                    if let first = result.first {
                        if first.weekday == reg.weekday {
                            return result + [reg]
                        } else {
                            return result
                        }
                    } else {
                        let components = Calendar.current.dateComponents([.weekday], from: Date())
                        return (reg.weekday >= (components.weekday ?? 0)) ? [reg] : []
                    }
                })
            }()
        )
    }
}
