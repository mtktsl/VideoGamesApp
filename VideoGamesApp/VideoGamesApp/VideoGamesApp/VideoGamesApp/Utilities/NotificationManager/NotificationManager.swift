//
//  NotificationManager.swift
//  VideoGamesApp
//
//  Created by Metin Tarık Kiki on 27.07.2023.
//

import Foundation
import UserNotifications

extension NotificationManager {
    fileprivate enum Constants {
        static let defaultHour: Int = 9
        static let defaultMinute: Int = 0
    }
}

protocol NotificationManagerProtocol: AnyObject {
    func requestAuth(_ options: UNAuthorizationOptions)
    func scheduleNotification(
        for date: Date,
        formatString: String,
        title: String,
        body: String
    )
}

final class NotificationManager {
    
    public static let shared: NotificationManagerProtocol = NotificationManager()
    
    private var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    private init() {}
}

extension NotificationManager: NotificationManagerProtocol {
    
    func requestAuth(_ options: UNAuthorizationOptions) {
        notificationCenter.requestAuthorization(
            options: options
        ) { success, error in
            if success {
                print("SUCCESS")
            } else {
                print("ERROR:", error)
            }
        }
    }
    
    func scheduleNotification(
        for date: Date,
        formatString: String,
        title: String,
        body: String
    ) {
        
        let calender = Calendar.autoupdatingCurrent
        
        var comps = calender.dateComponents(
            [.day, .month, .year, .hour, .minute],
            from: date
        )
        
        comps.hour = Constants.defaultHour
        comps.minute = Constants.defaultMinute
        
        print(comps)
    }
}
