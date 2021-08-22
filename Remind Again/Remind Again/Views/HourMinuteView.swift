//
//  HourMinuteView.swift
//  HourMinuteView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI
import CoreData

struct HourMinuteView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var registry: RemindRegistry
    
    let hourMinFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action : {
            registry.done.toggle()
            do {
                try viewContext.save()
            } catch {
                fatalError("Unresolved error")
            }
        }, label: {
            HStack(spacing: 2) {
                if registry.done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.gray)
                }
                if let time = registry.time {
                    Text(hourMinute(from: time))
                        .foregroundColor(.primary)
                }
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    func hourMinute(from time: Date) -> String {
        return hourMinFormatter.string(from: time)
    }
}

//struct HourMinuteView_Previews: PreviewProvider {
//    static var context: NSManagedObjectContext {
//        PersistenceController.preview.container.viewContext
//    }
//    static var item: RemindRegistry {
//        let request = RemindRegistry.fetchRequest()
//        return (try! context.fetch(request)).first!
//    }
//    static var previews: some View {
//        HourMinuteView(registry: item)
//    }
//}
