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
    var challanFilteredList: [ChallanModel] = []
    
    private var vehicleId: String?
    private var isVehicleFromGarage: String = ""
    
    let REFRESH_INTERVAL: Int64 =
    24 * 60 * 60 * 1000

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        
        if let data = receivedData as? [String: Any] {
            
            self.vehicleId = data["vehicleId"] as? String ?? ""
            self.isVehicleFromGarage = data["garage"] as? String ?? ""
            
        }
        
        setUI()
        
        getChallanList(vehicleNumber: vehicleId ?? "")

    }
    
   /* override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    */

    private func setUI() {

        title = "Challan List"

            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]

        if isVehicleFromGarage != "true" {
            navigationController?.navigationBar.tintColor = .black
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "arrow.clockwise"),
                style: .plain,
                target: self,
                action: #selector(refreshClicked)
            )
        }

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        tableView.separatorStyle = .none


        allChallanBtn.isUserInteractionEnabled = true

            let allChallanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAllChallanBtnClick)
            )

        allChallanBtn.addGestureRecognizer(allChallanBtnTap)
        
        
        pendingChallanBtn.isUserInteractionEnabled = true

            let pendingChallanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPendingChallanBtnClick)
            )

        pendingChallanBtn.addGestureRecognizer(pendingChallanBtnTap)
        
        paidChallanBtn.isUserInteractionEnabled = true

            let paidChallanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPaidChallanBtnClick)
            )

        paidChallanBtn.addGestureRecognizer(paidChallanBtnTap)
        
      
    }
    
    @objc func refreshClicked() {
        ChallanRefreshManager.shared.checkVehicleChallanOncePerDay(
            vehicleNumber: vehicleId ?? "",
            viewController: self
        )
    }
    
    @objc private func onAllChallanBtnClick() {
        
        allChallanDevider.backgroundColor = UIColor(named: "colorPrimary")
        allChallanBtnText.textColor = UIColor(named: "colorPrimary")
        
        pendingChallanDevider.backgroundColor = UIColor(named: "textDescription")
        pendingChallanBtnText.textColor = UIColor(named: "textDescription")
        
        paidChallanDevider.backgroundColor = UIColor(named: "textDescription")
        paidChallanBtnText.textColor = UIColor(named: "textDescription")
        
        challanFilteredList = challanList
        tableView.reloadData()
    }
    
    @objc private func onPendingChallanBtnClick() {
        
        allChallanDevider.backgroundColor = UIColor(named: "textDescription")
        allChallanBtnText.textColor = UIColor(named: "textDescription")
        
        pendingChallanDevider.backgroundColor = UIColor(named: "colorPrimary")
        pendingChallanBtnText.textColor = UIColor(named: "colorPrimary")
        
        paidChallanDevider.backgroundColor = UIColor(named: "textDescription")
        paidChallanBtnText.textColor = UIColor(named: "textDescription")
        
        challanFilteredList = filterChallanList(by: ["Pending", "pending", "unpaid", "partially paid"])
        tableView.reloadData()
    }
    
    @objc private func onPaidChallanBtnClick() {
        
        allChallanDevider.backgroundColor = UIColor(named: "textDescription")
        allChallanBtnText.textColor = UIColor(named: "textDescription")
        
        pendingChallanDevider.backgroundColor = UIColor(named: "textDescription")
        pendingChallanBtnText.textColor = UIColor(named: "textDescription")
        
        paidChallanDevider.backgroundColor = UIColor(named: "colorPrimary")
        paidChallanBtnText.textColor = UIColor(named: "colorPrimary")
        
        challanFilteredList = filterChallanList(by: ["Paid", "paid", "cash", "disposed"])
        tableView.reloadData()
    }
    
    
    func getChallanList(vehicleNumber: String, isRefresh: Bool = false) {

        challanList.removeAll()
        challanFilteredList.removeAll()
        tableView.reloadData()

        var url = APIEndpoints.CHALLAN_LIST
        
        if isRefresh || isVehicleFromGarage == "true"{
            url = APIEndpoints.REFRESH_CHALLAN_LIST
        }
        
        let params: [String: Any] = [
            "rcNumber": vehicleNumber
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
                        model.court_name = data["court_name"] as? String ?? ""
                        

                        self.challanList.append(model)
                    }
                    
                    self.challanFilteredList = self.challanList
                    showToast(message: message)
                    
                    var entity = VehicleChallanEntity()

                        entity.vehicleNumber = vehicleNumber

                        entity.lastHitServerDate = TimeUtils.getCurrentDate("yyyy-MM-dd")
                        entity.lastHitServerTime = TimeUtils.getCurrentDate("HH:mm:ss")
                        entity.lastHitServerMillis = Int64(Date().timeIntervalSince1970 * 1000)

                        VehicleChallanDatabase.shared.save(entity)

                    
                } catch {
                    print("🔥 Decode Error:", error.localizedDescription)
                    self.setEmptyLayout(true)
                    self.showToast(message: "No Challan found")
                    NavigationManager.moveToScreen(
                        from: self,
                        viewControllerID: "EmptyLayoutVC"
                    )
                }
                
                updateGarageUI()

            } else {

                self.setEmptyLayout(true)

                if message.lowercased() == "no internet connection" {

//                    self.showNoInternetDialog()

                } else {

                    self.showToast(message: "No Challan found")
                    NavigationManager.moveToScreen(
                        from: self,
                        viewControllerID: "EmptyLayoutVC"
                    )
                }
                
                do {
                    guard
                        let challan_credits = response?["error_type"] as? String
                    else {return}
                            
                            if challan_credits == "no_credits" {
                                CommonFunctions.showAlertDialog(
                                    on: self,
                                    title: "No credits left",
                                    message: message
                                )
                            } else{
                                NavigationManager.moveToScreen(
                                    from: self,
                                    viewControllerID: "EmptyLayoutVC"
                                )
                            }
                }
            }
        }
    }

    
    
    func filterChallanList(by transactionStatuses: [String]) -> [ChallanModel] {

        return challanList.filter { item in

            guard let status = item.transactionStatus else {
                return false
            }

            return transactionStatuses.contains {
                $0.caseInsensitiveCompare(status) == .orderedSame
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

        return challanFilteredList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let challanListItem = challanFilteredList[indexPath.row]

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
        
        if challanListItem.transactionStatus == "UNPAID" && ((challanListItem.court_name?.isEmpty) != nil){
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

        
        let params: [String: Any] = [
            "vehicleNumber": vehicleId ?? "",
            "challanNumbers": [
                challanListItem.challanNumber ?? ""
            ]
        ]

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.PAY_CHALLAN,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                do {
                    
                    let paymentUrl = response?["paymentUrl"] as? String ?? ""
                    
                    if !paymentUrl.isEmpty {

                        NavigationManager.pushScreen(
                            from: self,
                            storyboardName: "Main",
                            viewControllerID: "WebViewVC",
                            data: [
                                "policyType": "challanPay",
                                "paymentUrl": paymentUrl
                            ]
                        )

                    } else {

                        self.showToast(message: "Unable to make a payment")
                    }

                    

                } catch {
                    showToast(message: "Unable to make a payment")
                    NavigationManager.moveToScreen(
                        from: self,
                        viewControllerID: "EmptyLayoutVC"
                    )
                }
                
                updateGarageUI()

            } else {

                self.setEmptyLayout(true)

                if message.lowercased() == "no internet connection" {

//                    self.showNoInternetDialog()

                } else {
                    self.showToast(message: "No Challan found")
                }
                
                NavigationManager.moveToScreen(
                    from: self,
                    viewControllerID: "EmptyLayoutVC"
                )
            }
        }

    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    

}
