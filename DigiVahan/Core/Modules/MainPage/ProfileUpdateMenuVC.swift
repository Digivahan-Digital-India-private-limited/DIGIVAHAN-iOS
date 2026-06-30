//
//  ProfileUpdateMenuVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

//˳
//  WebViewVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage


class ProfileUpdateMenuVC: BaseViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileProgress: CircularProgressView!
    @IBOutlet weak var profileCompletionPercent: UILabel!
    
    @IBOutlet weak var basicDetailsLayoutBtn: UIView!
    @IBOutlet weak var basicDetailsFCL: UILabel!
    @IBOutlet weak var basicDetailsCompletionIcon: UIImageView!
    
    @IBOutlet weak var publicDetailsLayoutBtn: UIView!
    @IBOutlet weak var publicDetailsFCL: UILabel!
    @IBOutlet weak var publicDetailsCompletionIcon: UIImageView!
    
    @IBOutlet weak var emergencyContactLayoutBtn: UIView!
    @IBOutlet weak var emergencyContactFCL: UILabel!
    @IBOutlet weak var emergencyContactCompletionIcon: UIImageView!
    
    @IBOutlet weak var changePasswordLayoutBtn: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill

        setUI()
        
        loadUserProfile()
    }
    
    private func setUI() {
        // set updateBasicDetailsBtn
        basicDetailsLayoutBtn.isUserInteractionEnabled = true

            let basicDetailsLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onBasicDetailsLayoutBtnClick)
            )

        basicDetailsLayoutBtn.addGestureRecognizer(basicDetailsLayoutBtnTap)
        
        // set updateBasicDetailsBtn
        publicDetailsLayoutBtn.isUserInteractionEnabled = true

            let publicDetailsLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPublicDetailsLayoutBtnClick)
            )

        publicDetailsLayoutBtn.addGestureRecognizer(publicDetailsLayoutBtnTap)
        
        
        // set emergencyContactLayoutBtn
        emergencyContactLayoutBtn.isUserInteractionEnabled = true

            let emergencyContactLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onEmergencyContactLayoutBtnClick)
            )

        emergencyContactLayoutBtn.addGestureRecognizer(emergencyContactLayoutBtnTap)
        
        
        // set updateBasicDetailsBtn
        changePasswordLayoutBtn.isUserInteractionEnabled = true

            let changePasswordLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onChangePasswordLayoutBtnClick)
            )

        changePasswordLayoutBtn.addGestureRecognizer(changePasswordLayoutBtnTap)
    }
    
    
    @objc private func onEmergencyContactLayoutBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "EmergencyContactsListVC"
        )
        
    }
    
    @objc private func onBasicDetailsLayoutBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "BasicDetailsVC"
        )
        
    }
    
    @objc private func onPublicDetailsLayoutBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "PublicDetailsVC"
        )
        
    }
    
    @objc private func onChangePasswordLayoutBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "ChangePasswordVC"
        )
        
    }
    
    
    private func loadUserProfile() {

            let user = PreferenceManager.shared.getUser()

            print("USER =", user as Any)

            guard let user = user else {

                print("USER IS NIL")

                userProfileImage.image =
                UIImage(named: "defaultProfileIcon")

                return
            }

        setProfileValueStatus(user: user)

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
    
    
    private func setProfileValueStatus(user: User){
        // set basic details field completetion
        var basicDetailsFiledCompleted: Int = 0
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.profilePic)
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.firstName)
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.lastName)
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.email)
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.phoneNumber)
        basicDetailsFiledCompleted += CommonFunctions.checkValue(user.occupation)
        
        setButtonData(completedLabel: basicDetailsFCL, completedIcon: basicDetailsCompletionIcon, totalValues: 6,  completedValues: basicDetailsFiledCompleted)
        
        
        // set public details field completetion
        var publicDetailsFiledCompleted: Int = 0
        publicDetailsFiledCompleted += CommonFunctions.checkValue(user.publicPic)
        publicDetailsFiledCompleted += CommonFunctions.checkValue(user.nickName)
        publicDetailsFiledCompleted += CommonFunctions.checkValue(user.address)
        publicDetailsFiledCompleted += CommonFunctions.checkValue(String(user.age))
        publicDetailsFiledCompleted += CommonFunctions.checkValue(user.gender)
        
        setButtonData(completedLabel: publicDetailsFCL, completedIcon: publicDetailsCompletionIcon, totalValues: 5,  completedValues: publicDetailsFiledCompleted)
        
        setProfileUpdatedData(user: user)
        
        checkEmergencyContactList()
    }
    
    private func setProfileUpdatedData(user: User) {

        let params: [String: Any] = [
            "user_id": PreferenceManager.shared.getUserId(),
            "details_type": "basic_details"
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { response, status, message in

            print("STATUS:", status)
            print("MESSAGE:", message)
            print("FULL RESPONSE:", response ?? [:])

            if status {

                if let data = response?["data"] as? [String: Any] {

                    let completionPercent =
                        data["profile_completion_percent"] as? Int ?? 0

                    user.profileCompletionPercent = completionPercent

                    PreferenceManager.shared.saveUser(user)

                    self.profileProgress.setProgress(
                        CGFloat(completionPercent) / 100.0
                    )

                    self.profileCompletionPercent.text =
                        "  \(completionPercent)% Complete   "

                    print("Updated Completion =", completionPercent)
                }
            }
        }
    }
    
    private func setButtonData(completedLabel: UILabel, completedIcon: UIImageView, totalValues: Int, completedValues: Int){
        
        let isCompleted = totalValues == completedValues

            completedIcon.isHidden = !isCompleted
            completedLabel.isHidden = isCompleted

            completedLabel.text = "\(completedValues)/\(totalValues)"

    }
    
    
    // MARK: - Emergency Contact Status

    /// Fetches emergency contact details from server
    /// and updates UI completion status.
    ///
    /// Android Equivalent:
    /// checkEmergencyContactList()
    ///
    /// API:
    /// GET_USER_DETAILS
    ///
    /// Params:
    /// - user_id
    /// - details_type = emergency_contacts
    ///
    /// Result:
    /// - If at least one emergency contact exists,
    ///   completion icon will be shown.
    /// - Otherwise count label will be displayed.
    private func checkEmergencyContactList() {

        // Request Parameters
        let params: [String: Any] = [

            "user_id": PreferenceManager.shared.getUserId(),
            "details_type": "emergency_contacts"
        ]
        
        print(params)

        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { response, status, message in

            print("STATUS:", status)
            print("MESSAGE:", message)

            guard status else {
                return
            }

            do {

                // API Response Data
                if let contacts =
                    response?["data"] as? [[String: Any]] {

                    let hasEmergencyContact =
                    !contacts.isEmpty

                    self.setButtonData(
                        completedLabel: self.emergencyContactFCL,
                        completedIcon: self.emergencyContactCompletionIcon,
                        totalValues: 1,
                        completedValues: hasEmergencyContact ? 1 : 0
                    )

                    print(
                        "Emergency Contacts Count:",
                        contacts.count
                    )
                }

            } catch {
                print(
                    "Emergency Contact Error:",
                    error.localizedDescription
                )
            }
        }
    }
    
}
