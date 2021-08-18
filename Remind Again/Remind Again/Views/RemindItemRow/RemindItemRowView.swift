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
        Text(remindItem.title ?? "")
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
            }
            .frame(minHeight: 30)
            if isExpanded {
                if let weekday = viewModel.registries.first?.weekday {
                    Text(viewModel.weekday(from: Int(weekday)))
                        .font(.caption).bold()
                }
                LazyVGrid(columns: Array<GridItem>(repeating: GridItem(.flexible()), count: 3), alignment: .leading, spacing: 10) {
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
