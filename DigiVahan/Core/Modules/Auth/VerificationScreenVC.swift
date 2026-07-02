//
//  VerificationScreenVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import UIKit
import OneSignalFramework

class VerificationScreenVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var phoneNumberField: CustomInputFieldView!
    @IBOutlet weak var otpView: OTPView!
    @IBOutlet weak var sendVerifiyOTPBtn: UIButton!
    @IBOutlet weak var verificationTitle: UILabel!
    @IBOutlet weak var verificationDescription: UILabel!
    @IBOutlet weak var resendOtpBtn: UILabel!
    
    private var resendTimer: Timer?
    private var remainingSeconds = 30
    
    var isOTPSent: Bool = false
    var phone: String = ""
    var verificationType: String = ""
    var verificationUrl: String = ""
    
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var password: String = ""
    var user_register_id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableKeyboardDismissOnTap()
        enableKeyboardAvoiding(scrollView: mainScrollView)
        
        phoneNumberField.setUpField(title: "Phone Number", placeholder: "Enter your number", leftIcon: UIImage(named: "callIcon"), keyboardType: .numberPad, inputType: .phone)
        
        phoneNumberField.fieldTitle.isHidden = true
        
        
        navigationItem.hidesBackButton = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backPress)
        )
        
        
        
        if let data = receivedData as? [String: Any] {

            self.phone = data["phone"] as? String ?? ""
            self.verificationType = data["verificationType"] as? String ?? ""
            
            self.first_name = data["first_name"] as? String ?? ""
            self.last_name = data["last_name"] as? String ?? ""
            self.email = data["email"] as? String ?? ""
            self.password = data["password"] as? String ?? ""
            
            phoneNumberField.setText(phone)
           
            
            if verificationType != "changePassword"{
                phoneNumberField.txtInputField.isEnabled = false
                sendOTP(verificationType: verificationType)
            }
        }
        

        otpView.otpLength = 4


        resendOtpBtn.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(onResendOTPClick)
        )

        resendOtpBtn.addGestureRecognizer(tap)
    
    }
    
    @IBAction func sendVerifyOTPBtnClick(_ sender: Any) {
        
        var apiParameters: [String: Any]? = nil
        
        self.phone = phoneNumberField.txtInputField.text ?? ""
        
        if isOTPSent {
            let otp = otpView.getOTP()
            
            if verificationType == "otpLogin" || verificationType == "changePassword"{
                apiParameters = [
                    "login_via": "phone",
                    "value": phone,
                    "otp": otp
                ]
            } else if verificationType == "create"{
                apiParameters = [
                    "user_register_id": self.user_register_id,
                    "otp": otp
                ]
            }
            
            
            
            verifyOTP(verificationType: verificationType, apiParameters: apiParameters)
            
        }else {
            
            if phone.isEmpty {
                phoneNumberField.showError("Field can't be empty")
                return
            } else if phone.count < 10 {
                phoneNumberField.showError("Invalid Number")
                return
            }
            
            
            sendOTP(verificationType: verificationType)
        }
        
        
    }
    

    
    func sendOTP(verificationType: String) {
        startResendTimer()
        LoadingManager.shared.show(on: self.view)
        
        var apiParameters: [String: Any]? = nil
        
        if verificationType == "otpLogin" || verificationType == "changePassword"{
            apiParameters = [
                "login_via": "phone",
                "value": phone
            ]
        } else if verificationType == "create"{
            apiParameters = [
                "otp_channel": "phone",
                "first_name": first_name,
                "last_name": last_name,
                "email": email,
                "phone": phone,
                "password": password
            ]
        }
        
        var apiUrl: String = ""
        let apiMethod: String = "POST"
        
        if verificationType == "otpLogin" || verificationType == "changePassword"{
            apiUrl = APIEndpoints.OTPLogin
        } else if verificationType == "create"{
            apiUrl = APIEndpoints.register
        }
        
        // API Call
        NetworkManager.shared.callAPI(
            url: apiUrl,
            method: apiMethod,
            parameters: apiParameters
        ) { response, status, message in
            
            print("STATUS:", status)
            print("MESSAGE:", message)
            
            if status {
                if verificationType == "otpLogin" || verificationType == "changePassword"{
                    self.verificationUrl = response?["verify_otp_url"] as? String ?? ""
                    
                    self.verificationDescription.text = "Please enter the OTP received on your registered phone number. And don’t share your OTP with any one."
                    
                } else if verificationType == "create"{
                    self.user_register_id = response?["user_register_id"] as? String ?? ""
                    self.verificationUrl = response?["otp_verify_endpoint"] as? String ?? ""
                    
                    self.verificationDescription.text = "Please enter the OTP received on your \(self.phone). And don’t share your OTP with anyone."
                    
                    
                }
                
                self.isOTPSent = true
                self.phoneNumberField.isHidden = true
                self.otpView.isHidden = false
                self.navigationItem.hidesBackButton = false
                
                self.verificationTitle.text = "Enter the OTP"
                
                
                self.sendVerifiyOTPBtn.setTitle(self.isOTPSent ? "Verify" : "Send OTP", for: .normal)
                
                LoadingManager.shared.hide()
                
            } else {
                self.showToast(message: message)
                LoadingManager.shared.hide()
            }
        }
    }
    
    
    
    func verifyOTP(verificationType: String,apiParameters: [String: Any]? = nil) {
        LoadingManager.shared.show(on: self.view)
        
        var apiUrl: String = APIEndpoints.apiFolder + self.verificationUrl
        let apiMethod: String = "POST"
        
        
        // API Call
        NetworkManager.shared.callAPI(
            url: apiUrl,
            method: apiMethod,
            parameters: apiParameters
        ) { response, status, message in
            
            print("STATUS:", status)
            print("MESSAGE:", message)
            
            if status {
               
                // User Object
                if let userJson = response?["user"] as? [String: Any] {
                    
                    // Token
                    let token = userJson["token"] as? String ?? ""
                    
                    let userId = JWTUtils.getUserIdFromToken(token)
                    
                    OneSignal.login(userId)
                    
                    // Save Token
                    PreferenceManager.shared.setAuthToken(token)
                    
                    if verificationType == "changePassword"{
                                                
                        NavigationManager.pushScreen(
                               from: self,
                               storyboardName: "Auth",
                               viewControllerID: "RestPasswordVC",
                               data: [
                                       "userId": userId
                                   ]
                           )
                    } else {
                        
                        
                        let isTrackingOn = userJson["is_tracking_on"] as? Bool ?? false
                        PreferenceManager.shared.setBool(value: isTrackingOn, key: PreferenceManager.Keys.liveTracking)
                        
                        let isNotificationOn = userJson["is_notification_sound_on"] as? Bool ?? false
                        PreferenceManager.shared.setBool(value: isNotificationOn, key: PreferenceManager.Keys.notificationSound)
                        
                        if !userId.isEmpty  {
                            PreferenceManager.shared.setUserId(userId)
                            
                            let userData = CommonFunctions.parseUserFromJson(userJson)
                            
                            PreferenceManager.shared.saveUser(userData)
                        }
                        
                        if verificationType == "otpLogin" || verificationType == "create"{
                            
                            PreferenceManager.shared.setLoggedIn(true)
                            
                            // Move Next Screen
                            NavigationManager.moveToNavigationController(
                                from: self,
                                storyboardName: "Main",
                                navigationControllerID: "MainNavigationController"
                            )
                        }
                    }
                }
                
                LoadingManager.shared.hide()
                
                
            } else {
                self.showToast(message: message)
                LoadingManager.shared.hide()
            }
        }
    }
    
    
    @objc func backPress() {
        
        let alert = UIAlertController(
                    title: "Cancel Verification",
                    message: "Do you want to cancel the OTP verification process?",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "No", style: .cancel))

                alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                    
                    if self.verificationType == "otpLogin" || self.verificationType == "create" || !self.isOTPSent{
//                        NavigationManager.moveToScreen(
//                            from: self,
//                            storyboardName: "Auth",
//                            viewControllerID: "LoginScreenVC"
//                        )
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    else {
                        
                        self.isOTPSent = false
                        self.phoneNumberField.isHidden = false
                        self.otpView.isHidden = true
                        self.navigationItem.hidesBackButton = true
                        
                        // Optional
                        self.otpView.clearOTP()
                        
                        self.sendVerifiyOTPBtn.setTitle(self.isOTPSent ? "Verify" : "Send OTP", for: .normal)
                    }
                })

                present(alert, animated: true)
        
    }
    
    @objc func onResendOTPClick() {

        guard remainingSeconds <= 0 else {
            return
        }
        
        // Call Resend OTP API Here
        sendOTP(verificationType: verificationType)

    }
    
    func startResendTimer() {

        remainingSeconds = 30

        resendOtpBtn.textColor = UIColor(named: "textDescription")
        resendOtpBtn.isUserInteractionEnabled = false

        updateTimerText()

        resendTimer?.invalidate()

        resendTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateResendTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateResendTimer() {

        remainingSeconds -= 1

        updateTimerText()

        if remainingSeconds <= 0 {

            resendTimer?.invalidate()
            resendTimer = nil
  
            resendOtpBtn.text = "Resend OTP"
            resendOtpBtn.textColor = UIColor(named: "iconColor")
            resendOtpBtn.isUserInteractionEnabled = true
        }
    }
    
    func updateTimerText() {
        resendOtpBtn.text = "Resend OTP in \(remainingSeconds)s"
    }
    
}
