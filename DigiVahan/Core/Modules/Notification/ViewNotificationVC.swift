//
//  MainPage.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/05/26.
//

import UIKit

class ViewNotificationVC: BaseViewController {
        
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var mapBtnLayout: UIView!
    @IBOutlet weak var notificationDescription: UILabel!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var callBtnLayout: UIView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    private var notificationListItem : NotificationItemModel?
    
    private var ownerContect : String? = ""
    private var countdownTimer: Timer?
    private var remainingSeconds = 30
    
    // MARK: - Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
                
        // Receive Data
        if let data = receivedData as? [String: Any] {
            notificationListItem = data["notificationListItem"] as? NotificationItemModel ?? nil
        }
        
        if notificationListItem != nil {
            
            notificationTitle.text = notificationListItem?.notification_title
            notificationDescription.text = notificationListItem?.message
            
            if (notificationListItem?.latitude != nil && notificationListItem?.latitude != "") && (notificationListItem?.longitude != nil && notificationListItem?.longitude != ""){
                mapBtn.isHidden = false
            } else {
                mapBtn.isHidden = true
            }
            
            if notificationListItem?.notification_type == "chat" {
                getOwnerContect(userId: notificationListItem?.sender_id ?? "")
            }
            
            if notificationListItem?.issue_type == "no_parking" {
                notificationTypeImage.image = UIImage(named: "parkingIcon")
            } else if notificationListItem?.issue_type == "congested_parking" {
                notificationTypeImage.image = UIImage(named: "congestedparkingIcon")
            } else if notificationListItem?.issue_type == "road_block_alert" {
                notificationTypeImage.image = UIImage(named: "roadBlockAlertIcon")
            } else if notificationListItem?.issue_type == "blocked_vehicle_alert" {
                notificationTypeImage.image = UIImage(named: "blockedVehicleAlertIcon")
            } else if notificationListItem?.issue_type == "car_lights_windows_left_open" {
                notificationTypeImage.image = UIImage(named: "carLightsWindowsLeftOpenIcon")
            } else if notificationListItem?.issue_type == "car_horn_alarm_going_on" {
                notificationTypeImage.image = UIImage(named: "carHornOrAlarmGoingOnIcon")
            } else if notificationListItem?.issue_type == "unknown_issue_alert" {
                notificationTypeImage.image = UIImage(named: "unknownIssueAlertIcon")
            } else if notificationListItem?.issue_type == "accident_alert" {
                notificationTypeImage.image = UIImage(named: "accidentAlertIcon")
            }
      
        }
        
        
        mapBtn.backgroundColor = .red
        mapBtn.layer.borderWidth = 2
        mapBtn.layer.borderColor = UIColor.green.cgColor
        
        
        getOwnerContect(userId: notificationListItem?.sender_id ?? "")
        
        
    }
   
    @IBAction func callBtnClicked(_ sender: Any) {
        self.makeCall(receiverNumber: ownerContect)
    }
    @IBAction func mapClicked(_ sender: Any) {
        showToast(message: "Unable to find location")
        if (notificationListItem?.latitude != nil && notificationListItem?.latitude != "") && (notificationListItem?.longitude != nil && notificationListItem?.longitude != ""){
            showToast(message: "Unable to find location")
            CommonFunctions.openGoogleMaps(latitude: notificationListItem?.latitude, longitude: notificationListItem?.longitude)
        } else {
            showToast(message: "Unable to find location")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Button frame:", mapBtn.frame)

           let point = CGPoint(x: mapBtn.frame.midX, y: mapBtn.frame.midY)

           if let hitView = view.hitTest(point, with: nil) {
               print("Hit View:", hitView)
           }
    }
    
    
    func makeCall(receiverNumber: String?) {
        
        print("receiverNumber:- \(String(describing: receiverNumber))")

        LoadingManager.shared.show(on: view)


        let params: [String: Any] = [
            "agent": PreferenceManager.shared.getUser()?.phoneNumber ?? "",
            "receiver": receiverNumber ?? ""
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.CONTACT_VIA_CALL,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                self.showToast(message: "Call initiated successfully")
                
                self.disableCallButton()
                
                self.startCountdown()
            } else {
                self.showToast(message: "Can't initiate a Call")
            }
        }
    }
    
    private func disableCallButton() {

        if #available(iOS 15.0, *) {

            var config = self.callBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "textDescription")
            config?.baseForegroundColor = .white
            self.callBtn.configuration = config
        } else {

            self.callBtn.backgroundColor = UIColor(named: "textDescription")
            self.callBtn.setTitleColor(.white, for: .normal)
        }

        self.callBtn.isEnabled = false
    }
    
    private func enableCallButton() {

        if #available(iOS 15.0, *) {

            var config = self.callBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "iconColor")
            config?.baseForegroundColor = .white
            self.callBtn.configuration = config
        } else {

            self.callBtn.backgroundColor = UIColor(named: "iconColor")
            self.callBtn.setTitleColor(.white, for: .normal)
        }

        self.callBtn.isEnabled = true
    }
    
    private func startCountdown() {

        remainingSeconds = 30

        self.callBtn.setTitle("Wait (\(remainingSeconds))", for: .normal)

        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in

            guard let self = self else { return }

            self.remainingSeconds -= 1

            self.callBtn.setTitle(
                "Wait (\(self.remainingSeconds))",
                for: .normal
            )

            if self.remainingSeconds <= 0 {

                timer.invalidate()

                self.callBtn.setTitle(
                    "Call",
                    for: .normal
                )
                
                enableCallButton()
            }
        }
    }
    
    
    private func getOwnerContect(userId: String) {

        let params: [String: Any] = [
            "user_id": userId,
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
                    
                    let phone = data["phone_number"] as? String ?? ""
                    if !phone.isEmpty {
                        self.ownerContect = phone
                        self.callBtnLayout.isHidden = false
                    }
                    else {
                        self.callBtnLayout.isHidden = true
                    }

                }
            }
        }
    }
    
    
}
