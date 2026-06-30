//
//  SplashScreenVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import UIKit

class SplashScreenVC: BaseViewController {
    
    @IBOutlet weak var ivLogo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("========== SplashScreenVC Opened ==========")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Splash Screen Appeared")
        print("Waiting For 2 Seconds...")

        startLogoAnimation()
        
    }
    
    // MARK: - Start Logo Animation

        func startLogoAnimation() {

            print("Starting Logo Animation")

            UIView.animate(withDuration: 1.5,
                           animations: {

                // Scale Animation
                self.ivLogo.transform = CGAffineTransform(
                    scaleX: 1.2,
                    y: 1.2
                )

            }) { completed in

                print("Animation Completed")

                // Navigate after animation
                self.checkAppFlow()
            }
        }

    
    // MARK: - Check App Flow
    
    func checkAppFlow() {

        print("Checking First Launch Status...")

        let isFirstLaunch = PreferenceManager.shared.isFirstLaunch()
        let isLogin = PreferenceManager.shared.isLoggedIn()

        print("isFirstLaunch Value = \(isFirstLaunch)")

        if isFirstLaunch {
            
            if isLogin {
                NavigationManager.moveToNavigationController(
                    from: self,
                    storyboardName: "Main",
                    navigationControllerID: "MainNavigationController"
                )
//                NavigationManager.moveToScreen(
//                    from: self,
//                    viewControllerID: "MainPage"
//                )

            }else{
                NavigationManager.moveToNavigationController(
                    from: self,
                    storyboardName: "Auth",
                    navigationControllerID: "AuthNavigationController"
                )
            }

            

        } else {
            NavigationManager.moveToScreen(
                from: self,
                storyboardName: "Auth",
                viewControllerID: "InfoScreenVC"
            )
        }
    }
}
