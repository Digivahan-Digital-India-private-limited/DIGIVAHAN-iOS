//
//  VehicleInfoVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 19/06/26.
//

import UIKit
import SDWebImage

class VehicleInfoVC: BaseViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    private var garageModel: GarageItemModel?
    var vehicleDocumentsArrayList: [VehicleDocuments] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewImageLayout: UIView!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewImageCloseIcon: UIImageView!
    
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var addVehicleBtn: UIView!
    @IBOutlet weak var addVehicleBtnText: UILabel!
    
    @IBOutlet weak var ownerShipDetailsBtn: UIView!
    @IBOutlet weak var ownerShipDetailsArrow: UIImageView!
    @IBOutlet weak var ownerShipDetailsLayout: UIView!
    @IBOutlet weak var ownerShipName: UILabel!
    @IBOutlet weak var ownerShipCount: UILabel!
    @IBOutlet weak var registrationDate: UILabel!
    @IBOutlet weak var registeredRTO: UILabel!
    
    @IBOutlet weak var vehicleDetailsBtn: UIView!
    @IBOutlet weak var vehicleDetailsArrow: UIImageView!
    @IBOutlet weak var vehicleDetailsLayout: UIView!
    @IBOutlet weak var makerModel: UILabel!
    @IBOutlet weak var vehicleClass: UILabel!
    @IBOutlet weak var fuelType: UILabel!
    @IBOutlet weak var fuelNorms: UILabel!
    @IBOutlet weak var engineNo: UILabel!
    @IBOutlet weak var chassisNo: UILabel!
    
    
    @IBOutlet weak var importantDatesBtn: UIView!
    @IBOutlet weak var importantDatesArrow: UIImageView!
    @IBOutlet weak var importantDatesLayout: UIView!
    @IBOutlet weak var insuranceExpiry: UILabel!
    @IBOutlet weak var insuranceExpiringIn : UILabel!
    @IBOutlet weak var vehicleAge : UILabel!
    @IBOutlet weak var fitnessUpto : UILabel!
    @IBOutlet weak var pollutionUpto : UILabel!
    @IBOutlet weak var PUCExpiring : UILabel!
    
    
    @IBOutlet weak var otherInfoBtn: UIView!
    @IBOutlet weak var otherInfoArrow: UIImageView!
    @IBOutlet weak var otherInfoLayout: UIView!
    @IBOutlet weak var vehicleColor : UILabel!
    @IBOutlet weak var unloadedWeight : UILabel!
    @IBOutlet weak var RCStatus : UILabel!
    
    @IBOutlet weak var vehicleInfoLayoutBtn: UIView!
    @IBOutlet weak var vehicleInfoLayout: UIView!
    @IBOutlet weak var vehicleInfoDevider: UIView!
    @IBOutlet weak var vehicleInfoBtnText: UILabel!
    
    @IBOutlet weak var documentInfoLayoutBtn: UIView!
    @IBOutlet weak var documentInfoLayout: UIView!
    @IBOutlet weak var documentInfoDevider: UIView!
    @IBOutlet weak var documentInfoBtnText: UILabel!
        

    
    
    private var vehicleDataType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backPressed)
            )
        
        if let data = receivedData as? [String: Any] {

            self.garageModel = data["vehicleData"] as? GarageItemModel ?? nil
            self.vehicleDataType = data["vehicleDataType"] as? String ?? ""
            
            vehicleDocumentsArrayList = garageModel?.vehicleDocumentsArrayList ?? []
            
            print("vehicleDocumentsArrayList count:- \(vehicleDocumentsArrayList.count)")
            
            setData()
        }
        
//         set garageBtn
        addVehicleBtn.isUserInteractionEnabled = true

            let addVehicleBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAddVehicleBtnClick)
            )

        addVehicleBtn.addGestureRecognizer(addVehicleBtnTap)
        
