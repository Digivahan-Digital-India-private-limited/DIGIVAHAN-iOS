//
//  VirtualQRListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit
import SDWebImage

class NotificationListVC: BaseViewController {

    
    @IBOutlet var minView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var notificationList: [NotificationItemModel] = []

    var currentPage = 1
    var totalPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotificationList()
        
    }

    private func setUI() {

        title = "Notification List"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        tableView.separatorStyle = .none

    }
    
    func getNotificationList() {

        notificationList.removeAll()
        tableView.reloadData()

        let userId = PreferenceManager.shared.getUserId()

        let url = APIEndpoints.GET_NOTIFICATION + "\(userId)?current_page=\(currentPage)"

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                do {
                    guard
                        let dataArray = response?["data"] as? [[String: Any]],
                        let pagination = response?["pagination"] as? [String: Any]
                    else {
                        return
                    }

                    print("Pagination: \(pagination)")

                    for data in dataArray {
                        var model = NotificationItemModel()

                        model._id = data["_id"] as? String ?? ""
                        model.sender_id = data["sender_id"] as? String ?? ""
                        model.sender_pic = data["sender_pic"] as? String ?? ""
                        model.sender_name = data["sender_name"] as? String ?? ""
                        model.notification_type = data["notification_type"] as? String ?? ""
                        model.notification_title = data["notification_title"] as? String ?? ""
                        model.link = data["link"] as? String ?? ""
                        model.vehicle_id = data["vehicle_id"] as? String ?? ""
                        model.order_id = data["order_id"] as? String ?? ""
                        model.message = data["message"] as? String ?? ""
                        model.issue_type = data["issue_type"] as? String ?? ""
                        model.chat_room_id = data["chat_room_id"] as? String ?? ""
                        model.latitude = data["latitude"] as? String ?? ""
                        model.longitude = data["longitude"] as? String ?? ""
                        model.time = data["time"] as? String ?? ""
                        model.createdAt = data["createdAt"] as? String ?? ""
                        model.updatedAt = data["updatedAt"] as? String ?? ""
                        model.seen_status = data["seen_status"] as? Bool ?? true
                        model.inapp_notification = data["inapp_notification"] as? Bool ?? true
                        model.incident_proof = data["incident_proof"] as? [String] ?? []

                        print("""
                        ========== Notification ==========
                        ID: \(model._id ?? "")
                        Sender ID: \(model.sender_id ?? "")
                        Sender Name: \(model.sender_name ?? "")
                        Sender Pic: \(model.sender_pic ?? "")
                        Notification Type: \(model.notification_type ?? "")
                        Title: \(model.notification_title ?? "")
                        Message: \(model.message ?? "")
                        Vehicle ID: \(model.vehicle_id ?? "")
                        Order ID: \(model.order_id ?? "")
                        Chat Room ID: \(model.chat_room_id ?? "")
                        Issue Type: \(model.issue_type ?? "")
                        Latitude: \(model.latitude ?? "")
                        Longitude: \(model.longitude ?? "")
                        Created At: \(model.createdAt ?? "")
                        Updated At: \(model.updatedAt ?? "")
                        Seen Status: \(model.seen_status ?? false)
                        In-App Notification: \(model.inapp_notification ?? false)
                        Incident Proof: \(model.incident_proof ?? [])
                        =================================
                        """)

                        self.notificationList.append(model)
                    }

                } catch {
                    print("🔥 Decode Error:", error.localizedDescription)
                    self.setEmptyLayout(true)
                    self.showToast(message: "Parsing Error")
                }
                
                updateGarageUI()

            } else {

                self.setEmptyLayout(true)

                if message.lowercased() == "no internet connection" {

//                    self.showNoInternetDialog()

                } else {

                    self.showToast(message: "Vehicle not found")
                }
            }
        }
    }

    
    

    
    func updateGarageUI() {

        tableView.reloadData()

        listView.isHidden = notificationList.isEmpty
        emptyView.isHidden = !notificationList.isEmpty
    }
    
    func setEmptyLayout(_ isEmpty: Bool) {
        emptyView.isHidden = !isEmpty
        listView.isHidden = isEmpty
    }
    
}

extension NotificationListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return notificationList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let notificationListItem = notificationList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationListCell",
            for: indexPath
        ) as! NotificationListCell

        cell.selectionStyle = .none

        // Name
        cell.ownerName.text = notificationListItem.sender_name
        cell.notificationMessage.text = notificationListItem.issue_type

        // Number
        cell.notificationDate.text = notificationListItem.createdAt

        // Image
        cell.ownerImage.image = UIImage(
            named: "ic_vehicle_default"
        )

        // Preview button click
        cell.previewAction = { [weak self] in

            guard let self = self else { return }

            self.previewNotification(notificationListItem)
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let notificationListItem = notificationList[indexPath.row]

        previewNotification(notificationListItem)
    }
    
    
    func previewNotification(_ notificationListItem: NotificationItemModel) {
        
        
        let sharedData: [String: Any] = [
            "notificationListItem": notificationListItem
        ]

        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "ViewNotificationVC",
            data: sharedData
        )
    }
}
