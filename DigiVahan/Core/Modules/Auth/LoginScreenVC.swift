//
//  LoginScreenVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import UIKit

class LoginScreenVC: BaseViewController {
    
    var isOTPLogin: Bool = false
    
    // Layouts
    @IBOutlet weak var userLoginLayout: UIScrollView!
    @IBOutlet weak var userRegisterLayout: UIView!
    
    @IBOutlet weak var oldNewUserBtnLayout: UIStackView!
    
    @IBOutlet weak var loginTypeBtn: UIButton!
    @IBOutlet weak var phoneNumberField: CustomInputFieldView!
    @IBOutlet weak var passwordFieldLayout: UIStackView!
    @IBOutlet weak var passwordField: CustomInputFieldView!
    @IBOutlet weak var forgotPasswordBtn: UILabel!
    
    @IBOutlet weak var rFirstName: CustomInputFieldView!
    @IBOutlet weak var rLastName: CustomInputFieldView!
    @IBOutlet weak var rEmailAddress: CustomInputFieldView!
    @IBOutlet weak var rPhoneField: CustomInputFieldView!
    @IBOutlet weak var rPasswordField: CustomInputFieldView!
    @IBOutlet weak var rConfirmPassword: CustomInputFieldView!
    
    
    @IBOutlet weak var oldUserLayoutBtn: UIButton!
    @IBOutlet weak var newUserLayoutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldNewUserBtnLayout.isLayoutMarginsRelativeArrangement = true

        oldNewUserBtnLayout.layoutMargins = UIEdgeInsets(
            top: 4,
            left: 5,
            bottom: 4,
            right: 5
        )
        
        
        phoneNumberField.setUpField(title: "Phone Number", placeholder: "Enter your number", leftIcon: UIImage(named: "callIcon"), keyboardType: .numberPad, inputType: .phone)
        
