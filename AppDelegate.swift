//
//  AppDelegate.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 5/5/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit
//import GSTouchesShowingWindow_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    

    var window: UIWindow?
    /*
    var customWindow: GSTouchesShowingWindow?
    var window: UIWindow? {
        get {
            customWindow = customWindow ?? GSTouchesShowingWindow(frame: UIScreen.main.bounds)
            return customWindow
        }
        set { }
    }
     */

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 0.5)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        
        
        // Check to see if onboarding screens should be presented
        if let onboardedUser = UserDefaults.standard.value(forKey: "onboardedUser") as? Bool {
            
            if onboardedUser {
                let homeNavVC = mainStoryboard.instantiateViewController(withIdentifier: "baseNavVC") as! BaseNavigationController
                window?.rootViewController = homeNavVC
            }
            
            
        } else {
            
            // Set the boolean flag to true as user has been onboarded
            let onboardingNavVC = mainStoryboard.instantiateViewController(withIdentifier: "onboardingNavVC") as! OnboardingNavVC
            window?.rootViewController = onboardingNavVC
            UserDefaults.standard.setValue(true, forKey: "onboardedUser")
        }
        
        self.window?.makeKeyAndVisible()
        
        
        // Get the session ID for this app launch
        let sessionID = UUID().uuidString
        Log.sessionID = sessionID
        //UserDefaults.standard.set(sessionID, forKey: "sessionID")
        
        
        // Create UUID for this user to be used for logging and store it in UserDefault
        // to be retrieved everytime the app is launched
        if let userUUID = UserDefaults.standard.value(forKey: "userUUID") as? String {
            Log.userUUID = userUUID
        } else {
            // UserUID does not exist. Create one and store it
            let userUUID = UUID().uuidString
            UserDefaults.standard.set(userUUID, forKey: "userUUID")
            Log.userUUID = userUUID
            ParticipantViewController.userName = userUUID
        }
        
        
        // Check if the participantID has been set
        if let participantID = UserDefaults.standard.value(forKey: "participantID") as? String {
            Log.participantID = participantID
        } else {
            
            // ParticipantID does not exist. Create one and store it
            let uuid = UUID().uuidString
            let participantID = uuid.components(separatedBy: "-").first ?? "0ADE198"
            print("Participant ID: \(participantID)")
            UserDefaults.standard.set(participantID, forKey: "participantID")
            Log.participantID = participantID
        }
        
        
        Log.userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(ParticipantViewController.userName)")
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: Log.userDirectory.path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: Log.userDirectory.path, withIntermediateDirectories: true, attributes: nil)
                print("directory is created. \(Log.userDirectory.path)")
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        } else {
            print("The directory exists. \(Log.userDirectory.path)")
        }
        
        Log.writeToLog(Actions.appLaunched.rawValue)
        
        return true
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
        
        Log.writeToLog(Actions.appTerminated.rawValue)
    }


}

