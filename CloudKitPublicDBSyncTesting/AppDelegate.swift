//
//  AppDelegate.swift
//  CloudKitPublicDBSyncTesting
//
//  Created by Zeeshan A Zakaria on 2025-01-19.
//

import UIKit
import CoreData
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var caloriesFromNotification: Float?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initializing the databases as first thing so that CK is synced and ready.
        _ = CKPublicDBManager.sharedInstance.persistentContainer.viewContext
        
        application.registerForRemoteNotifications() // This is required to receive CloudKit's notificattions
        
        return true
    }
    
    func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

// MARK: Notifications

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Remote notification received")
        
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print("CloudKit database changed")
            print("\(notification)")
            NotificationCenter.default.post(name: .CKAccountChanged, object: nil)
            completionHandler(.newData)
            return
        }
    }
}
