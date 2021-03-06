//
//  AppDelegate.swift
//  Music
//
//  Created by PAC on 9/26/17.
//  Copyright © 2017 PAC. All rights reserved.
//   563bfd2b-92f0-49eb-93d6-166ba2926e19

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver {
    
    var window: UIWindow?
    
    var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    var notificationReceivedBlock: OSHandleNotificationReceivedBlock?
    var notificationOpenedBlock: OSHandleNotificationActionBlock?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let checkStates = UserDefaults.standard.value(forKey: "states") as? [Int] {
            SongArrays.checkState = checkStates
        }
        self.launchOptions = launchOptions
        self.setupOneSignal(launchOptions: launchOptions)
        
        self.determineAndLoadInitialVC()
        
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
    }
    
    
}

//MARK: setup first controller
extension AppDelegate: TutorialDelegate {
    
    func tutorialFinished(tutorialVC: TutorialController) {
        
        
        self.makeHomeControllerAsFirstController()
    }
    
    fileprivate func determineAndLoadInitialVC() {
        
        let userDefaults = UserDefaults.standard
        //        userDefaults.setValue(false, forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
        //        userDefaults.synchronize()
        let hasSeenTutorial = userDefaults.bool(forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
        
        if hasSeenTutorial {
            self.makeHomeControllerAsFirstController()
        } else {
            self.makeTutorialViewAsFirstController()
            userDefaults.setValue(true, forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
            userDefaults.synchronize()
        }
    }
    
    private func makeTutorialViewAsFirstController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tutorialController = TutorialController()
        tutorialController.delegate = self
        self.window?.rootViewController = tutorialController
        self.window?.makeKeyAndVisible()
    }
    
    private func makeHomeControllerAsFirstController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let rootController = HomeController()
        let navController = UINavigationController(rootViewController: rootController)
        window?.rootViewController = navController
        
        navController.navigationBar.barTintColor = StyleGuideManager.loginBackgroundColor
        navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
}

//MARK: setup onesignal

extension AppDelegate {
    fileprivate func setupOneSignal(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        notificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            
            let state: UIApplicationState = UIApplication.shared.applicationState
            if state == UIApplicationState.background {
                
            } else if state == UIApplicationState.active {
                
            }
            
            
        }
        
        notificationOpenedBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body)")
            print("badge number = \(payload?.badge)")
            print("notification sound = \(payload?.sound!)")
            
            let state: UIApplicationState = UIApplication.shared.applicationState
            if state == UIApplicationState.background {
                
                if let additionalData = result!.notification.payload!.additionalData {
                    
                }
            } else if state == UIApplicationState.active {
                
            } else if state == UIApplicationState.inactive {
                
            }
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("do something when button 2 is pressed")
                        
                        
                    } else if actionID == "id1" {
                        print("do something when button 1 is pressed")
                        
                    }
                }
            }
        }
        
        
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.setupOnesignalObserver), name: .SetupOneSignal, object: nil)
    }
    
    @objc fileprivate func setupOnesignalObserver() {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace '11111111-2222-3333-4444-0123456789ab' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "12f68875-52f1-4290-862d-4b1b7e174d02", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let hasPrompted = status.permissionStatus.hasPrompted
        if hasPrompted == false {
            // Call when you want to prompt the user to accept push notifications.
            // Only call once and only if you set kOSSettingsKeyAutoPrompt in AppDelegate to false.
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                if accepted == true {
                    print("User accepted notifications: \(accepted)")
                } else {
                    print("User accepted notificationsfalse: \(accepted)")
                }
            })
        } else {
        }
        
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        
    }
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
}

