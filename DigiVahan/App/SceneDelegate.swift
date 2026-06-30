//
//  SceneDelegate.swift
//  DigiVahan
//
//  Created by Mr Ash on 11/05/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    // This method is called when the app scene is created and attached
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        // Convert generic UIScene into UIWindowScene
        // If conversion fails then stop execution
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create the main app window
        // Similar to setting root activity in Android
        window = UIWindow(windowScene: windowScene)

        // Load Auth.storyboard file
        // bundle: nil means current app bundle
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)

        // Create instance of InfoScreenVC from Auth.storyboard
        // "InfoScreenVC" must match Storyboard ID exactly
        let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoScreenVC")

        // Add navigation support
        // Similar to Fragment backstack/navigation in Android
        let navController = UINavigationController(rootViewController: infoVC)

        // Set first screen of application
        // App will open this controller first
        window?.rootViewController = navController

        // Make window visible on screen
        // Without this app screen will stay blank
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

