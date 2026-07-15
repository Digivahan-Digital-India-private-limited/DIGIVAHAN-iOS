//
//  RestPassword.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit

class RestPasswordVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var passwordField: CustomInputFieldView!
    @IBOutlet weak var confirmPasswordField: CustomInputFieldView!
    @IBOutlet weak var savePasswordBtn: UIButton!
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableKeyboardAvoiding(scrollView: mainScrollView)
       
        if let data = receivedData as? [String: Any] {
            self.userId = data["userId"] as? String ?? ""
            
        }
        
        passwordField.setUpField(title: "Password", placeholder: "Enter your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        confirmPasswordField.setUpField(title: "Confirm Password", placeholder: "Confirm your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
    }
    
    @IBAction func savePasswordBtnClick(_ sender: Any) {
        let password = passwordField.txtInputField.text ?? ""
        let confirmPassword = confirmPasswordField.txtInputField.text ?? ""

        if !passwordField.validateField() {
            return
        } else if confirmPassword != password {
            confirmPasswordField.showError("Password Not Match")
            return
        }
        
        
        // Params
        let params: [String: Any] = [
            
            "user_id": userId,
            "new_password": password
        ]
        
        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.NEW_PASSWORD,
            method: "POST",
            parameters: params
        ) { response, status, message in
                        
            if status {
                
                NavigationManager.moveToNavigationController(
                    from: self,
                    storyboardName: "Auth",
                    navigationControllerID: "AuthNavigationController"
                )
                
            } else {
                                
                let errorType =
                response?["error_type"] as? String ?? ""
                
                switch errorType {
                    
                case "password":
                    self.passwordField.showError(message)
                    
                default:
                    break
                }
            }
        }
    }
    
    
}
