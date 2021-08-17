//
//  HourMinuteView.swift
//  HourMinuteView
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import SwiftUI


import SwiftUI
import CoreData

struct HourMinuteView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var registry: RemindRegistry
    
    let hourMinFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeStyle = .short
//        formatter.dateFormat = "HH:mm"
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
            HStack(spacing: 1) {
                Text(hourMinute(from: Int(registry.hour), Int(registry.minute)))
                    .foregroundColor(.primary)
                if registry.done {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .fixedSize()
        })
            .buttonStyle(PlainButtonStyle())
    }
    
    func hourMinute(from hour: Int, _ minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let hoursMinutes = Calendar.current.date(from: components) {
            return hourMinFormatter.string(from: hoursMinutes)
        } else {
            return ""
        }
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
