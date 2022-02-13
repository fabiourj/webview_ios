//  OnlineAppCreator.com
//  WebViewGold for iOS // webviewgold.com

/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */
/* PLEASE CHECK CONFIG.SWIFT FOR CONFIGURATION */

import UIKit
import UserNotifications
import OneSignal
import GoogleMobileAds
import Firebase
import FirebaseMessaging
import SwiftyStoreKit
import AVFoundation
import FBAudienceNetwork
import AppTrackingTransparency


@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.applicationIconBadgeNumber = 0
        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        
        if (Constants.kFirebasePushEnabled)
        {
            UIApplication.shared.registerForRemoteNotifications()
            FirebaseApp.configure()
            registerForPushNotifications(application: application)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: Notification.Name.InstanceIDTokenRefresh, object: nil)
            
            connectToFcm()
            
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                    UserDefaults.standard.set("", forKey: "FirebaseID")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    UserDefaults.standard.set(result.token, forKey: "FirebaseID")
                    self.connectToFcm()
                }
            }
        }
       
       
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break 
                @unknown default:
                    break 
                }
            }
        }
        
        
        
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body

            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
            }
        }
        if Constants.kPushEnabled
        {
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                         kOSSettingsKeyInAppLaunchURL: true]
            
            
            OneSignal.initWithLaunchOptions(launchOptions,appId: Constants.oneSignalID,handleNotificationAction: {(result) in let payload = result?.notification.payload
                if let additionalData = payload?.additionalData {
                    
                    var noti_url = ""
                    if additionalData["url"] != nil {
                    noti_url = additionalData["url"] as! String
                    }
                    UserDefaults.standard.set(noti_url, forKey: "Noti_Url")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OpenWithNotificationURL"), object: nil, userInfo: nil)
                    
                }},settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
            
        }
        if (Constants.showBannerAd || Constants.showFullScreenAd) {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        if UserDefaults.standard.value(forKey: "IsPurchase") == nil
        {
            UserDefaults.standard.setValue("NO", forKey: "IsPurchase")
        }
        
        if askforpushpermissionatfirstrun {
            registerForPushNotifications(application: application)
        }
        
        
        if Constants.kPushEnabled
        {
            if askforpushpermissionatfirstrun {
                
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    print("User accepted notifications: \(accepted)")
                })
                if application.responds(to: #selector(getter: application.isRegisteredForRemoteNotifications))
                {
                    if #available(iOS 10.0, *)
                    {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {(accepted, error) in
                            if !accepted {
                                print("Notification access denied")
                            }
                        }
                    }
                    else
                    {
                        application.registerUserNotificationSettings(UIUserNotificationSettings(types: ([.sound, .alert, .badge]), categories: nil))
                        application.registerForRemoteNotifications()
                    }
                }
                else
                {
                    let center = UNUserNotificationCenter.current()
                            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                                // Enable or disable features based on authorization.
                            }
                            application.registerForRemoteNotifications()
                }
            }
            
            return true
        }
        
        return true
    }
    
    func deactivatedarkmode() -> String {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        } else {
        }
        return "OK"
        
    }
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        let sendingAppID = options[.sourceApplication]
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let _ = components.path,
            let params = components.queryItems else {
                return false
        }
        
        if let url  = params.first(where: { $0.name == "link" })?.value {
            UserDefaults.standard.set(url, forKey: "DeepLinkUrl")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OpenWithExternalLink"), object: nil, userInfo: nil)
            
            return true
        } else {
            print("URL missing")
            return false
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {


    do {
    if #available(iOS 11.0, *) {
    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longForm, options: [.mixWithOthers, .allowAirPlay])
    } else {
    }
    try AVAudioSession.sharedInstance().setActive(true)
    } catch {
    print(error)
    }

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    switch status {
                    case .authorized:
                        // Tracking authorization dialog was shown
                        // and we are authorized
                        print("Authorized")
                    case .denied:
                        // Tracking authorization dialog was
                        // shown and permission is denied
                        print("Denied")
                        Constants.useFacebookAds = false;
                        showBannerAd = false;
                        showFullScreenAd = false;
                    case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        print("Not Determined")
                        Constants.useFacebookAds = false;
                        showBannerAd = false;
                        showFullScreenAd = false;
                    case .restricted:
                        print("Restricted")
                        Constants.useFacebookAds = false;
                        showBannerAd = false;
                        showFullScreenAd = false;
                    @unknown default:
                        print("Unknown")
                    }
                })
            }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    func registerForPushNotifications(application: UIApplication)
    {
        if #available(iOS 11.0, *)
        {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            print("Notification: registration for iOS >= 11 using UNUserNotificationCenter")
        }
        else
        {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            print("Notification: registration for iOS < 10 using Basic Notification Center")
        }
        
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    @objc func tokenRefreshNotification(_ notification: Notification)
    {
        connectToFcm()
    }
    
    func connectToFcm()
    {
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                UserDefaults.standard.set("", forKey: "FirebaseID")
                print("Error fetching remote instange ID: \(error)")
                print("FCM: Token does not exist.")
                return
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey: "FirebaseID")
                Messaging.messaging().shouldEstablishDirectChannel = true
                Messaging.messaging().shouldEstablishDirectChannel = false
                
            }
        }
        
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Notification: Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        
        let state : UIApplication.State = application.applicationState
        switch state
        {
        case .active:
            print("Application is in Active Mode!")
        case .inactive:
            if let x = userInfo["custom"] as? [AnyHashable: Any] {
                if let y = x["a"] as? [String:String] {
                    guard y["url"] != nil else {return}
                    let noti_url = y["url"]!
                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                        UserDefaults.standard.set(noti_url, forKey: "Noti_Url")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OpenWithNotificationURL"), object: nil, userInfo: nil)
                    })
                }
                
                
            }
        case .background:
            print("Application is in Backgound mode!")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
}


