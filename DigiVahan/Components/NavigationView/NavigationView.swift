//
//  NavigationView.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework

class NavigationView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var closeDialogBtn: UIImageView!
    
    @IBOutlet weak var updateProfileBtn: UIView!
    @IBOutlet weak var aboutUsBtn: UIView!
    @IBOutlet weak var termConditionBtn: UIView!
    @IBOutlet weak var privacyPolicyBtn: UIView!
    @IBOutlet weak var shareAppBtn: UIView!
    @IBOutlet weak var logoutBtn: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var garageBtn: UIView!
    @IBOutlet weak var myVirtualQRBtn: UIView!

    
    
    var onProceed: ((String) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {

        Bundle.main.loadNibNamed(
            "NavigationView",
            owner: self,
            options: nil
        )

        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        backgroundColor = UIColor.black.withAlphaComponent(0)

        dialogView.layer.cornerRadius = 20
        dialogView.clipsToBounds = true
        
        setupUI()
        
    }
    
    public func setupUI() {
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill

        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundTapped)
        )

        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
        
        // set updateProfileBtn
        updateProfileBtn.isUserInteractionEnabled = true

            let updateProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onUpdateProfileBtnClick)
            )

        updateProfileBtn.addGestureRecognizer(updateProfileBtnTap)
        
        // set aboutBtn
        aboutUsBtn.isUserInteractionEnabled = true

            let aboutUsBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAboutUsClick)
            )

            aboutUsBtn.addGestureRecognizer(aboutUsBtnTap)
        
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
        
        // set closeDialogBtn
        closeDialogBtn.isUserInteractionEnabled = true

            let closeDialogBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(closeDialog)
            )

        closeDialogBtn.addGestureRecognizer(closeDialogBtnTap)
    }
    
    @objc private func onMyVirtualQRBtnClick() {
        hideAnimated()
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "VirtualQRListVC"
            )
        }
    }
    
    @objc private func onGarageBtnClick() {
        hideAnimated()
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "GarageListVC"
            )
        }
    }
    
    @objc private func onUpdateProfileBtnClick() {
        hideAnimated()
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "ProfileUpdateMenuVC"
            )
        }
    }
    
    @objc private func onAboutUsClick() {
        hideAnimated()
        openPolicyPage(policyType: "about_page")
    }
    
    @objc private func onTermConditionBtnClick() {
        hideAnimated()
        openPolicyPage(policyType: "terms_condition")
    }
    
    @objc private func onPrivacyPolicyBtnClick() {
        hideAnimated()
        openPolicyPage(policyType: "privacy_policy")
    }
    
    @objc private func onShareAppBtnClick() {
        hideAnimated()
        if let vc = parentViewController {
            CommonFunctions.shareAppWithImage(
                from: vc
            )
        }
    }
    
    @objc private func onLogoutBtnClick() {
        hideAnimated()
        
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
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {

        let location = gesture.location(in: self)

        if !dialogView.frame.contains(location) {
            hideAnimated()
        }
    }

    // MARK: - Configure Dialog

    func configure(
        title: String,
        description: String,
        hint: String,
        buttonTitle: String,
        defaultValue: String = ""
    ) {
        loadUserProfile()
    }

    // MARK: - Show Animation

    func showAnimated() {

        dialogView.transform = CGAffineTransform(
            translationX: -UIScreen.main.bounds.width,
            y: 0
        )

        dialogView.alpha = 0

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {

            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.dialogView.transform = .identity
            self.dialogView.alpha = 1
        }
    }

    // MARK: - Hide Animation

    func hideAnimated(
        completion: (() -> Void)? = nil
    ) {

        UIView.animate(
            withDuration: 0.25,
            animations: {

                self.backgroundColor = UIColor.black.withAlphaComponent(0)

                self.dialogView.transform = CGAffineTransform(
                    translationX: -UIScreen.main.bounds.width,
                    y: 0
                )

                self.dialogView.alpha = 0

            },
            completion: { _ in

                self.removeFromSuperview()

                completion?()
            }
        )
    }



    // MARK: - Close Dialog

    @objc func closeDialog() {

        hideAnimated()
    }
    
}
