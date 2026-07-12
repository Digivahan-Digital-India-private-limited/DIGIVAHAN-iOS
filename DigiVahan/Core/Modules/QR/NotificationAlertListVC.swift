//
//  EmergencyContactsListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//


import UIKit
import SDWebImage

class NotificationAlertListVC: BaseViewController {

    var isEditable = true
    private var qrItem: QRDataModel?
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAge: UILabel!
    @IBOutlet weak var ownerGender: UILabel!
    @IBOutlet weak var ownerLocation: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var sendAlertBtn: UIButton!
    private var countdownTimer: Timer?
    private var remainingSeconds = 30
    private var isOtherAlerDisabled:Bool = false
    
    @IBOutlet weak var parkingViewBtn: UIView!
    @IBOutlet weak var congestedParkingViewBtn: UIView!
    @IBOutlet weak var roadBlockAlertViewBtn: UIView!
    @IBOutlet weak var blockedVehicleAlertViewBtn: UIView!
    @IBOutlet weak var carLightsWindowsLeftOpenViewBtn: UIView!
    @IBOutlet weak var carHornOrAlarmGoingOffViewBtn: UIView!
    @IBOutlet weak var unknownIssueAlertViewBtn: UIView!
    @IBOutlet weak var accidentAlertViewBtn: UIView!
    @IBOutlet weak var requestForDocumentAccessViewBtn: UIView!
    
    private var selectedAlertViewBtn: UIView?
    
