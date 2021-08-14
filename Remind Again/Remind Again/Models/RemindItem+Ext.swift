//
//  RemindItem+Ext.swift
//  RemindItem+Ext
//
//  Created by Yasin Cengiz on 14.08.2021.
//

import Foundation
import UserNotifications

extension RemindItem {
    func removeNotifications() {
        if let ids = (remindRegistry?.allObjects as? [RemindRegistry])?.compactMap({ reg in
            reg.registryID?.uuidString
        }) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}

