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
    @IBOutlet weak var pickImageViewBtn: UIView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var sendAlertBtn: UIButton!
    
    @IBOutlet weak var messageField: UITextView!
    
    var selectedImageList: [SavedImageData] = []
    
    private var chatRoomId: String? = "empty"
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        
        LocationManager.shared.requestLocationPermission()
        LocationManager.shared.startUpdatingLocation()
        
        createChatRoom(receiver_id: qrItem?.assigned_to)
        
        setUI()

    }
    
    
    @IBAction func sendAlertBtnClicked(_ sender: Any) {
        
        if selectedImageList.isEmpty {
            showToast(message: "Please select atleast one image")
            return
        } else if selectedImageList.count > 3{
            showToast(message: "You can select maximum 3 images")
            return
        }
        
        sendNotification(receiver_id: qrItem?.assigned_to, notification_type: qrItem?.notificationType, issue_type: qrItem?.issueType, issueMessage: messageField.text ?? qrItem?.issueMessage, notification_title: qrItem?.notificationTitle, vehicle_id: qrItem?.vehicle_id)
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
        
        CommonFunctions.addDashedBorder(to: pickImageViewBtn)
        
        // set updateBasicDetailsBtn
        pickImageViewBtn.isUserInteractionEnabled = true

            let pickImageViewBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(pickImageViewBtnClick)
            )

        pickImageViewBtn.addGestureRecognizer(pickImageViewBtnTap)
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
       
    }
    
    @objc private func pickImageViewBtnClick() {
        ImagePickerHelper.shared.openCameraDirectly(from: self) { image in

            guard let image = image else { return }
            
            LoadingManager.shared.show(on: self.view)
            
            NetworkManager.shared.uploadSingleImage(
                image: image, folderName: "vehicle-alert-image"
            ) { [weak self] success, message, response in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    LoadingManager.shared.hide()
                                        
                    if success {
                        
                        if let data = response?["data"] as? [String: Any] {
                            
                            var savedImage = SavedImageData()
                            
                            savedImage.image_url = data["image_url"] as? String ?? ""
                            savedImage.public_id = data["public_id"] as? String ?? ""
                            savedImage.folder = data["folder"] as? String ?? ""
                            savedImage.imageFile = image
                            
                            self.selectedImageList.append(savedImage)
                            self.imageCollectionView.reloadData()
                        }
                        
                    } else {
                        self.showToast(message: "Unable to complete the task. Please try again.")
                    }
                }
            }
            
        }
    }

    
    func sendNotification(receiver_id: String?, notification_type: String?, issue_type: String?, issueMessage: String?, notification_title: String?, vehicle_id: String?) {
        
        var incidentProof: [String] = []

        for item in selectedImageList {

            if let imageURL = item.image_url,
               !imageURL.isEmpty {

                incidentProof.append(imageURL)
            }
        }
        
        
        LoadingManager.shared.show(on: view)


        var params: [String: Any] = [
            "sender_id": PreferenceManager.shared.getUserId(),
            "receiver_id": receiver_id ?? "",
            "notification_type": notification_type ?? "",
            "issue_type": issue_type ?? "",
            "notification_title": notification_title ?? "",
            "message": issueMessage ?? "",
            "vehicle_id": vehicle_id ?? "",
            "seen_status": false,
                       "incident_proof": incidentProof
        ]
        
        if chatRoomId != "empty" {
                    params["chat_room_id"] = chatRoomId
                }
        
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
                NavigationManager.pushScreen(
                                    from: self,
                                    viewControllerID: "OwnerProfileVC",
                                    closeCurrentScreen: true,
                                    data: [
                                        "qrItem": self.qrItem
                                        ]
                                )
            }
        }
        
        
    }
    
    func createChatRoom(receiver_id: String?) {
        
        var members: [String] = []
        members.append(receiver_id ?? "")


        LoadingManager.shared.show(on: view)


        let params: [String: Any] = [
            "createdBy": PreferenceManager.shared.getUserId(),
            "members": members,
            "type": "direct"
        ]
        
        
        NetworkManager.shared.callAPI(
            url: APIEndpoints.CREATE_CHAT_ROOM,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                if let data = response?["room"] as? [String: Any] {
                                    
                    self.chatRoomId = data["_id"] as? String ?? ""
                    
                    print("✅ chatRoomId: \(self.chatRoomId ?? "")")
                    
                }
            }
        }
    }
    
    
    @objc func removeImage(_ sender: UITapGestureRecognizer) {

        guard let index = sender.view?.tag else {
            return
        }
        
        LoadingManager.shared.show(on: view)
        
        let params: [String: Any] = [
            "public_id": selectedImageList[index].public_id ?? ""
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.DELETE_SINGLE_FILE,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {
                self.selectedImageList.remove(at: index)
                self.imageCollectionView.reloadData()
            }
        }
    }

}


extension CustomNotificationAlertVC:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return selectedImageList.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NotificationImageCell",
            for: indexPath
        ) as! NotificationImageCell

        let item = selectedImageList[indexPath.row]

//        cell.fieldProfileIcon.layer.cornerRadius = 16
//        cell.fieldProfileIcon.clipsToBounds = true
        
        CommonFunctions.addDashedBorder(to: cell.cardView)

        cell.closeIcon.isUserInteractionEnabled = true
        cell.closeIcon.tag = indexPath.row

        let tap = UITapGestureRecognizer(  
            target: self,
            action: #selector(removeImage(_:))
        )

        cell.closeIcon.addGestureRecognizer(tap)

        // Prefer local image
        if let image = item.imageFile {

            cell.fieldProfileIcon.image = image

        } else {
            cell.fieldProfileIcon.sd_setImage(
                with: URL(string: item.image_url ?? ""),
                placeholderImage: UIImage(named: "emptyImage")
            )
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(width: 90, height: 90)
    }
}
