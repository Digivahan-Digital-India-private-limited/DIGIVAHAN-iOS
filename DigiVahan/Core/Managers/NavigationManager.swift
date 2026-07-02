//
//  NavigationManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import UIKit

class NavigationManager {
    
    /*
     Move Without Data
    NavigationManager.moveToScreen(
        from: self,
        viewControllerID: "HomeVC"
    )
     
   
     
     // if the different screen in same storyboard
     NavigationManager.moveToScreen(
         from: self,
         storyboardName: "Auth",
         viewControllerID: "LoginScreenVC"
     )
     
     send and Receive Data
     
     Move With Data
     NavigationManager.moveToScreen(
         from: self,
         storyboardName: "Auth",
         viewControllerID: "VerificationScreenVC",
         data: [
             "phone": phone,
             "password": password
         ]
     )

     Inside next screen:

     override func viewDidLoad() {
         super.viewDidLoad()

         if let data = receivedData as? [String: Any] {

             let phone = data["phone"] as? String ?? ""
             let password = data["password"] as? String ?? ""

             print(phone)
             print(password)
         }
     }
     */
    

    // MARK: - Root Navigation
    static func moveToScreen(
        from currentVC: UIViewController,
        storyboardName: String = "Main",
        viewControllerID: String,
        data: Any? = nil
    ) {

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        if let nextVC = storyboard.instantiateViewController(
            withIdentifier: viewControllerID
        ) as? BaseViewController {

            // Pass data if available
            nextVC.receivedData = data

            currentVC.view.window?.rootViewController = nextVC
            currentVC.view.window?.makeKeyAndVisible()
        }
    }


    // MARK: - Push Navigation
    // MARK: - Push Navigation
    static func pushScreen(
        from currentVC: UIViewController,
        storyboardName: String = "Main",
        viewControllerID: String,
        closeCurrentScreen: Bool = false,
        data: Any? = nil
    ) {

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        if let nextVC = storyboard.instantiateViewController(
            withIdentifier: viewControllerID
        ) as? BaseViewController {

            nextVC.receivedData = data

            if closeCurrentScreen,
               var viewControllers = currentVC.navigationController?.viewControllers {

                // Remove current screen
                viewControllers.removeLast()

                // Add next screen
                viewControllers.append(nextVC)

                currentVC.navigationController?.setViewControllers(
                    viewControllers,
                    animated: true
                )

            } else {

                // Normal push
                currentVC.navigationController?.pushViewController(
                    nextVC,
                    animated: true
                )
            }
        }
    }


    // MARK: - Present Navigation
    static func presentScreen(
        from currentVC: UIViewController,
        storyboardName: String = "Main",
        viewControllerID: String,
        data: Any? = nil
    ) {

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        if let nextVC = storyboard.instantiateViewController(
            withIdentifier: viewControllerID
        ) as? BaseViewController {

            nextVC.receivedData = data

            currentVC.present(nextVC, animated: true)
        }
    }
    
    
    // MARK: - open Navigation controller
    static func moveToNavigationController(
        from currentVC: UIViewController,
        storyboardName: String = "Main",
        navigationControllerID: String
    ) {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        let navVC = storyboard.instantiateViewController(
            withIdentifier: navigationControllerID
        )

        currentVC.view.window?.rootViewController = navVC
        currentVC.view.window?.makeKeyAndVisible()
    }
}
