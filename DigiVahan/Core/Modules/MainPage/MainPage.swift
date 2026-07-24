//
//  MainPage.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/05/26.
//

import UIKit
import OneSignalFramework

class MainPage: BaseViewController {
    
    @IBOutlet weak var profileVC: ProfileVC!
    @IBOutlet weak var DashBoardScreen: DashBoardVC!
    @IBOutlet weak var homeScreen: HomeVC!
    
    @IBOutlet weak var notificationBtn: UIView!
    @IBOutlet weak var notificationCountView: UIView!
    @IBOutlet weak var notificationCountText: UILabel!
    
    @IBOutlet weak var homeBtn: UIView!
    @IBOutlet weak var homeBtnIcon: UIImageView!
    @IBOutlet weak var homeBtnText: UILabel!
    
    @IBOutlet weak var dashBoardBtn: UIView!
    @IBOutlet weak var dashBoardIcon: UIImageView!
    @IBOutlet weak var dashBoardText: UILabel!
    
    @IBOutlet weak var profileBtn: UIView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var profileText: UILabel!
    
    var selectedScreen : String = "home"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        OneSignal.login(
            PreferenceManager.shared.getUserId()
        )
        
        LocationManager.shared.requestLocationPermission()
        LocationManager.shared.startUpdatingLocation()
        
        // set myVirtualQRBtn
        notificationBtn.isUserInteractionEnabled = true

            let notificationBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onNotificationBtnClick)
            )

        notificationBtn.addGestureRecognizer(notificationBtnTap)
        
        // set homeBtn
        homeBtn.isUserInteractionEnabled = true

            let homeBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onHomeBtnClick)
            )

        homeBtn.addGestureRecognizer(homeBtnTap)
        
        // set dashBoardBtn
        dashBoardBtn.isUserInteractionEnabled = true

            let dashBoardBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onDashBoardBtnClick)
            )

        dashBoardBtn.addGestureRecognizer(dashBoardBtnTap)
        
        // set profileBtn
        profileBtn.isUserInteractionEnabled = true

            let profileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onProfileBtnClick)
            )

        profileBtn.addGestureRecognizer(profileBtnTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        CommonFunctions.checkForAppUpdate(from: self)
        
        profileVC.setupUI()
        getNotificationList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc private func onHomeBtnClick() {
        selectedScreen = "home"
        setScreen()
    }
    
    @objc private func onDashBoardBtnClick() {
        selectedScreen = "dashBoard"
        setScreen()
    }
    
    @objc private func onProfileBtnClick() {
        selectedScreen = "profile"
        setScreen()
    }
    
    func setScreen() {
        
        homeBtnIcon.image = UIImage(named: "homeIcon")
        homeBtnText.textColor = UIColor(named: "colorPrimary")
        
        dashBoardIcon.image = UIImage(named: "dashBoardIcon")
        dashBoardText.textColor = UIColor(named: "colorPrimary")
        
        profileIcon.image = UIImage(named: "profileIcon")
        profileText.textColor = UIColor(named: "colorPrimary")
        
        homeScreen.isHidden = true
        DashBoardScreen.isHidden = true
        profileVC.isHidden = true
        
        if selectedScreen == "dashBoard" {
            DashBoardScreen.isHidden = false
            dashBoardIcon.image = UIImage(named: "dashBoardSelectedIcon")
            dashBoardText.textColor = UIColor(named: "secondIconColor")
        }
        else if selectedScreen == "profile" {
            profileVC.isHidden = false
            profileIcon.image = UIImage(named: "selectedProfileIcon")
            profileText.textColor = UIColor(named: "secondIconColor")
        }
        else {
            homeScreen.isHidden = false
            homeBtnIcon.image = UIImage(named: "selectedHomeIcon")
            homeBtnText.textColor = UIColor(named: "secondIconColor")
        }
    }
    
    @objc private func onNotificationBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "NotificationListVC"
        )
    }
    
    func getNotificationList() {

        let userId = PreferenceManager.shared.getUserId()

        let url = APIEndpoints.GET_NOTIFICATION + "\(userId)?current_page=1"

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                do {
                    guard let unseenCount = response?["unseen_count"] as? Int else {
                        return
                    }


                    if unseenCount > 0 {
                        if unseenCount > 99 {
                            notificationCountText.text = "99+"
                        } else {
                            notificationCountText.text = "\(unseenCount)"
                        }
                        
                        notificationCountView.isHidden = false
                    } else {
                        notificationCountView.isHidden = true
                    }

                } catch {
                    print("🔥 Decode Error:", error.localizedDescription)
                    self.showToast(message: "Parsing Error")
                }
                
            }
        }
    }
    
    func handelNotification() {
        if PreferenceManager.shared.getBool(key: PreferenceManager.Keys.NOTIFICATION_CLICKED) {
            
            PreferenceManager.shared.setBool(value: false, key: PreferenceManager.Keys.NOTIFICATION_CLICKED)
            
            let notificationType = PreferenceManager.shared.getString(key: PreferenceManager.Keys.NOTIFICATION_TYPE_TEMP)
            
            if notificationType == "vehicle" || notificationType == "chat" {
                onNotificationBtnClick()
            }
            
        }
    }
    
}
