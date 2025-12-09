//
//  AppDelegate.swift
//  FinalTesting
//
//  Created by Manish Chilwal on 26/10/25.
//

import UIKit
import CleverTapSDK
import Singular

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // MARK: - Singular Setup
        if let config = getSingularConfig() {
            Singular.start(config)
            print("Singular SDK initialized successfully")
        } else {
            print("Failed to initialize Singular SDK config")
        }
        
        // MARK: - CleverTap Setup
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.autoIntegrate()
        
        let consentDict: [String: [String]] = [
            "toRemove": ["Recommendation", "Marketing"],
            "toAdd": ["Offers"]
        ]

        if let valuesToAdd = consentDict["toAdd"] {
            CleverTap.sharedInstance()?.profileAddMultiValues(valuesToAdd, forKey: "PushConsent")
        }

        if let valuesToRemove = consentDict["toRemove"] {
            CleverTap.sharedInstance()?.profileRemoveMultiValues(valuesToRemove, forKey: "PushConsent")
        }
        
        
        registerForPush()
        
        // Initialize App Inbox
        CleverTap.sharedInstance()?.initializeInbox(callback: { success in
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount() ?? 0
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount() ?? 0
            print("CleverTap App Inbox initialized: \(success)")
            print("Total Messages: \(messageCount), Unread: \(unreadCount)")
        })
        

        return true
    }
    
    // MARK: - Singular Config
    func getSingularConfig() -> SingularConfig? {
        // Create config with API credentials
        guard let config = SingularConfig(apiKey: "divyekant_a545dc1d", andSecret: "790a4a5262be5317a364daee905bcc38") else {
            return nil
        }
        
        // Set deep link handler
        config.singularLinksHandler = { params in
            self.handleDeeplink(params: params)
        }
        
        if let ctId = CleverTap.sharedInstance()?.profileGetAttributionIdentifier() {
            config.setGlobalProperty("CLEVERTAPID", withValue: ctId, overrideExisting: true)
            print("Configured Singular global property: CLEVERTAPID = \(ctId)")
        } else {
            print("CleverTap attribution ID not available at launch")
        }
        
        return config
    }
    
    // MARK: - Singular Deep Link Handler
    func handleDeeplink(params: SingularLinkParams?) {
        print("Singular Link Handler Triggered")

        // Get Deeplink data from Singular Link
        let deeplink = params?.getDeepLink()
        let passthrough = params?.getPassthrough()
        let isDeferred = params?.isDeferred()
        let urlParams = params?.getUrlParameters()
        
        print("Deeplink: \(deeplink ?? "null")")
        print("Passthrough: \(passthrough ?? "null")")
        print("Is Deferred: \(isDeferred ?? false)")
        
        // Print all URL parameters
        if let urlParams = urlParams {
            for (key, value) in urlParams {
                print("   \(key): \(value)")
            }
        }
        
        // Handle deep link routing
        if let url = deeplink {
            handleDeepLinkRouting(url: url, isDeferred: isDeferred ?? false)
        }
    }
    
    // MARK: - Deep Link Routing
    func handleDeepLinkRouting(url: String, isDeferred: Bool) {
        print("Handle deep link routing for URL: \(url), deferred: \(isDeferred)")
    }
    
    // MARK: - Helper: Update Single CleverTap Property
    func updateSingleUserProperty(key: String, value: String) {
        let encodedValue = String(data: value.data(using: .utf8) ?? Data(), encoding: .utf8) ?? value
        let profileUpdate: [String: Any] = [key: encodedValue]
        CleverTap.sharedInstance()?.profilePush(profileUpdate)
        print("Updated CleverTap user property → \(key): \(encodedValue)")
    }
    
    func registerForPush() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
    
    // MARK: - Deep Link Handling (open URL)
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("Received URL: \(url.absoluteString)")
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}
