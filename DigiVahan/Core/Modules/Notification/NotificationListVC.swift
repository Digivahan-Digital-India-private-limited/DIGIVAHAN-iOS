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
    @IBOutlet weak var pageCountLayout: UIView!
    @IBOutlet weak var pageCount: UILabel!
    @IBOutlet weak var previousArrowBtn: UIImageView!
    @IBOutlet weak var nextArrowBtn: UIImageView!
    
    var notificationList: [NotificationItemModel] = []

    var currentPage = 1
    var totalPage = 1
    var pageSize = 20
    var totalNotifications = 1

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

        
        nextArrowBtn.isUserInteractionEnabled = true

        let nextArrowBtnTap = UITapGestureRecognizer(
            target: self,
            action: #selector(nextArrowBtnClicked(_:))
        )
        nextArrowBtn.addGestureRecognizer(nextArrowBtnTap)
        
        previousArrowBtn.isUserInteractionEnabled = true

        let previousArrowBtnTap = UITapGestureRecognizer(
            target: self,
            action: #selector(previousArrowBtnClicked(_:))
        )
        previousArrowBtn.addGestureRecognizer(previousArrowBtnTap)
    }
    
    @objc func nextArrowBtnClicked(_ sender: UITapGestureRecognizer) {
        if currentPage == totalPage{
            showToast(message: "No Data Left")
        } else {
            currentPage += 1
            getNotificationList()
        }
        
    }
    
    @objc func previousArrowBtnClicked(_ sender: UITapGestureRecognizer) {
        if currentPage == 1{
            showToast(message: "No Data Left")
        } else {
            currentPage -= 1
            getNotificationList()
        }
        
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
                    
                    currentPage = pagination["current_page"] as? Int ?? 0
                    totalPage = pagination["total_pages"] as? Int ?? 0
                    pageSize = pagination["page_size"] as? Int ?? 0
                    totalNotifications = pagination["total_notifications"] as? Int ?? 0
                    
                    pageCount.text = "\(currentPage) / \(totalPage)"
                    
                    if totalPage == 0{
                        pageCountLayout.isHidden = true
                    }

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

                    self.showToast(message: "Notification not found")
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
        var dateFormat: String = "dd MMM yyyy"
        if PreferenceManager.getCurrentDate(dateFormat) == TimeUtils.convertDateFormat(TimeUtils.convertUtcToDeviceTime(notificationListItem.createdAt), outputFormat: dateFormat)
        {
            dateFormat = "hh:mm a"
        }
        
        cell.notificationDate.text = TimeUtils.convertDateFormat(TimeUtils.convertUtcToDeviceTime(notificationListItem.createdAt), outputFormat: dateFormat)
        
        // Image
        
        cell.ownerImage.layer.cornerRadius =
        cell.ownerImage.frame.width / 2

        cell.ownerImage.clipsToBounds = true
        cell.ownerImage.contentMode = .scaleAspectFill
        
        let imageUrl = notificationListItem.sender_pic ?? ""

        cell.ownerImage.sd_setImage(
            with: URL(string: imageUrl),
            placeholderImage: UIImage(named: "defaultProfileIcon")
        )

        // Preview button click
        cell.previewAction = { [weak self] in

            guard let self = self else { return }

            self.previewNotification(notificationListItem)
        }
        
        cell.seenUnseenDot.isHidden = notificationListItem.seen_status ?? true

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
        
        
        var sharedData: [String: Any] = [
            "notificationListItem": notificationListItem
        ]
        
        var viewControllerID = "ViewNotificationVC"
        
        if notificationListItem.notification_type == "doc_access" {
            sharedData = [
                "userId": PreferenceManager.shared.getUserId(),
                "vehicleId": notificationListItem.vehicle_id ?? "",
                "taskType": "check"
            ]
            
            viewControllerID = "AccessDocVC"
        }

        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: viewControllerID,
            data: sharedData
        )

    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] (_, _, completion) in

            guard let self = self else {
                completion(false)
                return
            }

            print("🗑 Delete button tapped")
            print("Row:", indexPath.row)
            print("Notification ID:", self.notificationList[indexPath.row]._id ?? "nil")

            let notification = self.notificationList[indexPath.row]

            self.deleteNotification(notification, indexPath: indexPath)

            completion(true)
        }

        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }

    func deleteNotification(
        _ notification: NotificationItemModel,
        indexPath: IndexPath
    ) {

        print("🚀 deleteNotification() called")

        let params: [String: Any] = [
            "user_id": PreferenceManager.shared.getUserId(),
            "notification_id": notificationList[indexPath.row]._id ?? "",
            "chat_room_id": notificationList[indexPath.row].chat_room_id ?? ""
        ]

        print("Request Parameters:")
        print(params)

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.DELETE_NOTIFICATION,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            print("Status:", status)
            print("Message:", message)
            print("Response:", response ?? [:])

            if status {
            
                self.notificationList.remove(at: indexPath.row)

                self.tableView.deleteRows(
                    at: [indexPath],
                    with: .automatic
                )
                
                if totalPage > 1 {
                    let totalNotificationsLeft = totalNotifications - (pageSize - self.notificationList.count)
                    
                    if totalNotificationsLeft <= 20 || self.notificationList.count <= 2{
                        getNotificationList()
                    }
                }

                self.updateGarageUI()

            } else {

                print("❌ Failed to delete notification")

                self.showToast(message: message)
            }
        }
    }
}
