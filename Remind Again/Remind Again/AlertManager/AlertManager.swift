//
//  AlertManager.swift
//  Alertz
//
//  Created by Mazyad Alabduljaleel on 10/9/15.
//  Copyright © 2015 Mazy. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift

/** Manages application alerts, which are simply Local Notificaitons.

    To use:
    + initialize with an `id`.
    + assign the `alerts` property some alerts
    + call `scheduleNotifications` in the userNotification callback in AppDelegate
*/
public final class AlertManager {

    // MARK: - nested types

    enum AlertError: Error {
        case accessDenied
    }

    // MARK: - properties

    /** Used to uniquely identify which alert objects belong to this particular manager. */
    let id: String
    let alertScheduler = UNUserNotificationCenter.current()

    // MARK: - Init & Dealloc

    public init(id: String) {
        self.id = id
    }
    
    // MARK: - Public methods

    public func scheduleAlerts(alerts: Set<Alert>) -> Single<Void> {

        return alertScheduler.rx_requestAuthorization(alerts: alerts)
            .map { _ in () }
            .flatMap(alertScheduler.rx_notificationSettings)
            .flatMap(alertScheduler.rx_pendingNotificationRequests)
            .flatMap { [unowned self] in self.scheduleNotifications(context: $0, alerts: alerts) }
    }

    /** removes all delivered notifications except the most recent one.
     */
    public func cleanDeliveredNotifications() -> Single<Void> {

        alertScheduler
            .rx_deliveredNotifications()
            .map { [alertScheduler] notifications in

                guard notifications.count > 1 else {
                    return
                }

                let ids = notifications
                    .sorted { $1.date < $0.date }
                    .suffix(from: 1)
                    .map { $0.request.identifier }

                alertScheduler.removeDeliveredNotifications(withIdentifiers: ids)
            }
    }
}

private extension AlertManager {

    func scheduleNotifications(context: UserNotificationContext, alerts: Set<Alert>) -> Single<Void> {
        // must be able to schedule alerts, or we are trying to cancel all
        if !alerts.isEmpty && !context.settings.authorizationStatus.granted {
            return .error(AlertError.accessDenied)
        }

        let pendingNotifications = context.pendingNotifications
            .filter { $0.identifier.starts(with: id) }
        
        // cancel ones that aren't in the upcoming alerts
        let cancelIds = pendingNotifications
            .filter { !alerts.contains($0.alert) }
            .map { $0.identifier }

        alertScheduler.removePendingNotificationRequests(withIdentifiers: cancelIds)

        return Single.create { [id, alertScheduler] event in

            let group = DispatchGroup()
            let pendingAlerts = pendingNotifications.map { $0.alert }
            // schedules ones that aren't already scheduled
            // past dates are automagically ignored \o/
            alerts
                .filter { !pendingAlerts.contains($0) }
                .map { UNNotificationRequest(managerId: id, alert: $0) }
                .forEach {
                    group.enter()
                    alertScheduler.add($0) { _ in group.leave() }
                }

            group.notify(queue: .main) {
                event(.success(()))
            }

            return Disposables.create()
        }
    }
}

private typealias UserNotificationContext = (
    settings: UNNotificationSettings,
    pendingNotifications: [UNNotificationRequest])

public extension UNUserNotificationCenter /* +RxSwift */ {

    func rx_requestAuthorization(alerts: Set<Alert>) -> Single<Bool> {
        alerts.isEmpty ? .just(false) : .create { event in
            self.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                event(.success(granted))
            }
            return Disposables.create()
        }
    }

    func rx_notificationSettings() -> Single<UNNotificationSettings> {
        return .create { event in
            self.getNotificationSettings {
                event(.success($0))
            }
            return Disposables.create()
        }
    }

    fileprivate func rx_pendingNotificationRequests(_ settings: UNNotificationSettings)
        -> Single<UserNotificationContext> {
        return .create { event in
            self.getPendingNotificationRequests { requests in
                event(.success((settings, requests)))
            }
            return Disposables.create()
        }
    }

    fileprivate func rx_deliveredNotifications() -> Single<[UNNotification]> {
        return .create { event in
            self.getDeliveredNotifications { notifications in
                event(.success(notifications))
            }
            return Disposables.create()
        }
    }
}

private extension UNAuthorizationStatus {

    var granted: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}

private extension UNNotificationRequest {

    var alert: Alert {
        let calendarTrigger = trigger as? UNCalendarNotificationTrigger
        let sound = content.userInfo["sound"] as? String
        return .init(title: content.title,
                     message: content.body,
                     dateComponents: calendarTrigger?.dateComponents ?? .init(),
                     sound: sound)
    }

    convenience init(managerId: String, alert: Alert) {
        // Must be unique as not not override each other
        let identifier = [managerId, UUID().uuidString]
            .joined(separator: ":")

        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        alert.sound.flatMap { content.userInfo = ["sound": $0] }
        content.sound = alert.sound
            .flatMap(UNNotificationSoundName.init(_:))
            .flatMap(UNNotificationSound.init(named:))

        let trigger = UNCalendarNotificationTrigger(dateMatching: alert.dateComponents,
                                                    repeats: alert.repeats)

        self.init(identifier: identifier,
                  content: content,
                  trigger: trigger)
    }
}
