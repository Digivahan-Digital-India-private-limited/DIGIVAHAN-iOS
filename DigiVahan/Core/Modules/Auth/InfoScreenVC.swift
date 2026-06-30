//
//  InfoScreenVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 12/05/26.
//

import UIKit

class InfoScreenVC: BaseViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var introImage: UIImageView!
    @IBOutlet weak var indicatorIcon: UIImageView!
    @IBOutlet weak var introTitle: UILabel!
    @IBOutlet weak var introDescription: UILabel!
    
    // Track current intro page
        var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Login Screen Opened")
    }


    // MARK: - Skip Button Click
    @IBAction func skipButtonClick(_ sender: UIButton) {
        print("Skip Button Click")
        moveToLoginScreen()
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if currentPage == 1 {
                    currentPage = 2
                    loadSecondScreen()

                }else if currentPage == 2 {
                    currentPage = 3
                    loadThirdScreen()

                }else if currentPage == 3 {
                    currentPage = 4
                    loadFourthcreen()
                } else {
                    moveToLoginScreen()
                }
    }
    
    
    // Functions....
    
    // MARK: - Move To Main Screen
    func moveToLoginScreen() {
        // Save first launch completed
            PreferenceManager.shared.setFirstLaunch(true)
        NavigationManager.moveToNavigationController(
            from: self,
            storyboardName: "Auth",
            navigationControllerID: "AuthNavigationController"
        )
    }
    
    // MARK: - Second Intro Screen
        func loadSecondScreen() {

            introImage.image = UIImage(named: "InfoScreen2")
            indicatorIcon.image = UIImage(named: "info_indicator2")

            introTitle.text = "Nearby Essentials"

            introDescription.text = "Find nearby services like mechanics, petrol pumps, and towing – all based on your current location, just one tap away."

            nextButton.setTitle("Next", for: .normal)
        }
    
    // MARK: - Third Intro Screen
        func loadThirdScreen() {

            introImage.image = UIImage(named: "InfoScreen3")
            indicatorIcon.image = UIImage(named: "info_indicator3")

            introTitle.text = "Vehicle Info & Challan"

            introDescription.text = "Check challans, insurance, and PUC details of any vehicle with ease. All info comes from trusted government sources."

            nextButton.setTitle("Next", for: .normal)
        }

        // MARK: - Fourth Intro Screen
        func loadFourthcreen() {

            introImage.image = UIImage(named: "splash_logo")
            indicatorIcon.image = UIImage(named: "info_indicator4")

            introTitle.text = "Welcome to Digivahan"

            introDescription.text = "Simplifying the way you connect with vehicles. From instant owner contact to complete vehicle info – everything is just a tap away."

            nextButton.setTitle("Get Started", for: .normal)
        }

    
}
