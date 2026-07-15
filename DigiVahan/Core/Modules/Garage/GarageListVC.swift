//
//  EmergencyContactsListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//


import UIKit
import SDWebImage

class GarageListVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var vehicleNumberField: UITextField!

    @IBOutlet weak var addVehicleBtn: UIButton!

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showAddVehicleDialogBtn: UIImageView!
    @IBOutlet weak var addVehicleLayout: UIView!
    @IBOutlet weak var addVehicleLayoutCloseBtn: UIImageView!
        
    var garageItemList: [GarageItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getGarageVehicleList()
        
        enableKeyboardAvoiding(scrollView: mainScrollView)
    }

    private func setUI() {

        title = "My Garage"
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
                
        vehicleNumberField.delegate = self
        vehicleNumberField.autocapitalizationType = .allCharacters
        
        // set emergencyContactLayoutBtn
        showAddVehicleDialogBtn.isUserInteractionEnabled = true

            let showAddVehicleDialogTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showHideAddVehicleLayout)
            )

        showAddVehicleDialogBtn.addGestureRecognizer(showAddVehicleDialogTap)
        
        // set addVehicleLayoutCloseBtn
        addVehicleLayoutCloseBtn.isUserInteractionEnabled = true

            let addVehicleLayoutCloseBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showHideAddVehicleLayout)
            )

        addVehicleLayoutCloseBtn.addGestureRecognizer(addVehicleLayoutCloseBtnTap)
        
    }
    
    @objc private func showHideAddVehicleLayout() {

        addVehicleLayout.isHidden.toggle()

        if addVehicleLayout.isHidden {
            CommonFunctions.closeKeyboard()
        }
    }
    
    
    
    func getGarageVehicleList() {

        print("🚀 User ID =", PreferenceManager.shared.getUserId())

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_VEHICLE_LIST + PreferenceManager.shared.getUserId(),
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                do {

                    guard
                        let response = response,
                        let data = response["data"] as? [String: Any],
                        let vehicles = data["vehicles"] as? [[String: Any]]
                    else {

                        self.setEmptyLayout(true)
                        return
                    }

                    _ = try JSONSerialization.data(
                        withJSONObject: vehicles,
                        options: []
                    )

                    self.garageItemList.removeAll()

                    for vehicle in vehicles {

                        var model = GarageItemModel()

                        model.vehicle_id = vehicle["vehicle_id"] as? String ?? ""

                        if let apiData = vehicle["api_data"] as? [String: Any],
                           let info = apiData["custom_vehicle_info"] as? [String: Any] {

                            model.owner_name = info["owner_name"] as? String ?? ""
                            model.vehicle_number = info["vehicle_number"] as? String ?? ""
                            model.vehicle_name = info["vehicle_name"] as? String ?? ""
                            model.registration_date = info["registration_date"] as? String ?? ""
                            model.ownership_details = info["ownership_details"] as? String ?? ""
                            model.registered_rto = info["registered_rto"] as? String ?? ""
                            model.makers_model = info["makers_model"] as? String ?? ""
                            model.makers_name = info["makers_name"] as? String ?? ""
                            model.vehicle_class = info["vehicle_class"] as? String ?? ""
                            model.fuel_type = info["fuel_type"] as? String ?? ""
                            model.fuel_norms = info["fuel_norms"] as? String ?? ""
                            model.engine = info["engine"] as? String ?? ""
                            model.chassis_number = info["chassis_number"] as? String ?? ""
                            model.insurer_name = info["insurer_name"] as? String ?? ""
                            model.insurance_type = info["insurance_type"] as? String ?? ""
                            model.insurance_expiry = info["insurance_expiry"] as? String ?? ""
                            model.financer_name = info["financer_name"] as? String ?? ""
                            model.insurance_renewed_date = info["insurance_renewed_date"] as? String ?? ""

                            // vehicle_age is Int in response
                            if let age = info["vehicle_age"] {
                                model.vehicle_age = "\(age)"
                            }

                            model.fitness_upto = info["fitness_upto"] as? String ?? ""
                            model.pollution_renew_date = info["pollution_renew_date"] as? String ?? ""
                            model.pollution_expiry = info["pollution_expiry"] as? String ?? ""
                            model.color = info["color"] as? String ?? ""

                            if let weight = info["unloaded_weight"] {
                                model.unloaded_weight = "\(weight)"
                            }

                            model.rc_status = info["rc_status"] as? String ?? ""
                            model.insurance_policy_number = info["insurance_policy_number"] as? String ?? ""
                            model.category = info["category"] as? String ?? ""
                        }
                        
                      
                        if let vehicleDoc = vehicle["vehicle_doc"] as? [String: Any] {
                                if let documents = vehicleDoc["documents"] as? [[String: Any]] {

                                    var documentList: [VehicleDocuments] = []

                                    for document in documents {

                                        var documentModel = VehicleDocuments()

                                        documentModel.doc_name = document["doc_name"] as? String ?? ""
                                        documentModel.doc_type = document["doc_type"] as? String ?? ""
                                        documentModel.doc_number = document["doc_number"] as? String ?? ""
                                        documentModel.doc_url = document["doc_url"] as? String ?? ""
                                        documentModel.public_id = document["public_id"] as? String ?? ""
                                        documentModel.uploaded_at = document["uploaded_at"] as? String ?? ""

                                        documentList.append(documentModel)
                                    }

                                    model.vehicleDocumentsArrayList = documentList
                                }
                            }

                        self.garageItemList.append(model)
                    }

                    self.updateGarageUI()

                } catch {

                    print("🔥 Decode Error:", error.localizedDescription)
                    self.setEmptyLayout(true)
                    self.showToast(message: "Parsing Error")
                }

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

        listView.isHidden = garageItemList.isEmpty
        emptyView.isHidden = !garageItemList.isEmpty
    }
    
    func setEmptyLayout(_ isEmpty: Bool) {

        emptyView.isHidden = !isEmpty
        listView.isHidden = isEmpty
    }
    
    
    func deleteVehicle(_ contact: GarageItemModel, at index: Int) {

        let alert = UIAlertController(
            title: "Remove Vehicle",
            message: "Are you sure you want to remove it?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(
            title: "Yes, Delete",
            style: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }
            
            LoadingManager.shared.show(on: view)

            let params: [String: Any] = [
                "user_id": PreferenceManager.shared.getUserId(),
                "vehicle_number": contact.vehicle_id ?? ""
            ]

            NetworkManager.shared.callAPI(
                url: APIEndpoints.DELETE_VEHICLE,
                method: "POST",
                parameters: params
            ) { response, status, message in

                LoadingManager.shared.hide()
                
                self.showToast(message: message)

                if status {

                    self.garageItemList.remove(at: index)

                    self.tableView.deleteRows(
                        at: [IndexPath(row: index, section: 0)],
                        with: .automatic
                    )
                    
                    if self.garageItemList.isEmpty {
                        self.setEmptyLayout(true)
                    }

                } else {

                    self.showToast(message: message)
                }
            }
        })

        present(alert, animated: true)
    }
    
    
    
    @IBAction func addVehicleBtnClick(_ sender: Any) {
        let vehicleNumber: String = (
            vehicleNumberField.text ?? ""
        ).uppercased()
        
        if vehicleNumber.isEmpty {
            showToast(message: "Please enter vehicle number")
        }
        
        if let model = garageItemList.first(where: {
            ($0.vehicle_number ?? "").uppercased() == vehicleNumber
        }) {

            self.addVehicleLayout.isHidden = true

            NavigationManager.pushScreen(
                from: self,
                viewControllerID: "VehicleInfoVC",
                data: [
                    "vehicleData": model
                ]
            )
            
            return

        }
        
        let params: [String: Any] = [
            "vehicle_number": vehicleNumber
        ]

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.CHECK_VEHICLE,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if let httpCode = response?["http_code"] as? Int,
               httpCode == 503 {

                self.showAlert(
                    title: "Under Maintenance",
                    message: "RTO under maintenance, Vehicle not found in RTO database, please check the vehicle number or try after some time"
                )

                return
            }

            if status {

                self.showToast(message: message)

                guard
                    let data = response?["data"] as? [String: Any],
                    let result = data["result"] as? [String: Any],
                    let info = result["custom_vehicle_info"] as? [String: Any]
                else {
                    return
                }

                var model = GarageItemModel()

                // Vehicle ID
                model.vehicle_id = vehicleNumber

                // Vehicle Info
                model.owner_name = info["owner_name"] as? String ?? ""
                model.vehicle_number = info["vehicle_number"] as? String ?? ""
                model.vehicle_name = info["vehicle_name"] as? String ?? ""
                model.fuel_type = info["fuel_type"] as? String ?? ""
                model.rc_status = info["rc_status"] as? String ?? ""
                model.registration_date = info["registration_date"] as? String ?? ""
                model.ownership_details = info["ownership_details"] as? String ?? ""
                model.financer_name = info["financer_name"] as? String ?? ""
                model.registered_rto = info["registered_rto"] as? String ?? ""
                model.makers_model = info["makers_model"] as? String ?? ""
                model.makers_name = info["makers_name"] as? String ?? ""
                model.vehicle_class = info["vehicle_class"] as? String ?? ""
                model.fuel_norms = info["fuel_norms"] as? String ?? ""
                model.engine = info["engine"] as? String ?? ""
                model.chassis_number = info["chassis_number"] as? String ?? ""
                model.insurer_name = info["insurer_name"] as? String ?? ""
                model.insurance_type = info["insurance_type"] as? String ?? ""
                model.insurance_expiry = info["insurance_expiry"] as? String ?? ""
                model.insurance_renewed_date = info["insurance_renewed_date"] as? String ?? ""

                if let age = info["vehicle_age"] as? Int {
                    model.vehicle_age = String(age)
                } else {
                    model.vehicle_age = ""
                }

                model.fitness_upto = info["fitness_upto"] as? String ?? ""
                model.pollution_renew_date = info["pollution_renew_date"] as? String ?? ""
                model.pollution_expiry = info["pollution_expiry"] as? String ?? ""
                model.color = info["color"] as? String ?? ""
                model.unloaded_weight = info["unloaded_weight"] as? String ?? ""
                model.category = info["category"] as? String ?? ""
                model.insurance_policy_number = info["insurance_policy_number"] as? String ?? ""

                self.addVehicleLayout.isHidden = true
                
                NavigationManager.pushScreen(
                    from: self,
                    viewControllerID: "VehicleInfoVC",
                    data: [
                        "vehicleData": model,
                        "vehicleDataType": "check"
                    ]
                )

            } else {

                self.showAlert(
                    title: "Vehicle Alert",
                    message: message
                )
            }
        }
        
    }
    
    func showAlert(title: String, message: String, onRetry: (() -> Void)? = nil) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let quitAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            self.dismiss(animated: true)
        }

        alert.addAction(quitAction)

        present(alert, animated: true)
    }
    
}

