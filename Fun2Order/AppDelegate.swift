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

protocol ApplicationRefreshNotificationDelegate: class {
    func refreshNotificationList()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var myTabBar: UITabBar?
    weak var notificationDelegate: ApplicationRefreshNotificationDelegate?

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // When the app launch after user tap on notification (originally was not running / not in background)
        if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil) {
            let userInfos = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
            
            getLaunchNotification(user_infos: userInfos!)
        }
        
        return true
    }
    
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
            application.registerForRemoteNotifications()
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        Messaging.messaging().delegate = self
        
        getNotifications(completion: refreshNotifyList)
        signOutForFirstRun()
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("**************************************")
        print("********** Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            self.saveInstanceID(instance_id: result.token)
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
        print("application didReceiveRemoteNotification")
        getNotifications(completion: refreshNotifyList)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("-------- userNotificationCenter  didReceive response")
        getNotifications(completion: refreshNotifyList)
        completionHandler()

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("-------- userNotificationCenter willPresent")
        getTappedNotification(notification: notification)
        self.notificationDelegate?.refreshNotificationList()
        
        let isReadFlag = notification.request.content.userInfo["isRead"] as! String
        if isReadFlag == "Y" {
            completionHandler([])
        } else {
            completionHandler(UNNotificationPresentationOptions.alert)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("-------- applicationWillResignActive")
        getNotifications(completion: refreshNotifyList)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("-------- applicationDidEnterBackground")
        getNotifications(completion: refreshNotifyList)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("-------- applicationWillEnterForeground")
        getNotifications(completion: refreshNotifyList)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("-------- applicationDidBecomeActive")
        getNotifications(completion: refreshNotifyList)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("-------- applicationWillTerminate")
    }

    func refreshNotifyList() {
        self.notificationDelegate?.refreshNotificationList()
    }
    
    func signOutForFirstRun() {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            print("------ AppDelegate -> First run for Fun2Order ------")
            //if app is first time opened then it will be nil
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            // signOut from FIRAuth
            do {
                try Auth.auth().signOut()
            }catch {
                print(error.localizedDescription)
            }
        } else {
            print("------ AppDelegate -> Not first run for Fun2Order ------")
        }
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
        
        //if let user_id = Auth.auth().currentUser?.uid {
        //    uploadUserProfileTokenID(user_id: user_id, token_id: instance_id)
        //}
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

