//
//  RepeatedDay.swift
//  RepeatedDay
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import Foundation

struct RepeatedDay : Hashable, Equatable {
    
    let weekday : Int
    let day : String
    let shortenedDay : String
    
    static func repeatedDays(from fromWeekdays: [Int]) -> [RepeatedDay] {
        guard fromWeekdays.isEmpty == false else { return [] }
        
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component((.weekday), from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .filter({ fromWeekdays.contains($0) })
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
        
        return days.map({ (date) in
            let components = calendar.dateComponents([.weekday], from: date)
            return RepeatedDay(weekday: components.weekday!, day: DateFormatter.fullDayName.string(from: date), shortenedDay: DateFormatter.shortDayName.string(from: date))
        })
    }
}
