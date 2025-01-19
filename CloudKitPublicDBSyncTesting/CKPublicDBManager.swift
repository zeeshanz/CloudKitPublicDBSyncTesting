//
//  CKPublicDBManager.swift
//  CloudKitPublicDBSyncTesting
//
//  Created by Zeeshan A Zakaria on 2025-01-19.
//

import CoreData
import CloudKit

class CKPublicDBManager {
    
    let SUBSCRIPTION_ID = "CloudKitPublicDBSyncTesting"
    let CLOUD_KIT = "iCloud.com.company.DemoApp"
    
    class var sharedInstance: CKPublicDBManager {
        struct Singleton {
            static let instance = CKPublicDBManager()
        }
        
        return Singleton.instance
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "MyDatabase") // Name of the database entity on the local device
        
        let store = container.persistentStoreDescriptions.first!
        let storesURL = store.url!.deletingLastPathComponent()
        store.url = storesURL.appendingPathComponent("public.sqlite")
        store.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        store.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        store.cloudKitContainerOptions?.databaseScope = .public
        
        let database = CKContainer(identifier: CLOUD_KIT).publicCloudDatabase
        let subscription = CKQuerySubscription(recordType: "CD_Item", predicate: NSPredicate(value: true), subscriptionID: SUBSCRIPTION_ID, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])

        database.fetchAllSubscriptions { subscriptions, error in
            if let error = error {
                print("Failed to fetch subscriptions: \(error.localizedDescription)")
                return
            }
            
            // Check if the subscription already exists
            if subscriptions?.contains(where: { $0.subscriptionID == self.SUBSCRIPTION_ID }) == false {
                let subscription = CKQuerySubscription(
                    recordType: "CD_Item",
                    predicate: NSPredicate(value: true),
                    subscriptionID: self.SUBSCRIPTION_ID,
                    options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate]
                )
                
                let notification = CKSubscription.NotificationInfo()
                notification.shouldSendContentAvailable = true
                notification.alertBody = "There's a new change in the db."
                subscription.notificationInfo = notification
                
                database.save(subscription) { result, error in
                    if let error = error {
                        print("Error saving subscription: \(error.localizedDescription)")
                    } else {
                        print("Subscription saved successfully: \(result?.subscriptionID ?? "Unknown")")
                    }
                }
            }
        }

        //Load the persistent stores
        container.loadPersistentStores(completionHandler: { (success, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        })
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
