//
//  VirtualQRListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit
import SDWebImage

class ChallanListVC: BaseViewController {

    
    @IBOutlet var minView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var allChallanBtn: UIView!
    @IBOutlet weak var allChallanDevider: UIView!
    @IBOutlet weak var allChallanBtnText: UILabel!
    
    @IBOutlet weak var pendingChallanBtn: UIView!
    @IBOutlet weak var pendingChallanDevider: UIView!
    @IBOutlet weak var pendingChallanBtnText: UILabel!
    
    @IBOutlet weak var paidChallanBtn: UIView!
    @IBOutlet weak var paidChallanDevider: UIView!
    @IBOutlet weak var paidChallanBtnText: UILabel!
    
    var challanList: [ChallanModel] = []
    
    private var garageModel: GarageItemModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        
        if let data = receivedData as? [String: Any] {

            self.garageModel = data["vehicleData"] as? GarageItemModel ?? nil
            
        }
        
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getChallanList()
        
    }

    private func setUI() {

        title = "Challan List"
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


        pendingChallanBtn.isUserInteractionEnabled = true

            let pendingChallanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPendingChallanBtnClick)
            )

        pendingChallanBtn.addGestureRecognizer(pendingChallanBtnTap)
        
      
    }
    
    @objc private func onPendingChallanBtnClick() {
        
        allChallanDevider.backgroundColor = UIColor(named: "textDescription")
        allChallanBtnText.textColor = UIColor(named: "textDescription")
        
        pendingChallanDevider.backgroundColor = UIColor(named: "colorPrimary")
        pendingChallanBtnText.textColor = UIColor(named: "colorPrimary")
        
        paidChallanDevider.backgroundColor = UIColor(named: "textDescription")
        paidChallanBtnText.textColor = UIColor(named: "textDescription")
    }
    
    
    func getChallanList() {

        challanList.removeAll()
        tableView.reloadData()

        let url = APIEndpoints.CHALLAN_LIST
        
        let params: [String: Any] = [
            "rcNumber": garageModel?.vehicle_id ?? ""
        ]

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: url,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                do {
                    guard
                        let dataArray = response?["challans"] as? [[String: Any]]
                    else {
                        return
                    }

                    for data in dataArray {
                        var model = ChallanModel()

                        model.ownerName = data["ownerName"] as? String ?? ""
                        model.ownerFatherName = data["ownerFatherName"] as? String ?? ""
                        model.rcNumber = data["rcNumber"] as? String ?? ""
                        model.challanNumber = data["challanNumber"] as? String ?? ""
                        model.offence = data["offence"] as? String ?? ""
                        
                        model.amountSettledAt = data["amountSettledAt"] as? Int ?? 0
                        model.transactionStatus = data["transactionStatus"] as? String ?? ""
                        model.location = data["location"] as? String ?? ""
                        model.createdAt = data["createdAt"] as? String ?? ""
                        model.receiptLink = data["receiptLink"] as? String ?? ""
                        model.motorVehicleAct = data["motorVehicleAct"] as? String ?? ""
                        

                        self.challanList.append(model)
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

        listView.isHidden = challanList.isEmpty
        emptyView.isHidden = !challanList.isEmpty
    }
    
    func setEmptyLayout(_ isEmpty: Bool) {
        emptyView.isHidden = !isEmpty
        listView.isHidden = isEmpty
    }
    
}

extension ChallanListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return challanList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let challanListItem = challanList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChallanListCell",
            for: indexPath
        ) as! ChallanListCell

        cell.selectionStyle = .none

        cell.vehicleNumber.text = challanListItem.rcNumber
        
        cell.challanDate.text = TimeUtils.convertDateFormat(TimeUtils.convertUtcToDeviceTime(challanListItem.createdAt), outputFormat: "dd MMM yyyy")
        
        cell.accusedText.text = challanListItem.ownerName == "" ? "Not Defined" : challanListItem.ownerName
        cell.fatherName.text = challanListItem.ownerFatherName == "" ? "Not Defined" : challanListItem.ownerFatherName
        cell.challanStatus.text = challanListItem.transactionStatus == "" ? "Not Defined" : challanListItem.transactionStatus
        
        cell.challanAmount.text = challanListItem.amountSettledAt != nil
            ? "₹ \(challanListItem.amountSettledAt!)"
            : "Not Defined"
        
        cell.challanPlace.text = challanListItem.location == "" ? "Not Defined" : challanListItem.location
        cell.challanOffence.text = challanListItem.offence == "" ? "Not Defined" : challanListItem.offence
        
       if challanListItem.transactionStatus == "UNPAID" {
           cell.payBtnLayout.isHidden = false
       } else {cell.payBtnLayout.isHidden = true}

        // Preview button click
        cell.payAction = { [weak self] in

            guard let self = self else { return }

            self.payChallan(challanListItem)
        }
        

        return cell
    }

    
    func payChallan(_ challanListItem: ChallanModel) {
        
        
        var sharedData: [String: Any] = [
            "challanListItem": challanListItem
        ]
        
//        var viewControllerID = "ViewNotificationVC"
//        
//        if notificationListItem.notification_type == "doc_access" {
//            sharedData = [
//                "userId": PreferenceManager.shared.getUserId(),
//                "vehicleId": notificationListItem.vehicle_id ?? "",
//                "taskType": "check"
//            ]
//            
//            viewControllerID = "AccessDocVC"
//        }
//
//        NavigationManager.pushScreen(
//            from: self,
//            storyboardName: "Main",
//            viewControllerID: viewControllerID,
//            data: sharedData
//        )

    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    

}
