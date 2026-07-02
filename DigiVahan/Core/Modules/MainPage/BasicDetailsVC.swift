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


class BasicDetailsVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var profileProgress: CircularProgressView!
    
    @IBOutlet weak var firstName: CustomInputFieldView!
    @IBOutlet weak var lastName: CustomInputFieldView!
    @IBOutlet weak var emailAddress: CustomInputFieldView!
    @IBOutlet weak var phoneField: CustomInputFieldView!
    @IBOutlet weak var occupationSpinnerLayout: CustomInputFieldView!
    @IBOutlet weak var imagePickerBtn: UIImageView!
    
        let occupationList = [
            "IT / Software",
            "Business / Entrepreneur",
            "Finance / Banking",
            "Education",
            "Medical / Healthcare",
            "Government / Public Service",
            "Sales / Marketing",
            "Creative / Media",
            "Transport / Logistics",
            "Skilled / Technical",
            "Manufacturing / Industrial",
            "Retail / Shopkeeper",
            "Freelance / Self-Employed",
            "Agriculture / Farming",
            "Homemaker",
            "Student",
            "Intern / Trainee",
            "Unemployed / Job Seeker",
            "Retired",
            "Other"
        ]

        let occupationPicker = UIPickerView()
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableKeyboardDismissOnTap()
        enableKeyboardAvoiding(scrollView: mainScrollView)
        
        sutUI()
    }
    
    private func sutUI() {
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        firstName.setUpField(title: "First Name", placeholder: "Enter your first name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        lastName.setUpField(title: "Last Name", placeholder: "Enter your last name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        emailAddress.setUpField(title: "Email Address", placeholder: "Enter your email", leftIcon: UIImage(named: "emailFieldIcon"), keyboardType: .default, inputType: .email)
        
        phoneField.setUpField(title: "Phone Number", placeholder: "Enter your number", leftIcon: UIImage(named: "callIcon"), keyboardType: .numberPad, inputType: .phone)
        
        occupationSpinnerLayout.setUpField(title: "Occupation", placeholder: "Select your Occupation", leftIcon: UIImage(named: "occupationIcon"), keyboardType: .default, inputType: .name)
        
        
        occupationPicker.delegate = self
        occupationPicker.dataSource = self

        occupationSpinnerLayout.txtInputField.delegate = self
        occupationSpinnerLayout.txtInputField.inputView = occupationPicker
        occupationSpinnerLayout.txtInputField.tintColor = .clear
        occupationSpinnerLayout.txtInputField.text = occupationList[0]

        // Optional toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePicker)
        )

        toolbar.setItems([doneButton], animated: false)
        occupationSpinnerLayout.txtInputField.inputAccessoryView = toolbar
        
        
        // set updateBasicDetailsBtn
        imagePickerBtn.isUserInteractionEnabled = true

            let imagePickerBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(imagePickerBtnClick)
            )

        imagePickerBtn.addGestureRecognizer(imagePickerBtnTap)
        
        
        loadUserProfile()
    }
    
    @objc private func imagePickerBtnClick() {
        ImagePickerHelper.shared.showImagePicker(from: self) { image in

                guard let image = image else { return }

                self.userProfileImage.image = image
            self.selectedImage = image

                // Here you can upload or store the selected image
            }
        
    }
    
    
    @objc func donePicker() {
            occupationSpinnerLayout.txtInputField.resignFirstResponder()
        }
    
    
    private func loadUserProfile() {

            let user = PreferenceManager.shared.getUser()

            guard let user = user else {

                userProfileImage.image =
                UIImage(named: "defaultProfileIcon")

                return
            }
        

        setProfileValueStatus(user: user)

        let imageURL = user.profilePic
        
//        userName.text = user.firstName + " " + user.lastName
        
        var completedFields = 0

        completedFields += CommonFunctions.checkValue(user.firstName)
        completedFields += CommonFunctions.checkValue(user.lastName)
        completedFields += CommonFunctions.checkValue(user.email)
        completedFields += CommonFunctions.checkValue(user.phoneNumber)
        completedFields += CommonFunctions.checkValue(user.occupation)
        completedFields += CommonFunctions.checkValue(user.profilePic)

        let progress =
        (CGFloat(completedFields) / 6.0)

        profileProgress.setProgress(progress)
        

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
        firstName.txtInputField.text = user.firstName
        lastName.txtInputField.text = user.lastName
        emailAddress.txtInputField.text = user.email
        phoneField.txtInputField.text = user.phoneNumber
        
        if let index = occupationList.firstIndex(of: user.occupation) {
            occupationSpinnerLayout.txtInputField.text = user.occupation
            occupationPicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            occupationSpinnerLayout.txtInputField.text = occupationList[0]
            occupationPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func updateProfileBtnClick(_ sender: Any) {

        if !firstName.validateField() {
            return
        } else if !lastName.validateField() {
            return
        } else if !emailAddress.validateField() {
            return
        } else if !phoneField.validateField() {
            return
        }

        guard let user = PreferenceManager.shared.getUser() else {
            showToast(message: "User not found")
            return
        }
        
     
        // Show loader
        LoadingManager.shared.show(on: view)

        NetworkManager.shared.updateBasicDetails(
            userId: PreferenceManager.shared.getUserId(),
            firstName: firstName.txtInputField.text ?? "",
            lastName: lastName.txtInputField.text ?? "",
            occupation: occupationSpinnerLayout.txtInputField.text ?? "",
            profileImage: selectedImage
        ) { [weak self] success, message, updatedUser in

            guard let self = self else { return }

            DispatchQueue.main.async {

                // Hide loader
                LoadingManager.shared.hide()

                // Show message
                self.showToast(message: message)
                
                print(message)

                if success {

                    // Save updated user
                    if let updatedUser = updatedUser {
                        PreferenceManager.shared.saveUser(updatedUser)
                    }

                    // Update progress and UI
                    self.loadUserProfile()

                    // Go back
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
}


extension BasicDetailsVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return occupationList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return occupationList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        occupationSpinnerLayout.txtInputField.text = occupationList[row]
    }

    // Prevent manual typing
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == occupationSpinnerLayout.txtInputField {
            return false
        }

        return true
    }

}
