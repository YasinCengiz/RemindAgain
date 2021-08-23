//
//  DoneStatusUpdater.swift
//  DoneStatusUpdater
//
//  Created by Yasin Cengiz on 23/8/21.
//

import Foundation
import SwiftUI
import Combine

class DoneStatusUpdater {

    private var cancellables: Set<AnyCancellable> = []
    
    init(registriesPublisher: AnyPublisher<[RemindRegistry], Never>) {
        registriesPublisher.sink { [unowned self] registries in
            self.updateDoneStatus(registries: registries)
        }
        .store(in: &cancellables)
    }
    
    func updateDoneStatus(registries: [RemindRegistry]) {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        guard let today = components.weekday else {
            return
        }
        
        registries
            .sorted { r1, r2 in
                if r1.weekday == r2.weekday {
                    return r1.time! < r2.time!
                }
                return r1.weekday < r2.weekday
            }
            .reduce([RemindRegistry](), { result, reg in ///
                if let first = result.first {
                    if first.weekday == reg.weekday {
                        return result + [reg]
                    } else {
                        return result
                    }
                } else {
                    let normalizedRegDay = normalizedWeekday(for: Int(reg.weekday), today: today)
                    let normalizedToday = normalizedWeekday(for: today, today: today)
                    return (normalizedRegDay >= normalizedToday) ? [reg] : []
                }
            })
            .forEach { reg in
                reg.done = false
            }
    }

}

// Set Today as 1
private func normalizedWeekday(for weekday: Int, today: Int) -> Int {
    let normalized = (7 + weekday - today + 1) % 7
    return normalized == 0 ? 7 : normalized
}

