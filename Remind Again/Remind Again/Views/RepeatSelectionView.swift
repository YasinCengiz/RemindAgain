//
//  RepeatSelectionView.swift
//  RepeatSelectionView
//
//  Created by Yasin Cengiz on 31.07.2021.
//

import SwiftUI

class RepeatSelectionViewModel: ObservableObject {
    
    let repeatTimes : [RepeatedDay]
    // Weekdays as Monday,,,
    
    init() {
        repeatTimes = RepeatedDay.repeatedDays(from: Array(0..<7))
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
