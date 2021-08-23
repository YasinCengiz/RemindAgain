//
//  NotificationScheduler.swift
//  NotificationScheduler
//
//  Created by Yasin Cengiz on 23/8/21.
//

import Foundation
import CoreData
import UserNotifications
import Combine
import RxSwift

final class NotificationScheduler {
    
    private let alertManager = AlertManager(id: "REMINDER_ALERTS")
    private var cancellables: Set<AnyCancellable> = []
    private var disposeBag = DisposeBag()
    
    init(remindersPublisher: AnyPublisher<[RemindItem], Never>) {
        remindersPublisher.sink { [unowned self] reminders in
            self.scheduleNotifications(reminders: reminders)
        }
        .store(in: &cancellables)
    }
    
    func scheduleNotifications(reminders: [RemindItem]) {
        let alerts = reminders.map { reminder -> [Alert] in
            let title = reminder.title ?? "" // RemindItem's title
            return (reminder.remindRegistry as? Set<RemindRegistry>)?
                .map({ registry in
                    var components = Calendar.current.dateComponents([.hour, .minute], from: registry.time!)
                    components.weekday = Int(registry.weekday)
                    return Alert(title: title,
                                 registryID: registry.registryID!,
                                 dateComponents: components,
                                 sound: "sound",
                                 repeats: true)
                }) ?? []
        }
        .flatMap { $0 }
        alertManager.scheduleAlerts(alerts: Set<Alert>(alerts))
            .subscribe(onSuccess: {})
            .disposed(by: disposeBag)
    }
}
