//
//  AppDelegate.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/8.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var myTabBar: UITabBar?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        writeFirebaseConfig()
        writeAppConfig()
        writeSetupConfig()
        FirebaseApp.configure()

        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["2077ef9a63d2b398840261c8221a0c9b"]
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        //deleteAllNotifications()
        getNotifications()
        NotificationCenter.default.post(name: NSNotification.Name("RefreshNotificationList"), object: nil)
        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            self.saveInstanceID(instance_id: result.token)
            //self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
          }
        }
    }

    private func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("application didRegisterForRemoteNotificationsWithDeviceToken")
        Messaging.messaging().apnsToken = deviceToken as Data
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        getNotifications()
        NotificationCenter.default.post(name: NSNotification.Name("RefreshNotificationList"), object: nil)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let userInfo = notification.request.content.userInfo
        //print(userInfo)
        //getNotifications()
        print("notification.request.identifier = \(notification.request.identifier)")
        setupNotification(notity: notification)
        setNotificationBadgeNumber()
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        //center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        // Change this to your preferred presentation option
        NotificationCenter.default.post(name: NSNotification.Name("RefreshNotificationList"), object: nil)
        completionHandler(UNNotificationPresentationOptions.alert)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func writeFirebaseConfig() {
        let fm = FileManager.default
        let src = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let dst = NSHomeDirectory() + "/Documents/GoogleService-Info.plist"
        
        if !fm.fileExists(atPath: dst) {
            try! fm.copyItem(atPath: src!, toPath: dst)
        }
    }

    func writeAppConfig() {
        let fm = FileManager.default
        let src = Bundle.main.path(forResource: "AppConfig", ofType: "plist")
        let dst = NSHomeDirectory() + "/Documents/AppConfig.plist"
        
        if !fm.fileExists(atPath: dst) {
            try! fm.copyItem(atPath: src!, toPath: dst)
        }
    }

    func writeSetupConfig() {
        let fm = FileManager.default
        let src = Bundle.main.path(forResource: "MyProfile", ofType: "plist")
        let dst = NSHomeDirectory() + "/Documents/MyProfile.plist"
        
        if !fm.fileExists(atPath: dst) {
            try! fm.copyItem(atPath: src!, toPath: dst)
        }
    }
    
    func saveInstanceID(instance_id: String) {
        let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["FirebaseInstanceID"] = instance_id
            
            if !plist.write(toFile: path, atomically: true) {
                print("Save AppConfig.plist failed")
            }
        }
        
        if let user_id = Auth.auth().currentUser?.uid {
            uploadUserProfileTokenID(user_id: user_id, token_id: instance_id)
        }
    }
    
    @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Fun2Order")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print(error.localizedDescription)
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
    }

}

