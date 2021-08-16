//
//  RemindItemRowView.swift
//  RemindItemRowView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import CoreData

struct RemindItemTitleView: View {
    
    @ObservedObject var remindItem: RemindItem
    
    var body: some View {
        Text(remindItem.title ?? "Error Getting Title")
            .foregroundColor(Color(uiColor: .label))
    }
}

struct RemindItemRowView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @State var isExpanded = false
    @StateObject var viewModel : RemindItemRowViewModel
    
    init (remindItem : RemindItem) {
        _viewModel = StateObject(wrappedValue: RemindItemRowViewModel(remindItem: remindItem))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isExpanded.toggle()
            }) {
                RemindItemTitleView(remindItem: viewModel.remindItem)
//                Text(viewModel.remindItem.title ?? "Error Getting Title")
//                    .foregroundColor(Color(uiColor: .label))
            }
            .frame(minHeight: 40)
            if isExpanded {
                if let weekday = viewModel.registries.first?.weekday {
                    Text(viewModel.weekday(from: Int(weekday)))
                        .font(.caption).bold()
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: 5) {
                    ForEach(viewModel.registries, id: \.registryID) { registry in
                        HourMinuteView(registry: registry)
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
