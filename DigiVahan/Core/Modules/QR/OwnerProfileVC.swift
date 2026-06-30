//
//  EmergencyContactsListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//


import UIKit
import SDWebImage

class CustomNotificationAlertVC: BaseViewController {

    private var qrItem: QRDataModel?
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAge: UILabel!
    @IBOutlet weak var ownerGender: UILabel!
    @IBOutlet weak var ownerLocation: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var sendAlertBtn: UIButton!
    
    @IBOutlet weak var messageField: UITextView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setUI()

    }
    
    
    @IBAction func sendAlertBtnClicked(_ sender: Any) {
        
    }
    
    private func setUI() {

        title = "Notification"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]
        
        
        if let data = receivedData as? [String: Any] {

            self.qrItem = data["qrItem"] as? QRDataModel ?? nil
            
            
        }
        
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        messageField.layer.cornerRadius = 16
            messageField.layer.borderWidth = 1.5
            messageField.layer.borderColor =
                (UIColor(named: "iconColor") ?? .systemBlue).cgColor

            messageField.textContainerInset = UIEdgeInsets(
                top: 12,
                left: 12,
                bottom: 12,
                right: 12
            )

            messageField.font = UIFont.systemFont(ofSize: 16)
        
        
        self.ownerName.text = self.qrItem?.nick_name
        self.ownerGender.text = self.qrItem?.gender
        self.ownerLocation.text = self.qrItem?.address
        self.ownerAge.text = "\(self.qrItem?.age ?? "") year old"
        
        self.userProfileImage.sd_setImage(
            with: URL(string: self.qrItem?.public_pic ?? ""),
            placeholderImage: UIImage(named: "defaultProfileIcon")
        )
        
        
        sendNotification(receiver_id: qrItem?.assigned_to, notification_type: qrItem?.notificationType, issue_type: qrItem?.issueType, issueMessage: qrItem?.issueMessage, notification_title: qrItem?.notificationTitle, vehicle_id: qrItem?.vehicle_id)
       
    }

    
    func sendNotification(receiver_id: String?, notification_type: String?, issue_type: String?, issueMessage: String?, notification_title: String?, vehicle_id: String?) {

        LoadingManager.shared.show(on: view)


        let params: [String: Any] = [
            "token": PreferenceManager.shared.getAuthToken(),
            "sender_id": PreferenceManager.shared.getUserId(),
            "receiver_id": receiver_id ?? "",
            "notification_type": notification_type ?? "",
            "issue_type": issue_type ?? "",
            "notification_title": notification_title ?? "",
            "message": issueMessage ?? "",
            "vehicle_id": vehicle_id ?? ""
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.SEND_NOTIFICATION,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                NavigationManager.pushScreen(
                    from: self,
                    viewControllerID: "CustomNotificationAlertVC",
                    closeCurrentScreen: true,
                    data: [
                        "qrItem": self.qrItem
                        ]
                )
            }
        }
    }

}