extension GarageListVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return garageItemList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let contact = garageItemList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "GarageListCell",
            for: indexPath
        ) as! GarageListCell

        cell.selectionStyle = .none

        // Vehicle details
        cell.vehicleName.text = contact.makers_model
        cell.vehicleClass.text = "\(contact.makers_name ?? "")\n\(contact.vehicle_id ?? "")"

        // Vehicle image
        cell.vehicleImage.contentMode = .scaleAspectFit
        cell.vehicleImage.image = UIImage(named: "ic_vehicle_default")

        // Item click
        cell.itemClickAction = { [weak self] in

            guard let self = self else { return }

            let sharedData: [String: Any] = [
                "vehicleData": contact
            ]

            NavigationManager.pushScreen(
                from: self,
                viewControllerID: "VehicleInfoVC",
                data: sharedData
            )
        }
        
        cell.deleteAction = { [weak self] in
            self?.deleteVehicle(contact, at: indexPath.row)
        }

        return cell
    }

//    func tableView(
//        _ tableView: UITableView,
//        didSelectRowAt indexPath: IndexPath
//    ) {
//
//        let contact = garageItemList[indexPath.row]
//
//        let sharedData: [String: Any] = [
//            "vehicleData": contact
//        ]
//
//        NavigationManager.pushScreen(
//            from: self,
//            viewControllerID: "VehicleInfoVC",
//            data: sharedData
//        )
//    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return false
        }

        var updatedText = currentText
            .replacingCharacters(in: textRange, with: string)
            .uppercased()

        // Limit vehicle number to 14 characters
        if textField == vehicleNumberField && updatedText.count > 14 {
            updatedText = String(updatedText.prefix(20))
        }

        textField.text = updatedText

        return false
    }
}
