//
//  SceneDelegate.swift
//  FinalTesting
//
//  Created by Manish Chilwal on 26/10/25.
//

import UIKit
import Singular
import CleverTapSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navController = UINavigationController(rootViewController: HomeViewController())
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("Universal Link detected — forwarding to Singular")
        
        // Your Singular API credentials
        let apiKey = "key"
        let apiSecret = "secret"
        
        // Restart the Singular session with the Universal Link
        Singular.startSession(
            apiKey,
            withKey: apiSecret,
            andUserActivity: userActivity
        ) { params in
            // Handle deep link params here
            let deeplink = params?.getDeepLink()
            let urlParams = params?.getUrlParameters()
            
            print("Singular Deep Link Triggered via SceneDelegate")
            print("Deeplink: \(deeplink ?? "null")")
            
            if let urlParams = urlParams {
                print("URL Parameters:")
                for (key, value) in urlParams {
                    print("   \(key): \(value)")
                }
            }
            
            // MARK: Extract ct_msg_id (Campaign ID) from Deep Link
            if let deepLinkString = deeplink,
               let urlComponents = URLComponents(string: deepLinkString),
               let queryItems = urlComponents.queryItems,
               let ctMsgId = queryItems.first(where: { $0.name == "ct_msg_id" })?.value {
                
                print("Extracted ct_msg_id: \(ctMsgId)")
                
                // Create CleverTap-compatible payload
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                let dateSuffix = dateFormatter.string(from: Date())
                
                let payload: [String: Any] = [
                    "wzrk_acct_id": "R5K-486-ZW7Z", // CleverTap Account ID
                    "wzrk_id": "\(ctMsgId)_\(dateSuffix)",
                    "wzrk_c2a": deepLinkString,
                    "wzrk_pivot": "wzrk_default",
                    "wzrk_pn": "true"
                ]
                
                print("Raising CleverTap Push Notification Click Event with payload: \(payload)")
                
                // Send event to CleverTap
                CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: payload)
                print("CleverTap event raised successfully for campaign ID: \(ctMsgId)")
            } else {
                print("No ct_msg_id found in deep link URL")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
