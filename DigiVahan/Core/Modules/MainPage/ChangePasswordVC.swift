//
//  ChangePasswordVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 08/06/26.
//


import UIKit

class ChangePasswordVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var currentPasswordField: CustomInputFieldView!
    @IBOutlet weak var newPasswordField: CustomInputFieldView!
    @IBOutlet weak var confirmPasswordField: CustomInputFieldView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableKeyboardAvoiding(scrollView: mainScrollView)
        
        currentPasswordField.setUpField(title: "Current Password", placeholder: "Enter your Current password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        newPasswordField.setUpField(title: "New Password", placeholder: "Enter your New password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        confirmPasswordField.setUpField(title: "Confirm password", placeholder: "Confirm your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        
    }
    
    @IBAction func savePasswordBtnClick(_ sender: Any) {
        let currentPassword = currentPasswordField.txtInputField.text ?? ""
        let newPassword = newPasswordField.txtInputField.text ?? ""
        let confirmPassword = confirmPasswordField.txtInputField.text ?? ""

        if currentPassword.isEmpty {
            confirmPasswordField.showError("Field is required")
            return
        }else if !newPasswordField.validateField() {
            return
        } else if confirmPassword != newPassword {
            confirmPasswordField.showError("Password Not Match")
            return
        }
        
        
        // Params
        let params: [String: Any] = [
            
            "user_id": PreferenceManager.shared.getUserId(),
            "old_password": currentPassword,
            "new_password": newPassword
        ]
        
        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.CHANGE_PASSWORD,
            method: "POST",
            parameters: params
        ) { response, status, message in
                        
            if status {
                
                CommonFunctions.showSuccessDialog(
                    from: self,
                    verificationType: "changePassword"
                )
                
            } else {
                                
                let errorType =
                response?["error_type"] as? String ?? ""
                
                switch errorType {
                    
                case "password":
                    self.newPasswordField.showError(message)
                
                case "old_password":
                    self.currentPasswordField.showError(message)
                    
                default:
                    break
                }
            }
        }
    }
    
    
}

