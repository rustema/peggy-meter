//
//  AppDelegate.swift
//  Peggy Meter
//
//  Created by Artem Iglikov on 3/4/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseAuthUI



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
    
    func scheduleReminderNotification(_ reminders_enabled: Bool) {
        if #available(iOS 10.0, *) {
            if reminders_enabled {
                print("scheduling reminders")
                let content = UNMutableNotificationContent()
                content.body = "How do you feel?"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
                let request = UNNotificationRequest(identifier: "MoodLogReminder", content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
            } else {
                // Remove any outstanding reminder requests.
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("cancelling outstanding reminders")
            }
        }
    }

    // Handle Google and Facebook sign-in.
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            print("handling google url: \(String(describing: url))")
            return true
        }
        // other URL handling goes here.
        print("failure --> !!!")
        return false
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

        let defaults = UserDefaults()
        defaults.synchronize()
        if #available(iOS 10.0, *) {
            
            let reminders_enabled = defaults.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.RemindersEnabled)
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                self.scheduleReminderNotification(reminders_enabled)
            }
        }
        SettingsBundleHelper.setVersionAndBuildNumber()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

