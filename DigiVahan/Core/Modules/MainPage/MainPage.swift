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
        profileVC.setupUI()
    }
    
    @objc private func onNotificationBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "NotificationListVC"
        )
    }
    
}
