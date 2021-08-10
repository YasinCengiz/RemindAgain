//
//  RepeatSelectionView.swift
//  RepeatSelectionView
//
//  Created by Yasin Cengiz on 31.07.2021.
//

import SwiftUI

struct RepeatedDay : Hashable, Equatable {
    
    let weekday : Int
    let day : String
    let shortenedDay : String
    
}

class RepeatSelectionViewModel: ObservableObject {
    
    let repeatTimes : [RepeatedDay]  // ["Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
    
    init() {
        
        let calendar = Calendar.current
        let firstWeekday = calendar.firstWeekday
        
        let date = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: date) // Today
        components.day = firstWeekday
        let firstDayOfWeek = calendar.date(from: components)! // First day of this week
        
        var days: [(Int, Date)] = (0..<7).compactMap { index in
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
        
        repeatTimes = days.map({ (weekday , date) in
            RepeatedDay(weekday: weekday, day: formatter.string(from: date), shortenedDay: shortenedFormatter.string(from: date))
        })
        
        
    }
    
    
}


struct RepeatSelectionView: View {
    
    @Binding var repeatTime: [RepeatedDay]
    @StateObject var viewModel = RepeatSelectionViewModel()
    
    var body: some View {
        List {
            
            Section{
                Button(action: {
                    //                    let repeatedTimesInt = viewModel.repeatTimes.map { $0.weekday }
                    if repeatTime == viewModel.repeatTimes {
                        repeatTime = []
                    } else {
                        repeatTime = viewModel.repeatTimes
                    }
                }, label: {
                    Text("Everyday")
                        .foregroundColor(Color(.label))
                })
            }
            
            ForEach(viewModel.repeatTimes, id: \.self) { repeatedDay in
                Button(action: {
                    if repeatTime.contains(repeatedDay) {
                        repeatTime.removeAll(where: { repeatedDay == $0 })
                    } else {
                        repeatTime.append(repeatedDay)
                    }
                }, label: {
                    HStack {
                        Text("Every " + repeatedDay.day)
                            .foregroundColor(Color(.label))
                        Spacer()
                        if repeatTime.contains(repeatedDay) {
                            Image(systemName: "checkmark")
                        }
                    }
                })
            }
            
            
        }
    }
}




struct RepeatSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatSelectionView(repeatTime: Binding<[RepeatedDay]>(get: {
            []
        }, set: { _ in
        }))
    }
}
