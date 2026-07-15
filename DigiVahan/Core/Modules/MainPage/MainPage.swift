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
    @IBOutlet weak var notificationBtn: UIView!
    @IBOutlet weak var notificationCountView: UIView!
    @IBOutlet weak var notificationCountText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        OneSignal.login(
            PreferenceManager.shared.getUserId()
        )
        
        // set myVirtualQRBtn
        notificationBtn.isUserInteractionEnabled = true

            let notificationBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onNotificationBtnClick)
            )

        notificationBtn.addGestureRecognizer(notificationBtnTap)
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
