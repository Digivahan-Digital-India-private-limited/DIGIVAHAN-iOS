//
//  UpdateEmergencyContactsVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 11/06/26.
//

import UIKit
import SDWebImage


class UpdateEmergencyContactsVC: BaseViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var firstName: CustomInputFieldView!
    @IBOutlet weak var lastName: CustomInputFieldView!
    @IBOutlet weak var relationField: CustomInputFieldView!
    @IBOutlet weak var phoneNumber: CustomInputFieldView!
    @IBOutlet weak var imagePickerBtn: UIImageView!
    @IBOutlet weak var contextLabel: UILabel!
    
        let relationList = [
            "Select Relation",
                        "Friend",
                        "Father",
                        "Mother",
                        "Son",
                        "Daughter",
                        "Brother",
                        "Sister",
                        "Husband",
                        "Wife"
        ]

        let relationPicker = UIPickerView()
    
    var selectedImage: UIImage?
    
    var hit_type: String? = "add"
    var contactDetails: EmergencyContactModel? = nil
    
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
        
        firstName.setUpField(title: "First Name", placeholder: "Enter your first name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        lastName.setUpField(title: "Last Name", placeholder: "Enter your last name", leftIcon: UIImage(named: "locationIcon"), keyboardType: .default, inputType: .name)
        
        relationField.setUpField(title: "Relation", placeholder: "Select Relation", leftIcon: UIImage(named: "calenderIcon"), keyboardType: .default, inputType: .age)
        
        phoneNumber.setUpField(title: "Phone Number", placeholder: "Please enter contact number", leftIcon: UIImage(named: "callIcon"), keyboardType: .default, inputType: .phone)
        
        relationPicker.delegate = self
        relationPicker.dataSource = self

        relationField.txtInputField.delegate = self
        relationField.txtInputField.inputView = relationPicker
        relationField.txtInputField.tintColor = .clear
        relationField.txtInputField.text = relationList[0]

        // Optional toolbar with Done button
        let toolbarForGenderField = UIToolbar()
        toolbarForGenderField.sizeToFit()

        let genderFieldDoneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePicker)
        )

        toolbarForGenderField.setItems([genderFieldDoneButton], animated: false)
        relationField.txtInputField.inputAccessoryView = toolbarForGenderField
        
        
        // set updateBasicDetailsBtn
        imagePickerBtn.isUserInteractionEnabled = true

            let imagePickerBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(imagePickerBtnClick)
            )

        imagePickerBtn.addGestureRecognizer(imagePickerBtnTap)
        
        // Receive Data
        if let data = receivedData as? [String: Any] {

            hit_type = data["hit_type"] as? String ?? ""

            if hit_type == "update" {
                
                contextLabel.text = "Update Emergency Contact"
                
                if let contact = data["contactDetails"] as? EmergencyContactModel {

                    self.contactDetails = contact
                    
                    userProfileImage.sd_setImage(
                        with: URL(string: contact.profile_pic),
                        placeholderImage: UIImage(named: "defaultProfileIcon")
                    )

                    firstName.txtInputField.text = contact.first_name
                    lastName.txtInputField.text = contact.last_name
                    phoneNumber.txtInputField.text = contact.phone_number
                    
                    if let index = relationList.firstIndex(of: contact.relation) {
                        relationField.txtInputField.text = contact.relation
                        relationPicker.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        relationField.txtInputField.text = relationList[0]
                        relationPicker.selectRow(0, inComponent: 0, animated: false)
                    }
                }

            } else {
                contextLabel.text = "Add Emergency Contact"
                userProfileImage.image = UIImage(named: "defaultProfileIcon")
            }
        }
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
            relationField.txtInputField.resignFirstResponder()
        }
    
    @IBAction func updateProfileBtnClick(_ sender: Any) {
        
        let relationText = relationField.txtInputField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !firstName.validateField() {
                return
            } else if !lastName.validateField() {
                return
            } else if !phoneNumber.validateField() {
                return
            } else if relationText == "Select Relation" {
                relationField.showError("Please select relation")
                return
            }
    
            LoadingManager.shared.show(on: view)
        
        if hit_type == "update" {
            
            NetworkManager.shared.editEmergencyContact(
                userId: PreferenceManager.shared.getUserId(),
                first_name: firstName.txtInputField.text ?? "",
                last_name: lastName.txtInputField.text ?? "",
                relation: relationField.txtInputField.text ?? "",
                phone_number: phoneNumber.txtInputField.text ?? "",
                contact_id: contactDetails?._id ?? "",
                public_id: contactDetails?.public_id ?? "",
                publicImage: selectedImage
            ) { [weak self] success, message, response in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    LoadingManager.shared.hide()
                    
                    self.showToast(message: response?.debugDescription ?? "")
                    
                    
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showToast(message: "Unable to complete the task. Please try again.")
                    }
                }
            }
        } else {
            
            NetworkManager.shared.addEmergencyContact(
                userId: PreferenceManager.shared.getUserId(),
                first_name: firstName.txtInputField.text ?? "",
                last_name: lastName.txtInputField.text ?? "",
                relation: relationField.txtInputField.text ?? "",
                phone_number: phoneNumber.txtInputField.text ?? "",
                publicImage: selectedImage
            ) { [weak self] success, message, response in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                
                    LoadingManager.shared.hide()
                    
                    self.showToast(message: message)
                    
                    
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showToast(message: "Unable to complete the task. Please try again.")
                    }
                }
            }
        }
            
    }
    
}


extension UpdateEmergencyContactsVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        relationField.txtInputField.text = relationList[row]
    }

    // Prevent manual typing
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == relationField.txtInputField {
            return false
        }

        return true
    }

}

