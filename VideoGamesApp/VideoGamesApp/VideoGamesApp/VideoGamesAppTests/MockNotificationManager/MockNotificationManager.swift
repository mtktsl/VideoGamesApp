//
//  MockNotificationManager.swift
//  VideoGamesAppTests
//
//  Created by Metin Tarık Kiki on 28.07.2023.
//

import Foundation
@testable import VideoGamesApp
import UserNotifications

final class MockNotificationManager {
    var notificationAuth = false
    var calendarAuth = false
    
    var notificationScheduleCount: Int {
        return scheduledNotifications.count
    }
    
    var calendarScheduleCount: Int {
        scheduledCalendarEvents.count
    }
    
    var scheduledNotifications = Set<String>()
    var scheduledCalendarEvents = Set<String>()
}

extension MockNotificationManager: NotificationManagerProtocol {
    func requestNotificationAuth(_ options: UNAuthorizationOptions, completion: @escaping (Bool) -> Void) {
        completion(notificationAuth)
    }
    
    func requestCalendarAuth(completion: @escaping (Bool) -> Void) {
        completion(calendarAuth)
    }
    
    func scheduleNotification(for date: Date, formatString: String, id: String, title: String, body: String, completion: @escaping (Bool) -> Void) {
        if notificationAuth {
            scheduledNotifications.insert(id)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func cancelNotification(id: String) {
        scheduledNotifications.remove(id)
    }
    
    func checkIfScheduled(_ identifier: String, completion: @escaping (Bool) -> Void) {
        completion(
            scheduledNotifications.contains(identifier)
        )
    }
    
    func addToCalendar(for date: Date, title: String, body: String, completion: @escaping (Bool) -> Void) {
        if calendarAuth {
            scheduledCalendarEvents.insert(title)
        }
        
        completion(calendarAuth)
    }
    
    
}