//        ownerShipDetailsBtn.isUserInteractionEnabled = true
//
//            let ownerShipDetailsBtnTap = UITapGestureRecognizer(
//                target: self,
//                action: #selector(onOwnerShipDetailsBtnClick)
//            )
//
//        ownerShipDetailsBtn.addGestureRecognizer(ownerShipDetailsBtnTap)
        
        
        vehicleDetailsBtn.isUserInteractionEnabled = true

            let vehicleDetailsBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onVehicleDetailsBtnClick)
            )

        vehicleDetailsBtn.addGestureRecognizer(vehicleDetailsBtnTap)
        
        
        importantDatesBtn.isUserInteractionEnabled = true

            let ImportantDatesBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onImportantDatesBtnClick)
            )

        importantDatesBtn.addGestureRecognizer(ImportantDatesBtnTap)
        
        
        otherInfoBtn.isUserInteractionEnabled = true

            let otherInfoBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onOtherInfoBtnClick)
            )

        otherInfoBtn.addGestureRecognizer(otherInfoBtnTap)
        
        vehicleInfoLayoutBtn.isUserInteractionEnabled = true

            let vehicleInfoLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onVehicleInfoLayoutBtnnClick)
            )

        vehicleInfoLayoutBtn.addGestureRecognizer(vehicleInfoLayoutBtnTap)
        
        documentInfoLayoutBtn.isUserInteractionEnabled = true

            let documentInfoLayoutBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onDocumentInfoLayoutBtnnClick)
            )

        documentInfoLayoutBtn.addGestureRecognizer(documentInfoLayoutBtnTap)
        
        viewImageCloseIcon.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(closeViewImageBtnClicked(_:))
        )
        viewImageCloseIcon.addGestureRecognizer(tap)
        
    }
    
    func checkDoc() {
        
        vehicleDocumentsArrayList.removeAll()

        LoadingManager.shared.show(on: view)
      
        // Params
        var params: [String: Any] = [
            "user_id": PreferenceManager.shared.getUserId(),
            "vehicle_id": garageModel?.vehicle_id ?? ""
        ]
        

        NetworkManager.shared.callAPI(
            url: APIEndpoints.DOC_CHECK,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                guard let response = response else {
                    self.showToast(message: "Invalid Response")
                    return
                }

                var documentList: [VehicleDocuments] = []

                if let documents = response["vehicle_doc_data"] as? [[String: Any]] {

                    for document in documents {

                        var model = VehicleDocuments()

                        model.doc_name = document["doc_name"] as? String ?? ""
                        model.doc_type = document["doc_type"] as? String ?? ""
                        model.doc_number = document["doc_number"] as? String ?? ""
                        model.doc_url = document["doc_url"] as? String ?? ""
                        model.public_id = document["public_id"] as? String ?? ""
                        model.uploaded_at = document["uploaded_at"] as? String ?? ""

                        documentList.append(model)
                    }
                }
                
                self.vehicleDocumentsArrayList = documentList
                print("Total Documents:", self.vehicleDocumentsArrayList.count)

                self.tableView.reloadData()

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkDoc()
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
    
    
    @IBAction func addDocumentBtnClicked(_ sender: Any) {
        NavigationManager.pushScreen(
            from: self,
            viewControllerID: "AddDocumentVC",
            data: [
                "vehicleData": garageModel
            ]
        )
    }
    @objc private func onVehicleInfoLayoutBtnnClick() {
        vehicleInfoLayout.isHidden = false
        documentInfoLayout.isHidden = true
        
        vehicleInfoDevider.backgroundColor = UIColor(named: "colorPrimary")
        vehicleInfoBtnText.textColor = UIColor(named: "colorPrimary")
        
        documentInfoDevider.backgroundColor = UIColor(named: "textDescription")
        documentInfoBtnText.textColor = UIColor(named: "textDescription")
    }
    
    @objc private func onDocumentInfoLayoutBtnnClick() {
        vehicleInfoLayout.isHidden = true
        documentInfoLayout.isHidden = false
        
        vehicleInfoDevider.backgroundColor = UIColor(named: "textDescription")
        vehicleInfoBtnText.textColor = UIColor(named: "textDescription")
        
        documentInfoDevider.backgroundColor = UIColor(named: "colorPrimary")
        documentInfoBtnText.textColor = UIColor(named: "colorPrimary")
    }
    
    @objc private func onOwnerShipDetailsBtnClick() {
        ownerShipDetailsLayout.isHidden.toggle()

        ownerShipDetailsArrow.image = UIImage(
            named: ownerShipDetailsLayout.isHidden ? "arrow2" : "arrow1"
        )
    }
    
    @objc private func onVehicleDetailsBtnClick() {
        vehicleDetailsLayout.isHidden.toggle()

        vehicleDetailsArrow.image = UIImage(
            named: vehicleDetailsLayout.isHidden ? "arrow2" : "arrow1"
        )
    }
    
    @objc private func onImportantDatesBtnClick() {
        importantDatesLayout.isHidden.toggle()

        importantDatesArrow.image = UIImage(
            named: importantDatesLayout.isHidden ? "arrow2" : "arrow1"
        )
    }
    
    @objc private func onOtherInfoBtnClick() {
        otherInfoLayout.isHidden.toggle()

        otherInfoArrow.image = UIImage(
            named: otherInfoLayout.isHidden ? "arrow2" : "arrow1"
        )
    }
        
        
    @objc private func onAddVehicleBtnClick() {
        
        if vehicleDataType == "check"{
            let dialog = AddVehicleCustomDialog(
                frame: UIScreen.main.bounds
            )
            
            dialog.configure(
                title: "Verify Owner",
                description: "Please verify the vehicle owner \(garageModel?.owner_name ?? "") before adding this vehicle.",
                hint: "Enter owner name",
                buttonTitle: "Verify"
            )
            
            dialog.onProceed = { value in
                
                if value.isEmpty {
                    self.showToast(message: "Please enter owner name")
                }
                
                let params: [String: Any] = [
                    "user_id": PreferenceManager.shared.getUserId(),
                    "owner_name": value,
                    "vehicle_number": self.garageModel?.vehicle_number ?? ""
                ]
                
                LoadingManager.shared.show(on: self.view)
                
                NetworkManager.shared.callAPI(
                    url: APIEndpoints.ADD_VEHICLE,
                    method: "POST",
                    parameters: params
                ) { response, status, message in
                    
                    LoadingManager.shared.hide()
                    
                    if status {
                        
                        self.showToast(message: message)
                        
                        guard
                            let data = response?["data"] as? [String: Any],
                            let result = (data["result"] as? [String: Any]) ??
                                (data["vehicle"] as? [String: Any]),
                            let info = result["custom_vehicle_info"] as? [String: Any]
                        else {
                            return
                        }
                        
                        var model = GarageItemModel()
                        
                        // Vehicle ID
                        model.vehicle_id = self.garageModel?.vehicle_id
                        
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
                        
                        self.garageModel = model
                        
                        self.vehicleDataType = "verify"
                        
                        self.setData()
                        
                    } else {
                        self.showToast(message: message)
                        
                    }
                }
                
            }
            
            view.addSubview(dialog)
            
        }
        
        else {
            let params: [String: Any] = [
                "user_id": PreferenceManager.shared.getUserId(),
                "vehicle_id": self.garageModel?.vehicle_number ?? ""
            ]
            
            LoadingManager.shared.show(on: self.view)
            
            NetworkManager.shared.callAPI(
                url: APIEndpoints.REFRESH_VEHICLE,
                method: "POST",
                parameters: params
            ) { response, status, message in
                
                LoadingManager.shared.hide()
                
                self.showToast(message: message)
                
                if status {
                    
                    self.showToast(message: message)
                    
                    guard
                        let data = response?["data"] as? [String: Any],
                        let info = data["custom_vehicle_info"] as? [String: Any]
                    else {
                        return
                    }
                    
                    var model = GarageItemModel()
                    
                    // Vehicle ID
                    model.vehicle_id = self.garageModel?.vehicle_id
                    
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
                    
                    
                    self.garageModel = model
                    
                    self.setData()
                    
                }
            }
        }
        
    }
    
    private func setData(){
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        tableView.separatorStyle = .none
        tableView.reloadData()
        
        
        
        self.ownerName.text = CommonFunctions.safeValue(garageModel?.owner_name)
        self.vehicleNumber.text = "\(garageModel?.vehicle_number ?? "") |  \(garageModel?.ownership_details ?? "")"
        self.companyName.text = garageModel?.vehicle_name
        
        self.addVehicleBtnText.text = vehicleDataType == "check" ? "Add It in My Garage" : "Refresh Data"
        
        self.ownerShipName.text = CommonFunctions.safeValue(garageModel?.owner_name)
        self.ownerShipCount.text = CommonFunctions.getFormattedOwner(CommonFunctions.safeValue(garageModel?.ownership_details))
        
        self.registrationDate.text = TimeUtils.convertDateFormat( CommonFunctions.safeValue(garageModel?.registration_date), outputFormat: "dd MMM yyyy")
        
        self.registeredRTO.text = CommonFunctions.safeValue(garageModel?.registered_rto)
        self.makerModel.text = CommonFunctions.safeValue(garageModel?.makers_model)
        self.vehicleClass.text = CommonFunctions.safeValue(garageModel?.vehicle_class)
        self.fuelType.text = CommonFunctions.safeValue(garageModel?.fuel_type)
        self.fuelNorms.text = CommonFunctions.safeValue(garageModel?.fuel_norms)
        self.engineNo.text = CommonFunctions.safeValue(garageModel?.engine)
        self.chassisNo.text = CommonFunctions.safeValue(garageModel?.chassis_number)
        self.insuranceExpiry.text = TimeUtils.convertDateFormat(CommonFunctions.safeValue(garageModel?.insurance_expiry), outputFormat: "dd MMM yyyy")
        
        let daysLeft = TimeUtils.getDaysDifference(
            garageModel?.insurance_expiry,
            TimeUtils.getCurrentDate("dd MMM yyyy")
        )

        if TimeUtils.isDateExpired(
            currentDateString: TimeUtils.getCurrentDate("dd MMM yyyy"),
            targetDateString: garageModel?.insurance_expiry
        ) {
            self.insuranceExpiringIn.text = "Expired"

        } else {

            self.insuranceExpiringIn.text = "\(daysLeft) Days Left"
        }
        
        
        self.vehicleAge.text = CommonFunctions.getVehicleAge(
            currentDateStr: TimeUtils.getCurrentDate("dd MMM yyyy"),
            registrationDateStr: CommonFunctions.safeValue(garageModel?.vehicle_age))
        
        self.fitnessUpto.text = TimeUtils.convertDateFormat(CommonFunctions.safeValue(garageModel?.fitness_upto), outputFormat: "dd MMM yyyy")
        
        self.pollutionUpto.text = TimeUtils.convertDateFormat(CommonFunctions.safeValue(garageModel?.pollution_expiry), outputFormat: "dd MMM yyyy")
        

        if TimeUtils.isDateExpired(
            currentDateString: TimeUtils.getCurrentDate("dd MMM yyyy"),
            targetDateString: garageModel?.pollution_expiry
        ) {
            self.PUCExpiring.text = "Expired"

        } else {

            self.PUCExpiring.text = "\(daysLeft) Days Left"
        }
        
        
        self.vehicleColor.text = CommonFunctions.safeValue(garageModel?.color)
        self.unloadedWeight.text = CommonFunctions.safeValue(garageModel?.unloaded_weight)
        self.RCStatus.text = CommonFunctions.safeValue(garageModel?.rc_status)
        
    }
    
    
}


extension VehicleInfoVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        print("Rows:", vehicleDocumentsArrayList.count)
        return vehicleDocumentsArrayList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        print("cellForRowAt:", indexPath.row)

        let document = vehicleDocumentsArrayList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DocumentListCell",
            for: indexPath
        ) as! DocumentListCell

        cell.selectionStyle = .none

        // Vehicle details
        cell.documentNumber.text = document.doc_number
        
        if document.doc_type == "aadhar"{
            cell.documentName.text = "Aadhar"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "insurance"{
            cell.documentName.text = "Insurance"
            cell.documentImage.image = UIImage(named: "insuranceDocIcon")
        }
        else if document.doc_type == "pollution"{
            cell.documentName.text = "Pollution"
            cell.documentImage.image = UIImage(named: "pollutionDocIcon")
        }
        else if document.doc_type == "rc"{
            cell.documentName.text = "Registration Certificate"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "pancard"{
            cell.documentName.text = "Pancard"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "driving licence"{
            cell.documentName.text = "Driving Licence"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else {
            cell.documentName.text = document.doc_name
            cell.documentImage.image = UIImage(named: "documentIcon")
        }
        
        cell.deleteAction = { [weak self] in
            
            print("🗑 Delete button tapped")
                print("Row:", indexPath.row)
                print("Document:", document.doc_name ?? "")
            
            self?.deleteDocument(document, at: indexPath.row)
        }
        
        cell.previewAction = { [weak self] in
            self?.viewDocBtnClick(document)
        }

        return cell
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        if let textRange = Range(range, in: currentText) {

            let updatedText = currentText
                .replacingCharacters(in: textRange, with: string)
                .uppercased()

            textField.text = updatedText
        }

        return false
    }
    
    func deleteDocument(_ document: VehicleDocuments, at index: Int) {

        let alert = UIAlertController(
            title: "Remove Document",
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
                "vehicle_id": garageModel?.vehicle_id ?? "",
                "doc_type": document.doc_type ?? ""
            ]

            NetworkManager.shared.callAPI(
                url: APIEndpoints.DELETE_DOCUMENT,
                method: "POST",
                parameters: params
            ) { response, status, message in

                LoadingManager.shared.hide()
                
                self.showToast(message: message)

                if status {

                    self.vehicleDocumentsArrayList.remove(at: index)

                    self.tableView.deleteRows(
                        at: [IndexPath(row: index, section: 0)],
                        with: .automatic
                    )
                    

                } else {

                    self.showToast(message: message)
                }
            }
        })

        present(alert, animated: true)
    }
    
    func viewDocBtnClick(_ document: VehicleDocuments) {
        
        if let imageUrl = document.doc_url, !imageUrl.isEmpty {

            viewImage.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: UIImage(named: "emptyImage")
            )

        } else {

            viewImage.image = UIImage(named: "emptyImage")
        }
        
        viewImageLayout.isHidden = false
    }
}

