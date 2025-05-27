//
//  NotificationsManager.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/18/25.
//

import Foundation
import UserNotifications
import UIKit
import SwiftUI
import FirebaseCore
import FirebaseMessaging
import Firebase

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled = false
    
    private init() {
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
                print("🔍 Notification status checked: \(self.isNotificationsEnabled)")
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("⚠️ Error requesting notifications permission: \(error)")
            }
            
            print("🔔 Notification permission granted: \(granted)")
            
            if granted {
                // Register with APNS only if permission granted
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.isNotificationsEnabled = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    completion(granted)
                }
            } else {
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        }
    }
    
    func subscribeToFavoriteUpdates(completion: @escaping (Bool) -> Void) {
        // First check if notifications are authorized
        checkNotificationStatus()
        
        if isNotificationsEnabled {
            // User has already authorized notifications, subscribe to topics
            subscribeToTopics(completion: completion)
        } else {
            // User hasn't authorized notifications yet, prompt them
            requestNotificationPermission { granted in
                if granted {
                    // Permission granted, now subscribe
                    self.subscribeToTopics(completion: completion)
                } else {
                    // Permission denied
                    completion(false)
                }
            }
        }
    }
    
    private func subscribeToTopics(completion: @escaping (Bool) -> Void) {
        // Subscribe to general updates
        Messaging.messaging().subscribe(toTopic: "updates") { error in
            if let error = error {
                print("❌ Failed to subscribe to updates topic: \(error)")
                completion(false)
                return
            }
            
            print("✅ Subscribed to topic: updates")
            
        }
    }
    
    func unsubscribeFromTopics(userId: String, completion: @escaping (Bool) -> Void) {
        Messaging.messaging().unsubscribe(fromTopic: "updates") { error in
            if let error = error {
                print("❌ Failed to unsubscribe from updates topic: \(error)")
                completion(false)
                return
            }
        }
    }
    
    func uploadFCMTokenToFirestore(userId: String) {
        guard let fcmToken = Messaging.messaging().fcmToken else {
            print("⚠️ FCM token not available")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("Users").document(userId).updateData([
            "fcmToken": fcmToken]
        ) { error in
            if let error = error {
                print("❌ Error uploading FCM token: \(error)")
            } else {
                print("✅ FCM token uploaded to Firestore for user: \(userId)")
            }
        }
    }
    
    func ensureFCMTokenIsReady(userId: String, completion: @escaping (Bool) -> Void) {
        // Check if we already have an FCM token
        if let fcmToken = Messaging.messaging().fcmToken {
            // We have a token, so we can proceed
            print("✅ FCM token already available: \(fcmToken)")
            completion(true)
            return
        }
        
        // We need to wait for the token to be generated
        // This generally happens after the APNs token is set
        var tokenRetries = 0
        let maxRetries = 5
        
        func checkForToken() {
            if let fcmToken = Messaging.messaging().fcmToken {
                // Token is ready
                print("✅ FCM token now available: \(fcmToken)")
                completion(true)
            } else if tokenRetries < maxRetries {
                // Try again in a moment
                tokenRetries += 1
                print("⏳ Waiting for FCM token - attempt \(tokenRetries)/\(maxRetries)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    checkForToken()
                }
            } else {
                // Give up
                print("❌ FCM token not available after \(maxRetries) attempts")
                completion(false)
            }
        }
        
        // Start checking
        checkForToken()
    }
}