        passwordField.setUpField(title: "Password", placeholder: "Enter your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        rFirstName.setUpField(title: "First Name", placeholder: "Enter your first name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        rLastName.setUpField(title: "Last Name", placeholder: "Enter your last name", leftIcon: UIImage(named: "fieldProfileIcon"), keyboardType: .default, inputType: .name)
        
        rEmailAddress.setUpField(title: "Email Address", placeholder: "Enter your email", leftIcon: UIImage(named: "emailFieldIcon"), keyboardType: .default, inputType: .email)
        
        rPhoneField.setUpField(title: "Phone Number", placeholder: "Enter your number", leftIcon: UIImage(named: "callIcon"), keyboardType: .numberPad, inputType: .phone)
        
        rPasswordField.setUpField(title: "Password", placeholder: "Enter your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        rConfirmPassword.setUpField(title: "Confirm password", placeholder: "Confirm your password", leftIcon: UIImage(named: "lockIocn"), keyboardType: .default, inputType: .password)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        
        forgotPasswordBtn.isUserInteractionEnabled = true
        let tapToMoveForgotPassword = UITapGestureRecognizer(target: self, action: #selector(moveToForgotPage))
        forgotPasswordBtn.addGestureRecognizer(tapToMoveForgotPassword)


        setLoginType(loginType: isOTPLogin)
         


    }
     
    @IBAction func changeLoginOption(_ sender: Any) {
        setLoginType(loginType: isOTPLogin)
    }
    
    
    @IBAction func onClickLogin(_ sender: UIButton) {

        let phone = phoneNumberField.txtInputField.text ?? ""
        let password = passwordField.txtInputField.text ?? ""

        if phone.isEmpty {
            phoneNumberField.showError("Field can't be empty")
            return
        } else if phone.count < 10 {
            phoneNumberField.showError("Invalid Number")
            return
        } else if !isOTPLogin && password.isEmpty {
            passwordField.showError("Field can't be empty")
            return
        }
        
        if isOTPLogin {
            print("Navigation Controller =", self.navigationController as Any)
            NavigationManager.pushScreen(
                   from: self,
                   storyboardName: "Auth",
                   viewControllerID: "VerificationScreenVC",
                   data: [
                           "phone": phone,
                           "verificationType": "otpLogin"
                       ]
               )
        
        }
        else{
            // Params
            let params: [String: Any] = [
                
                "login_type": "phone",
                "login_value": phone,
                "password": password
            ]
            
            // API Call
            NetworkManager.shared.callAPI(
                url: APIEndpoints.login,
                method: "POST",
                parameters: params
            ) { response, status, message in
                
                print("STATUS:", status)
                print("MESSAGE:", message)
                
                if status {
                    
                    // User Object
                    if let user = response?["user"] as? [String: Any] {
                        
                        // Token
                        let token = user["token"] as? String ?? ""
                        
                        // Save Token
                        PreferenceManager.shared.setAuthToken(token)
                        PreferenceManager.shared.setUserId(JWTUtils.getUserIdFromToken(token))
                        
                        print(JWTUtils.getUserIdFromToken(token))
                        
                        PreferenceManager.shared.setLoggedIn(true)
                            
                            PreferenceManager.shared.saveUser(CommonFunctions.parseUserFromJson(user))

                        
                        // Move Next Screen
                        NavigationManager.moveToScreen(
                            from: self,
                            viewControllerID: "MainPage"
                        )
                        
                        
                    }
                    
                } else {
                    
                    let errorType =
                    response?["error_type"] as? String ?? ""
                    
                    switch errorType {
                        
                    case "password":
                        self.passwordField.showError(message)
                        
                    case "phone":
                        self.phoneNumberField.showError(message)
                        
                    default:
                        break
                    }
                }
            }
        }
         
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        let password = rPasswordField.txtInputField.text ?? ""
        let confirmPassword = rConfirmPassword.txtInputField.text ?? ""

        if !rFirstName.validateField() {
            return
        }else if !rLastName.validateField() {
            return
        }else if !rEmailAddress.validateField() {
            return
        }else if !rPhoneField.validateField() {
            return
        } else if !rPasswordField.validateField() {
            return
        } else if confirmPassword != password {
            rConfirmPassword.showError("Password Not Match")
            return
        }
        

        

        // Params
        let params: [String: Any] = [
            "otp_channel": "phone",
            "first_name": rFirstName.getValue(),
            "last_name": rLastName.getValue(),
            "email": rEmailAddress.getValue(),
            "phone": rPhoneField.getValue(),
            "password": rPasswordField.getValue(),
            "hit_type": "check",
            "verificationType": "create"
        ]
        
        /*
        
        print("========== PARAMS ==========")

        for (key, value) in params {
            print("\(key): \(value)")
        }

        print("============================")
         
         */


        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.checkRegister,
            method: "POST",
            parameters: params
        ) { response, status, message in

            print("STATUS:", status)
            print("MESSAGE:", message)

            if status {

                NavigationManager.pushScreen(
                    from: self,
                    storyboardName: "Auth",
                    viewControllerID: "VerificationScreenVC",
                    data: params
                )
                
                
            } else {
                
                self.showToast(message: message)
                
                let errorType =
                response?["error_type"] as? String ?? ""
                
                switch errorType {

                case "email":
                    self.rEmailAddress.showError(message)

                case "phone":
                    self.rPhoneField.showError(message)

                default:
                    break
                }
            }
        }
         

    }
    
    
    @IBAction func showLoginLayout(_ sender: UIButton) {
        userLoginLayout.isHidden = false
        userRegisterLayout.isHidden = true
        
        oldUserLayoutBtn.backgroundColor = UIColor(named: "iconColor")
        newUserLayoutBtn.backgroundColor = UIColor(named: "unselected")
        
    }
   
    
    @IBAction func showRegisterLayout(_ sender: UIButton) {
        userLoginLayout.isHidden = true
        userRegisterLayout.isHidden = false
        
        oldUserLayoutBtn.backgroundColor = UIColor(named: "unselected")
        newUserLayoutBtn.backgroundColor = UIColor(named: "iconColor")
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func moveToForgotPage() {
        let params: [String: Any] = [
            "verificationType": "changePassword"
        ]
        
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Auth",
            viewControllerID: "VerificationScreenVC",
            data: params
        )
    }
    
    func setLoginType(loginType: Bool) {

        isOTPLogin = !loginType

        passwordFieldLayout.isHidden = isOTPLogin

        if isOTPLogin {
            loginTypeBtn.setTitle("Login With Password", for: .normal)
        } else {
            loginTypeBtn.setTitle("Login With OTP", for: .normal)
        }
    }
}
