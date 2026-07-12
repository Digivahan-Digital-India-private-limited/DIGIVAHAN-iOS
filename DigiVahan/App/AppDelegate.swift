//
//  AppDelegate.swift
//  DigiVahan
//
//  Created by Mr Ash on 11/05/26.
//

import UIKit
import OneSignalFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate,
                   OSNotificationLifecycleListener,
                   OSNotificationClickListener {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        print("🚀 AppDelegate Started")
        print("Launch Options:", launchOptions ?? [:])
        
        CommonFunctions.fetchAppInfo()

        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
        UNUserNotificationCenter.current().delegate = self

        OneSignal.initialize(
            "6841c599-0740-4059-aa80-b4a2396ff67e",
            withLaunchOptions: launchOptions
        )
        
        // 👇 ADD THIS HERE
           if let path = Bundle.main.path(forResource: "no_parking", ofType: "caf") {
               print("✅ Found:", path)
           } else {
               print("❌ no_parking.caf NOT FOUND")
           }
        
        // For the OSNotificationClickListener
        OneSignal.Notifications.addClickListener(self)
        OneSignal.Notifications.addForegroundLifecycleListener(self)
        
        OneSignal.Notifications.requestPermission({ _ in }, fallbackToSettings: true)

        
       
        OneSignal.User.pushSubscription.addObserver(self)


//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//            print("Subscription ID:", OneSignal.User.pushSubscription.id ?? "nil")
//
//            print("Push Token:", OneSignal.User.pushSubscription.token ?? "nil")
//
//            print("Opted In:", OneSignal.User.pushSubscription.optedIn)
//
//            print("Permission:", OneSignal.Notifications.permission)
//
//            print("Permission Native:", OneSignal.Notifications.permissionNative)
//            
//            print("User Id:", PreferenceManager.shared.getUserId())
//        }
        
        

        return true
    }
    
    // Add the required onClick method for OSNotificationClickListener
      func onClick(event: OSNotificationClickEvent) {
          print("=================================")
             print("Notification Clicked")
             print(event.jsonRepresentation())
             print("=================================")

             let notification = event.notification
//
//             print("Title:", notification.title ?? "")
//             print("Body:", notification.body ?? "")
//             print("Launch URL:", notification.launchURL ?? "nil")
//
//             print("Additional Data:")
//             print(notification.additionalData ?? [:])
          
        // Access notification data
//        let title = notification.title ?? ""
//        let body = notification.body ?? ""
        let additionalData = notification.additionalData ?? [:] // Custom key-value pairs you sent
          
          let notificationType = additionalData["notification_type"] as? String ?? ""
              let issueType = additionalData["issue_type"] as? String ?? ""
              let vehicleId = additionalData["vehicle_id"] as? String ?? ""
              let senderId = additionalData["sender_id"] as? String ?? ""
              let chatRoomId = additionalData["chat_room_id"] as? String ?? ""
              let orderId = additionalData["order_id"] as? String ?? ""
              let latitude = additionalData["latitude"] as? String ?? ""
              let longitude = additionalData["longitude"] as? String ?? ""
          
          
        // Example: Deep link based on custom data
          if notificationType == "vehicle" || notificationType == "chat" {
              
              PreferenceManager.shared.setBool(value: true, key: PreferenceManager.Keys.NOTIFICATION_CLICKED)
              
              PreferenceManager.shared.setString(value: notificationType, key: PreferenceManager.Keys.NOTIFICATION_TYPE_TEMP)
              PreferenceManager.shared.setString(value: senderId, key: PreferenceManager.Keys.NOTIFICATION_SENDER_ID_TEMP)
              
              PreferenceManager.shared.setString(value: vehicleId, key: PreferenceManager.Keys.NOTIFICATION_VEHICLE_ID_TEMP)
              
              PreferenceManager.shared.setString(value: chatRoomId, key: PreferenceManager.Keys.NOTIFICATION_CHAT_ROOM_ID_TEMP)
              
//              var notificationListItem = NotificationItemModel()
//
//              notificationListItem.notification_title = title
//              notificationListItem.message = body
//              notificationListItem.notification_type = notificationType
//              notificationListItem.issue_type = issueType
//              notificationListItem.vehicle_id = vehicleId
//              notificationListItem.sender_id = senderId
//              notificationListItem.chat_room_id = chatRoomId
//              notificationListItem.order_id = orderId
//              notificationListItem.latitude = latitude
//              notificationListItem.longitude = longitude
              
             
//              let sharedData: [String: Any] = [
//                  "notificationListItem": notificationListItem
//              ]
//
//              if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                 let window = windowScene.windows.first,
//                 let nav = window.rootViewController as? UINavigationController {
//
//                  NavigationManager.pushScreen(
//                      from: nav.topViewController!,
//                      storyboardName: "Main",
//                      viewControllerID: "ViewNotificationVC",
//                      data: sharedData
//                  )
//              }
          }
      }

    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let token = deviceToken.map {
            String(format: "%02x", $0)
        }.joined()

    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {

        print("🔴 APNS ERROR")
        print(error.localizedDescription)
    }

    func onWillDisplay(
        event: OSNotificationWillDisplayEvent
    ) {

        print(event.notification.additionalData ?? [:])

        event.notification.display()
    }

    
}

extension AppDelegate: OSPushSubscriptionObserver {

    func onPushSubscriptionDidChange(
        state: OSPushSubscriptionChangedState
    ) {

        print(state.current.id ?? "")
        print(state.current.token ?? "")

        let userId = PreferenceManager.shared.getUserId()

        if !userId.isEmpty {
            OneSignal.login(userId)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            // Fallback on earlier versions
        }
    }
}
