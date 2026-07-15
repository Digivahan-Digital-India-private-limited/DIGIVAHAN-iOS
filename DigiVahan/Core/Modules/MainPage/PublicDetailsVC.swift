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


class PublicDetailsVC: BaseViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var profileProgress: CircularProgressView!
    
    @IBOutlet weak var nickName: CustomInputFieldView!
    @IBOutlet weak var address: CustomInputFieldView!
    @IBOutlet weak var agePickerLayout: CustomInputFieldView!
    @IBOutlet weak var genderField: CustomInputFieldView!
    @IBOutlet weak var imagePickerBtn: UIImageView!
    
    let agePicker = UIDatePicker()
    
    
        let genderList = [
            "Male",
            "Female",
            "Other"
        ]

        let genderPicker = UIPickerView()
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableKeyboardDismissOnTap()
        sutUI()
    }
    
    private func sutUI() {
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        nickName.setUpField(title: "Nickname", placeholder: "Enter your Nick name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        address.setUpField(title: "Address", placeholder: "Enter your Address", leftIcon: UIImage(named: "locationIcon"), keyboardType: .default, inputType: .name)
        
        agePickerLayout.setUpField(title: "Age", placeholder: "Pick your Age", leftIcon: UIImage(named: "calenderIcon"), keyboardType: .default, inputType: .age)
        
        
        genderField.setUpField(title: "Gender", placeholder: "Select your Gender", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .normal)
        
        
        agePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            agePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }

            // Maximum date = today - 10 years
            var components = DateComponents()
            components.year = -10
            let maxDate = Calendar.current.date(byAdding: components, to: Date())

            agePicker.maximumDate = maxDate

            // Set initial date
            agePicker.date = maxDate ?? Date()

            // Assign to TextField
            agePickerLayout.txtInputField.inputView = agePicker
            agePickerLayout.txtInputField.tintColor = .clear

            // Toolbar with Done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let doneButton = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(doneAgePicker)
            )

            let spaceButton = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            )

            toolbar.setItems([spaceButton, doneButton], animated: false)
            agePickerLayout.txtInputField.inputAccessoryView = toolbar
        
        
        genderPicker.delegate = self
        genderPicker.dataSource = self

        genderField.txtInputField.delegate = self
        genderField.txtInputField.inputView = genderPicker
        genderField.txtInputField.tintColor = .clear
        genderField.txtInputField.text = genderList[0]

        // Optional toolbar with Done button
        let toolbarForGenderField = UIToolbar()
        toolbarForGenderField.sizeToFit()

        let genderFieldDoneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePicker)
        )

        toolbarForGenderField.setItems([genderFieldDoneButton], animated: false)
        genderField.txtInputField.inputAccessoryView = toolbarForGenderField
        
        
        // set updateBasicDetailsBtn
        imagePickerBtn.isUserInteractionEnabled = true

            let imagePickerBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(imagePickerBtnClick)
            )

        imagePickerBtn.addGestureRecognizer(imagePickerBtnTap)
        
        
        loadUserProfile()
    }
    
    @objc func doneAgePicker() {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"

        agePickerLayout.txtInputField.text = formatter.string(from: agePicker.date)
        agePickerLayout.clearError()

        view.endEditing(true)
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
            genderField.txtInputField.resignFirstResponder()
        }
    
    
    private func loadUserProfile() {

            let user = PreferenceManager.shared.getUser()

            guard let user = user else {

                userProfileImage.image =
                UIImage(named: "defaultProfileIcon")

                return
            }
        

        setProfileValueStatus(user: user)

        let imageURL = user.publicPic
        
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
        nickName.txtInputField.text = user.nickName
        address.txtInputField.text = user.address
        agePickerLayout.txtInputField.text = user.age
        
        if let index = genderList.firstIndex(of: user.occupation) {
            genderField.txtInputField.text = user.occupation
            genderPicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            genderField.txtInputField.text = genderList[0]
            genderPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func updateProfileBtnClick(_ sender: Any) {

        if !nickName.validateField() {
                return
            } else if !address.validateField() {
                return
            } else if !agePickerLayout.validateField() {
                return
            }
    
            LoadingManager.shared.show(on: view)

            NetworkManager.shared.updatePublicDetails(
                userId: PreferenceManager.shared.getUserId(),
                nickName: nickName.txtInputField.text ?? "",
                address: address.txtInputField.text ?? "",
                age: agePickerLayout.txtInputField.text ?? "",
                gender: (genderField.txtInputField.text ?? "").lowercased(),
                publicImage: selectedImage
            ) { [weak self] success, message, updatedUser in

                guard let self = self else { return }

                DispatchQueue.main.async {

                    LoadingManager.shared.hide()

                    self.showToast(message: message)
                    
                    print("Nick Name : \(updatedUser?.nickName ?? "")")
                    print("Address   : \(updatedUser?.address ?? "")")
                    print("Age       : \(updatedUser?.age ?? "")")
                    print("Gender    : \(updatedUser?.gender ?? "")")

                    if success {

                        if let updatedUser = updatedUser {
                            PreferenceManager.shared.saveUser(updatedUser)
                        }

                        self.loadUserProfile()

                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }
    
}


extension PublicDetailsVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.txtInputField.text = genderList[row]
    }

    // Prevent manual typing
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == genderField.txtInputField {
            return false
        }

        return true
    }

}
