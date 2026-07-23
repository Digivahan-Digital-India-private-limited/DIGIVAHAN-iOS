//
//  MainPage.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/05/26.
//

import UIKit
import SDWebImage

class ViewNotificationVC: BaseViewController  {
        
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var mapBtnLayout: UIView!
    @IBOutlet weak var notificationDescription: UILabel!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var callBtnLayout: UIView!
    @IBOutlet weak var notificationTypeImage: UIImageView!
    private var notificationListItem : NotificationItemModel?
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewImageLayout: UIView!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewImageCloseIcon: UIImageView!
    
    private var ownerContect : String? = ""
    private var countdownTimer: Timer?
    private var remainingSeconds = 30
    
    // MARK: - Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backPressed)
            )
         
        // Receive Data
        if let data = receivedData as? [String: Any] {
            notificationListItem = data["notificationListItem"] as? NotificationItemModel ?? nil
        }
        
        if let item = notificationListItem {
                print("========== Notification Item ==========")
                print("sender_id: \(item.sender_id ?? "nil")")
                print("sender_pic: \(item.sender_pic ?? "nil")")
                print("sender_name: \(item.sender_name ?? "nil")")
                print("notification_type: \(item.notification_type ?? "nil")")
                print("notification_title: \(item.notification_title ?? "nil")")
                print("link: \(item.link ?? "nil")")
                print("vehicle_id: \(item.vehicle_id ?? "nil")")
                print("order_id: \(item.order_id ?? "nil")")
                print("message: \(item.message ?? "nil")")
                print("issue_type: \(item.issue_type ?? "nil")")
                print("chat_room_id: \(item.chat_room_id ?? "nil")")
                print("latitude: \(item.latitude ?? "nil")")
                print("longitude: \(item.longitude ?? "nil")")
                print("_id: \(item._id ?? "nil")")
                print("time: \(item.time ?? "nil")")
                print("createdAt: \(item.createdAt ?? "nil")")
                print("updatedAt: \(item.updatedAt ?? "nil")")
                print("seen_status: \(String(describing: item.seen_status))")
                print("inapp_notification: \(String(describing: item.inapp_notification))")
                print("incident_proof: \(item.incident_proof ?? [])")
                print("=======================================")
            } else {
                print("notificationListItem is nil")
            }
        
        if notificationListItem != nil {
            
            if !(notificationListItem?.seen_status ?? true) {
                setSeenNotificationTrue(notification_id: notificationListItem?._id ?? "")
            }
            
            notificationTitle.text = notificationListItem?.notification_title
            notificationDescription.text = notificationListItem?.message
            
            if (notificationListItem?.latitude != nil && notificationListItem?.latitude != "") && (notificationListItem?.longitude != nil && notificationListItem?.longitude != ""){
                mapBtnLayout.isHidden = false
            } else {
                mapBtnLayout.isHidden = true
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        viewImageCloseIcon.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(closeViewImageBtnClicked(_:))
        )
        viewImageCloseIcon.addGestureRecognizer(tap)
        
    }
    
    @objc func backPressed() {

        if !viewImageLayout.isHidden {
            viewImageLayout.isHidden = true
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func closeViewImageBtnClicked(_ sender: UITapGestureRecognizer) {
        viewImageLayout.isHidden = true
    }
    
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {

        guard let card = sender.view else { return }

        let index = card.tag
        
        if let imageUrl = notificationListItem?.incident_proof?[index] {

            viewImage.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: UIImage(named: "emptyImage")
            )

        } else {

            viewImage.image = UIImage(named: "emptyImage")
        }
        
        viewImageLayout.isHidden = false
    }
   
    @IBAction func callBtnClicked(_ sender: Any) {
        self.makeCall(receiverNumber: ownerContect)
    }
    
    
    @IBAction func mapClicked(_ sender: Any) {
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
    
    private func setSeenNotificationTrue(notification_id: String) {
        
        // Params
        let params: [String: Any] = [
            "user_id": PreferenceManager.shared.getUserId(),
            "notification_id": notification_id
        ]
        
        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.SET_NOTIFICATION_SEEN,
            method: "POST",
            parameters: params
        ) { response, status, message in
                        
        }
        
    }
    
}

extension ViewNotificationVC:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {

            return notificationListItem?.incident_proof?.count ?? 0
        }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NotificationImageCell",
            for: indexPath
        ) as! NotificationImageCell

        CommonFunctions.addDashedBorder(to: cell.cardView)

        cell.cardView.tag = indexPath.row
        cell.cardView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(cardViewClicked(_:))
        )

        cell.cardView.gestureRecognizers?.removeAll()
        cell.cardView.addGestureRecognizer(tap)

        cell.closeIcon.isHidden = true

        if let imageUrl = notificationListItem?.incident_proof?[indexPath.row] {

            cell.fieldProfileIcon.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: UIImage(named: "emptyImage")
            )

        } else {

            cell.fieldProfileIcon.image = UIImage(named: "emptyImage")
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        print("Card Clicked: \(indexPath.row)")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(width: 90, height: 90)
    }
    
}
