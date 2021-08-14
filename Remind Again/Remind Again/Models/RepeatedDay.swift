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
    
    static func repeatedDays(from weekdays: [Int]) -> [RepeatedDay] {
        guard weekdays.isEmpty == false else { return [] }
        
        let calendar = Calendar.current
        let firstWeekday = calendar.firstWeekday
        
        let date = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: date) // Today
        components.day = firstWeekday
        let firstDayOfWeek = calendar.date(from: components)! // First day of this week
        
        let days: [(Int, Date)] = weekdays.map { index in
            var components = calendar.dateComponents([.year, .month, .day, .weekday], from: firstDayOfWeek)
            components.day = components.day! + index
            guard let weekday = components.weekday,
                  let date = calendar.date(from: components)
            else {
                fatalError("Error")
            }
            let weekdayCalculation = (weekday + index) % 7  // Depending on calender a day might return 8 - turn it to 0
            return (weekdayCalculation == 0 ? 7 : weekdayCalculation, date)  // turn 0 to 7
        }
        
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE"
        
        let shortenedFormatter = DateFormatter()
        shortenedFormatter.locale = .current
        shortenedFormatter.dateFormat = "E"
        
        return days.map({ (weekday , date) in
            RepeatedDay(weekday: weekday, day: formatter.string(from: date), shortenedDay: shortenedFormatter.string(from: date))
        })
    }
}