    private var notification_type: String = "vehicle"
    private var notificationTitle: String = "No parking"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.requestLocationPermission()
        LocationManager.shared.startUpdatingLocation()
        
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        getEmergencyContactList()
    }
    
    @IBAction func sendAlertBtnClicked(_ sender: Any) {
        guard let selectedView = selectedAlertViewBtn else {
                showToast(message: "Please select an alert")
                return
            }

        var notificationIssueType = ""
        var notificationIssueMessage = ""
        var isVaultAccess = false

        switch selectedView {

        case parkingViewBtn:
            notificationTitle = "No Parking"
            notificationIssueType = "no_parking"
            notificationIssueMessage = "Your car is parking in no parking zone."

        case congestedParkingViewBtn:
            notificationTitle = "Congested Parking"
            notificationIssueType = "congested_parking"
            notificationIssueMessage = """
            Your vehicle has been identified as causing parking congestion in the area.
            Kindly move your vehicle to a suitable parking space to avoid inconvenience to others.
            """

        case roadBlockAlertViewBtn:
            notificationTitle = "Road Block Alert"
            notificationIssueType = "road_block_alert"
            notificationIssueMessage = """
            Your vehicle has been identified as obstructing traffic flow and causing a road block.
            Please move your vehicle immediately to clear the way and ensure smooth movement for others.
            """

        case blockedVehicleAlertViewBtn:
            notificationTitle = "Blocked Vehicle Alert"
            notificationIssueType = "blocked_vehicle_alert"
            notificationIssueMessage = """
            Your vehicle is blocking another parked vehicle.
            Please move your vehicle promptly to allow the other driver to exit smoothly.
            """

        case carLightsWindowsLeftOpenViewBtn:
            notificationTitle = "Car Lights Windows Left Open"
            notificationIssueType = "car_lights_windows_left_open"
            notificationIssueMessage = "⚠️ Your car lights or windows are open. Please check your vehicle immediately for safety."

        case carHornOrAlarmGoingOffViewBtn:
            notificationTitle = "Car Horn Alarm Going On"
            notificationIssueType = "car_horn_alarm_going_on"
            notificationIssueMessage = "Your car alarm or horn is going off. Please check your vehicle immediately."

        case unknownIssueAlertViewBtn:
            notificationTitle = "Unknown Issue Alert"
            notificationIssueType = "unknown_issue_alert"
            notificationIssueMessage = "🚗 An unknown issue has been detected with your vehicle. Please inspect it for safety."

        case accidentAlertViewBtn:
            notificationTitle = "Accident Alert"
            notificationIssueType = "accident_alert"
            notificationIssueMessage = "⚠️ Your vehicle may have been involved in an accident. Please check immediately."
            
            self.qrItem?.notificationType = "chat"
            self.qrItem?.issueType = notificationIssueType
            self.qrItem?.issueMessage = notificationIssueMessage
            self.qrItem?.notificationTitle = notificationTitle

            NavigationManager.pushScreen(
                from: self,
                viewControllerID: "CustomNotificationAlertVC",
                closeCurrentScreen: true,
                data: [
                        "qrItem": qrItem
                    ]
            )
            return

        case requestForDocumentAccessViewBtn:
            isVaultAccess = true
            notificationTitle = "Doc Access"
            self.qrItem?.notificationType = "doc_access"
            notificationIssueType = "doc_access"
            notificationIssueMessage = "⚠️ You've received a request for document access. Please review and approve if appropriate."

        default:
            showToast(message: "Invalid alert selected")
            return
        }
        
        disableOtherViews()
        
        sendNotification(receiver_id: qrItem?.assigned_to, notification_type: notification_type, issue_type: notificationIssueType, issueMessage: notificationIssueMessage, notification_title: notificationTitle, vehicle_id: qrItem?.vehicle_id, isVaultAccess: isVaultAccess)
    }
    
    private func setUI() {

        title = "Scan QR Code"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]
        
        
        if let data = receivedData as? [String: Any] {

            self.qrItem = data["qrItem"] as? QRDataModel ?? nil
            getOwnerDetails(ownerId: qrItem?.assigned_to)
            
            
        }
        
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        
        onAlertViewClicked(selectedView: nil)
        
        alertViews.forEach {
            addTapGesture(to: $0)
        }
        
        enableSendButton()
        
    }
    
    private func disableOtherViews() {
        
        self.isOtherAlerDisabled = true

        for view in alertViews {

            if view != selectedAlertViewBtn {
                setCardSelected(
                    isSelected: false,
                    clickedView: view
                )
            }
        }
        
        disableSendButton()
        
    }
    
    private func disableSendButton() {

        if #available(iOS 15.0, *) {

            var config = sendAlertBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "textDescription")
            config?.baseForegroundColor = .white
            sendAlertBtn.configuration = config
        } else {

            sendAlertBtn.backgroundColor = UIColor(named: "textDescription")
            sendAlertBtn.setTitleColor(.white, for: .normal)
        }

        sendAlertBtn.isEnabled = false
    }
    
    private func enableSendButton() {

        if #available(iOS 15.0, *) {

            var config = sendAlertBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "iconColor")
            config?.baseForegroundColor = .white
            sendAlertBtn.configuration = config
        } else {

            sendAlertBtn.backgroundColor = UIColor(named: "iconColor")
            sendAlertBtn.setTitleColor(.white, for: .normal)
        }

        sendAlertBtn.isEnabled = true
    }
    
    private func startCountdown(
        issueType: String,
        issueMessage: String
    ) {

        remainingSeconds = 30

        sendAlertBtn.setTitle("Wait (\(remainingSeconds))", for: .normal)

        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in

            guard let self = self else { return }

            self.remainingSeconds -= 1

            self.sendAlertBtn.setTitle(
                "Wait (\(self.remainingSeconds))",
                for: .normal
            )

            if self.remainingSeconds <= 0 {

                timer.invalidate()

                self.sendAlertBtn.setTitle(
                    "Send Notification",
                    for: .normal
                )
                
                enableSendButton()
                
                NavigationManager.pushScreen(
                    from: self,
                    viewControllerID: "CustomNotificationAlertVC",
                    closeCurrentScreen: true,
                    data: [
                            "qrItem": qrItem
                        ]
                )
            }
        }
    }
    
    private func addTapGesture(to view: UIView) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(alertViewTapped(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func alertViewTapped(_ sender: UITapGestureRecognizer) {

        guard let clickedView = sender.view else {
            return
        }

        onAlertViewClicked(selectedView: clickedView)
    }
    
    
    func sendNotification(receiver_id: String?, notification_type: String?, issue_type: String?, issueMessage: String?, notification_title: String?, vehicle_id: String?, isVaultAccess: Bool?) {

        LoadingManager.shared.show(on: view)


        var params: [String: Any] = [
            "sender_id": PreferenceManager.shared.getUserId(),
            "receiver_id": receiver_id ?? "",
            "notification_type": notification_type ?? "",
            "issue_type": issue_type ?? "",
            "notification_title": notification_title ?? "",
            "message": issueMessage ?? "",
            "vehicle_id": vehicle_id ?? ""
        ]
        
        if let latitude = LocationManager.shared.latitude,
           let longitude = LocationManager.shared.longitude {

            params["latitude"] = latitude
            params["longitude"] = longitude
        }

        NetworkManager.shared.callAPI(
            url: APIEndpoints.SEND_NOTIFICATION,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {
                self.qrItem?.notificationType = notification_type
                self.qrItem?.issueType = issue_type
                self.qrItem?.issueMessage = issueMessage
                self.qrItem?.notificationTitle = notification_title

                if isVaultAccess == true {
                    
                }else{
                    self.startCountdown(issueType: issue_type ?? "", issueMessage: issueMessage ?? "")
                }
            }
        }
    }


    
    
    func getOwnerDetails(ownerId: String? = "") {

        LoadingManager.shared.show(on: view)

        let params: [String: Any] = [
            "user_id": ownerId ?? "",
            "details_type": "all"
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                if let data = response?["data"] as? [String: Any] {

                    // Public Details
                    let publicDetails = data["public_details"] as? [String: Any]

                    self.qrItem?.public_pic = publicDetails?["public_pic"] as? String ?? ""
                    self.qrItem?.nick_name = publicDetails?["nick_name"] as? String ?? ""
                    self.qrItem?.gender = publicDetails?["gender"] as? String ?? ""
                    self.qrItem?.address = publicDetails?["address"] as? String ?? ""
                    self.qrItem?.age = TimeUtils.getDatePart(
                        from: publicDetails?["age"] as? String ?? "",
                        type: "age"
                    )

                    // Basic Details
                    let basicDetails = data["basic_details"] as? [String: Any]

                    self.qrItem?.ownerNumber = basicDetails?["phone_number"] as? String ?? ""

                    // Set UI
                    self.ownerName.text = self.qrItem?.nick_name
                    self.ownerGender.text = self.qrItem?.gender
                    self.ownerLocation.text = self.qrItem?.address
                    self.ownerAge.text = "\(self.qrItem?.age ?? "") year old"

                    self.userProfileImage.sd_setImage(
                        with: URL(string: self.qrItem?.public_pic ?? ""),
                        placeholderImage: UIImage(named: "defaultProfileIcon")
                    )
                }
            }
        }
    }
    
    
    
    private var alertViews: [UIView] {
        [
            parkingViewBtn,
            congestedParkingViewBtn,
            roadBlockAlertViewBtn,
            blockedVehicleAlertViewBtn,
            carLightsWindowsLeftOpenViewBtn,
            carHornOrAlarmGoingOffViewBtn,
            unknownIssueAlertViewBtn,
            accidentAlertViewBtn,
            requestForDocumentAccessViewBtn
        ]
    }

    private func onAlertViewClicked(selectedView: UIView?) {

        alertViews.forEach {
            setCardSelected(isSelected: false, clickedView: $0)
        }

        if let selectedView = selectedView {
            self.selectedAlertViewBtn = selectedView
            setCardSelected(isSelected: true, clickedView: selectedView)
        } else {
            self.selectedAlertViewBtn = nil
        }
    }
    
    
    private func setCardSelected(
        isSelected: Bool,
        clickedView: UIView
    ) {

        clickedView.layer.cornerRadius = 16
        clickedView.layer.masksToBounds = true
        clickedView.layer.borderWidth = 3

        if isSelected {

            // Selected view can never be disabled
            clickedView.backgroundColor = .white
            clickedView.layer.borderColor = (
                UIColor(named: "iconColor") ?? .systemBlue
            ).cgColor

            clickedView.isUserInteractionEnabled = true

        } else if self.isOtherAlerDisabled {

            // Disabled view
            clickedView.backgroundColor = UIColor(named: "textDescription")
            clickedView.layer.borderColor = (
                UIColor(named: "textDescription") ?? .lightGray
            ).cgColor

            clickedView.isUserInteractionEnabled = false

        } else {

            // Normal view
            clickedView.backgroundColor = .white
            clickedView.layer.borderColor = (
                UIColor(named: "textDescription") ?? .lightGray
            ).cgColor

            clickedView.isUserInteractionEnabled = true
        }
    }
}
