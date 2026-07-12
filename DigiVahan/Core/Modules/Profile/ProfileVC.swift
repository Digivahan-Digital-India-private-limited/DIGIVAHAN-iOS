//
//  ProfileVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework

class ProfileVC: UIView, UITextFieldDelegate {
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var updateProfileBtn: UIView!
    @IBOutlet weak var aboutUsBtn: UIView!
    @IBOutlet weak var termConditionBtn: UIView!
    @IBOutlet weak var privacyPolicyBtn: UIView!
    @IBOutlet weak var shareAppBtn: UIView!
    @IBOutlet weak var logoutBtn: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileCompletionPercent: UILabel!
    @IBOutlet weak var scanBtn: UIView!
    @IBOutlet weak var garageBtn: UIView!
    @IBOutlet weak var myVirtualQRBtn: UIView!
    
    @IBOutlet weak var profileProgress: CircularProgressView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Common Init
    private func commonInit() {

        Bundle.main.loadNibNamed(
            "Profile",
            owner: self,
            options: nil
        )

        guard let contentView = mainContentView else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)

        NSLayoutConstraint.activate([

            contentView.topAnchor.constraint(equalTo: topAnchor),

            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),

            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)

        ])

        setupUI()
    }

    public func setupUI() {
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill

        
        loadUserProfile()
        
        // set updateProfileBtn
        updateProfileBtn.isUserInteractionEnabled = true

            let updateProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onUpdateProfileBtnClick)
            )

        updateProfileBtn.addGestureRecognizer(updateProfileBtnTap)
        
        // set aboutBtn
        aboutUsBtn.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAboutUsClick)
            )

            aboutUsBtn.addGestureRecognizer(tap)
        
        // set termConditionBtn
        termConditionBtn.isUserInteractionEnabled = true

            let termConditionBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onTermConditionBtnClick)
            )

        termConditionBtn.addGestureRecognizer(termConditionBtnTap)
        
        // set privacyPolicyBtn
        privacyPolicyBtn.isUserInteractionEnabled = true

            let privacyPolicyBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPrivacyPolicyBtnClick)
            )

        privacyPolicyBtn.addGestureRecognizer(privacyPolicyBtnTap)
        
        // set shareAppBtn
        shareAppBtn.isUserInteractionEnabled = true

            let shareAppBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onShareAppBtnClick)
            )

        shareAppBtn.addGestureRecognizer(shareAppBtnTap)
        
        // set logoutBtn
        logoutBtn.isUserInteractionEnabled = true

            let logoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onLogoutBtnClick)
            )

        logoutBtn.addGestureRecognizer(logoutBtnTap)
        
        // set scanBtn
        scanBtn.isUserInteractionEnabled = true

            let scanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onScanBtnClick)
            )

        scanBtn.addGestureRecognizer(scanBtnTap)
        
        // set garageBtn
        garageBtn.isUserInteractionEnabled = true

            let garageBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onGarageBtnClick)
            )

        garageBtn.addGestureRecognizer(garageBtnTap)
        
        // set myVirtualQRBtn
        myVirtualQRBtn.isUserInteractionEnabled = true

            let myVirtualQRBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onMyVirtualQRBtnClick)
            )

        myVirtualQRBtn.addGestureRecognizer(myVirtualQRBtnTap)
    }
    
    @objc private func onMyVirtualQRBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "VirtualQRListVC"
            )
        }
    }
    
    @objc private func onGarageBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "GarageListVC"
            )
        }
    }
    
    @objc private func onUpdateProfileBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "ProfileUpdateMenuVC"
            )
        }
    }
    
    @objc private func onScanBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "ScanVC"
            )
        }
        
    }
    
    @objc private func onAboutUsClick() {
        openPolicyPage(policyType: "about_page")
    }
    
    @objc private func onTermConditionBtnClick() {
        openPolicyPage(policyType: "terms_condition")
    }
    
    @objc private func onPrivacyPolicyBtnClick() {
        openPolicyPage(policyType: "privacy_policy")
    }
    
    @objc private func onShareAppBtnClick() {
        if let vc = parentViewController {
            CommonFunctions.shareAppWithImage(
                from: vc
            )
        }
    }
    
    @objc private func onLogoutBtnClick() {
        
        OneSignal.logout()
        
        if let vc = parentViewController {
            CommonFunctions.logout(
                from: vc,
                isLogout: true
            )
            
        }
    }
    
    private func openPolicyPage(policyType: String) {

        guard let vc = parentViewController else {
            print("Parent ViewController not found")
            return
        }

        NavigationManager.pushScreen(
            from: vc,
            storyboardName: "Main",
            viewControllerID: "WebViewVC",
            data: [
                "policyType": policyType
            ]
        )
    }
    
    private func loadUserProfile() {
        

            let user = PreferenceManager.shared.getUser()

            guard let user = user else {

                userProfileImage.image =
                UIImage(named: "defaultProfileIcon")

                return
            }

        let imageURL = user.profilePic
        
        userName.text = user.firstName + " " + user.lastName
        
        profileProgress.setProgress(
            CGFloat(user.profileCompletionPercent) / 100.0
        )
        
        
        profileCompletionPercent.text = "  \(user.profileCompletionPercent)% Complete   "
        
        

        if imageURL.isEmpty {

            userProfileImage.image =
            UIImage(named: "defaultProfileIcon")

            return
        }

        userProfileImage.sd_setImage(
            with: URL(string: imageURL),
            placeholderImage: UIImage(
                named: "defaultProfileIcon"
            )
        )
    }
}
