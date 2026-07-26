//
//  ProfileVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework

class DashBoardVC: UIView, UITextFieldDelegate {
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var navigationProfileBtn: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var greatingText: UILabel!
    @IBOutlet weak var userName: UILabel!
    
   
    
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
            "DashBoard",
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
        
        setUI()

    }
    
    func setUI() {
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        loadUserProfile()
    
        // set navigationProfileBtn
        navigationProfileBtn.isUserInteractionEnabled = true

            let navigationProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showNavigation)
            )

        navigationProfileBtn.addGestureRecognizer(navigationProfileBtnTap)
        
    }
    
    @objc private func showNavigation() {

        let dialog = NavigationView(
            frame: UIScreen.main.bounds
        )

        dialog.configure()

        dialog.onProceed = { value in
            print(value)
        }

        if let vc = parentViewController {
            vc.view.addSubview(dialog)
            dialog.showAnimated()
        }
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
        
        self.greatingText.text = "Welcome, \(CommonFunctions.getTimeGreeting())"
    }

}
