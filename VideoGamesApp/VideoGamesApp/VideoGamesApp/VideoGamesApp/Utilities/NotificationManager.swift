//
//  NotificationManager.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import Foundation
import UserNotifications
import EventKit
import UIKit

extension NotificationManager {
    fileprivate enum Constants {
        static let defaultHour: Int = 9
        static let defaultMinute: Int = 0
    }
}

protocol NotificationManagerProtocol: AnyObject {
    func requestNotificationAuth(
        _ options: UNAuthorizationOptions,
        completion: @escaping (_ isAuthorized: Bool) -> Void
    )
    
    func requestCalendarAuth(
        completion: @escaping (_ isAuthorized: Bool) -> Void
    )
    
    func scheduleNotification(
        for date: Date,
        formatString: String,
        id: String,
        title: String,
        body: String,
        completion: @escaping (_ success: Bool) -> Void
    )
    
    func cancelNotification(id: String)
    
    func checkIfScheduled(
        _ identifier: String,
        completion: @escaping (_ exists: Bool) -> Void
    )
    
    func addToCalendar(
        for date: Date,
        title: String,
        body: String,
        completion: @escaping (_ success: Bool) -> Void
    )
    
    
}

final class NotificationManager {
    
    private var notificationCenter = UNUserNotificationCenter.current()
    
    private var newlyReleasedGames = [Int]()
    
}

extension NotificationManager: NotificationManagerProtocol {
    
    func requestNotificationAuth(
        _ options: UNAuthorizationOptions,
        completion: @escaping (_ isAuthorized: Bool) -> Void
    ) {
        notificationCenter.requestAuthorization(
            options: options
        ) { [weak self] success, error in
            guard let self else { return }
            
            if success {
                notificationCenter.getNotificationSettings { settings in
                    completion(
                        settings.authorizationStatus == .authorized
                    )
                }
            } else {
                completion(false)
            }
        }
    }
    
    func requestCalendarAuth(
        completion: @escaping (_ isAuthorized: Bool) -> Void
    ) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func scheduleNotification(
        for date: Date,
        formatString: String,
        id: String,
        title: String,
        body: String,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        let calender = Calendar.autoupdatingCurrent
        
        
        
        var dateComponents = calender.dateComponents(
            [.day, .month, .year, .hour, .minute],
            from: date
        )
        
        dateComponents.hour = Constants.defaultHour
        dateComponents.minute = Constants.defaultMinute
        
        // Testing Parameters
        //----------------------------------------
//        dateComponents.year = 2023
//        dateComponents.month = 7
//        dateComponents.day = 28
//        dateComponents.hour = 13
//        dateComponents.minute = 25
        //----------------------------------------
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        DispatchQueue.main.sync {
            content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [id]
        )
        
        notificationCenter.add(request) { error in
            completion(error == nil)
        }
    }
    
    func cancelNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [id]
        )
    }
    
    func checkIfScheduled(
        _ identifier: String,
        completion: @escaping (_ exists: Bool) -> Void
    ) {
        notificationCenter.getPendingNotificationRequests { requests in
            completion(
                requests.contains(where: {$0.identifier == identifier})
            )
        }
    }
    
    func addToCalendar(
        for date: Date,
        title: String,
        body: String,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.notes = body
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true)
        } catch {
            completion(false)
        }
    }
}
