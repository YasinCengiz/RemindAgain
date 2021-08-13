//
//  NotificationCenterDelegate.swift
//  NotificationCenterDelegate
//
//  Created by Yasin Cengiz on 13.08.2021.
//

import Foundation
import UserNotifications
import CoreData

class NotificationCenterDelegate: NSObject {
    
    static let shared = NotificationCenterDelegate()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
}


extension NotificationCenterDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
                                @escaping () -> Void) {
        
        // Get the meeting ID from the original notification.
        let userInfo = response.notification.request.content.userInfo
        let registryID = userInfo["REGISTRY_ID"] as! String
             
        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "DONE_ACTION":
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<RemindRegistry> = RemindRegistry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(RemindRegistry.registryID), registryID)
            do {
                guard let registry = try context.fetch(fetchRequest).first else {
                    return
                }
//                print("DEBUG: REGISTRY: \(registry)")
                registry.done.toggle()
                try context.save()
            }
            catch let error as NSError {
                print("Error getting RegistryID: \(error.localizedDescription), \(error.userInfo)")
            }
            
//            print("DEBUG: DONE ACTION \(registryID)")
           break
             
        // Handle other actions…
      
        default:
           break
        }
         
        // Always call the completion handler when done.
        completionHandler()
        
    }

}
