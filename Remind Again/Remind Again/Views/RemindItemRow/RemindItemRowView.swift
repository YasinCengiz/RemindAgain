//
//  RemindItemRowView.swift
//  RemindItemRowView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import CoreData

struct RemindItemRowView: View {
    
    @State var isExpanded = false
    @StateObject var viewModel : RemindItemRowViewModel
    @Environment(\.managedObjectContext) var viewContext
    
    init (remindItem : RemindItem) {
        _viewModel = StateObject(wrappedValue: RemindItemRowViewModel(remindItem: remindItem))
    }
    
    var body: some View {
        VStack {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(viewModel.remindItem.title ?? "Error Getting Title")
                }
                
            }
            
            if isExpanded {
                VStack {
                    ForEach(viewModel.registry.keys, id: \.self) { weekday in
                        HStack {
                            Text(viewModel.weekday(from: weekday))
                                .frame(width: 69, alignment: .leading)
                            ScrollView(.horizontal) {
                                HStack {
                                    if let registries = viewModel.registry[weekday] {
                                        ForEach(registries) { registry in
                                            HourMinuteView(registry: registry)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//struct RemindItemRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        RemindItemRowView()
//    }
//}
