//
//  CommonsDiningApp.swift
//  CommonsDining
//
//  Created by Caden Cooley on 1/30/25.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseMessaging

@main
struct CommonsDiningApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("hasOnboarded") var hasOnboarded = false
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var menuViewModel = MenuPageViewModel()
    @StateObject var extraViewModel = ExtraInfoViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                NavigationStack {
                    TabHomeView()
                        .navigationBarHidden(true)
                }
                .environmentObject(homeViewModel)
                .environmentObject(menuViewModel)
                .environmentObject(extraViewModel)
                .environmentObject(profileViewModel)
                .environmentObject(NotificationManager.shared)
            }
            else {
                OnBoardingView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Set up messaging delegate
        Messaging.messaging().delegate = self
        
        // Note: We are NOT requesting notification permissions here anymore
        // This will be triggered by a button press instead
        
        if UserDefaults.standard.bool(forKey: "hasEnabledNotifications") {
            // Only register if user has already enabled notifications
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("📱 Registered with APNs: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📩 Received push in foreground")
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📲 Notification tapped by user")
        
        // Handle notification tap - you can add navigation logic here
        let userInfo = response.notification.request.content.userInfo
        print("📲 Notification payload: \(userInfo)")
        
        // Check if it's a favorites notification
        if let type = userInfo["type"] as? String, type == "favorite_items_available" {
            // You can post a notification to navigate to favorites
            NotificationCenter.default.post(
                name: Notification.Name("ShowFavoritesNotification"),
                object: nil,
                userInfo: userInfo
            )
        }
        
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM registration token: \(fcmToken ?? "nil")")
        
        // Store the token for later use
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "FCMToken")
        }
        
        // Note: We don't automatically subscribe to topics here anymore
        // This will happen when the user presses the notification permission button
    }
}
