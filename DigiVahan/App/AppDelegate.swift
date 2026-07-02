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

        OneSignal.Debug.setLogLevel(.LL_VERBOSE)

        OneSignal.initialize(
            "6841c599-0740-4059-aa80-b4a2396ff67e",
            withLaunchOptions: launchOptions
        )

        OneSignal.Notifications.requestPermission(
            { accepted in
                print("Permission accepted:", accepted)
            },
            fallbackToSettings: true
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {

            print("✅ OneSignal initialized")

            print("Subscription ID:",
                  OneSignal.User.pushSubscription.id ?? "nil")

            print("Push Token:",
                  OneSignal.User.pushSubscription.token ?? "nil")
        }

        return true
    }

    func onWillDisplay(
        event: OSNotificationWillDisplayEvent
    ) {

        print("Notification received")
        print(event.notification.additionalData ?? [:])

        event.notification.display()
    }

    func onClick(
        event: OSNotificationClickEvent
    ) {

        let data = event.notification.additionalData

        let notificationType =
            data?["notification_type"] as? String ?? ""

        let chatRoomId =
            data?["chat_room_id"] as? String ?? ""

        let senderId =
            data?["sender_id"] as? String ?? ""

        let vehicleId =
            data?["vehicle_id"] as? String ?? ""

        print("Notification clicked")
        print(notificationType)
        print(chatRoomId)
        print(senderId)
        print(vehicleId)
    }
}
