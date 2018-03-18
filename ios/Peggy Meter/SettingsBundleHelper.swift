//
//  SettingsBundleHelper.swift
//  Peggy Meter
//
//  Created by Rustem Arzymbetov on 3/12/18.
//  Copyright © 2018 PeggyJo. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let RemindersEnabled = "reminders_enabled_preference"
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    /*
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.RemindersEnabled) {
            UserDefaults.standard.set(true, forKey: SettingsBundleKeys.RemindersEnabled)
            // Handle notifications.
            
            // Remove all persistent data.
            // let appDomain: String? = Bundle.main.bundleIdentifier
            // UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            // reset userDefaults..
            // CoreDataDataModel().deleteAllData()
            // delete all other user data here..
        } else {
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.RemindersEnabled)
        }
    }
    */
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.AppVersionKey)
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: SettingsBundleKeys.BuildVersionKey)
    }
}
