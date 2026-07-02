//
//  VehicleInfoVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 19/06/26.
//

import UIKit

class VehicleInfoVC: BaseViewController {
    
    private var garageModel: GarageItemModel?
    
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

    
    
    private var vehicleDataType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = receivedData as? [String: Any] {

            self.garageModel = data["vehicleData"] as? GarageItemModel ?? nil
            self.vehicleDataType = data["vehicleDataType"] as? String ?? ""
            
            setData()
        }
        
//         set garageBtn
        addVehicleBtn.isUserInteractionEnabled = true

            let addVehicleBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAddVehicleBtnClick)
            )

        addVehicleBtn.addGestureRecognizer(addVehicleBtnTap)
        
        ownerShipDetailsBtn.isUserInteractionEnabled = true

            let ownerShipDetailsBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onOwnerShipDetailsBtnClick)
            )

        ownerShipDetailsBtn.addGestureRecognizer(ownerShipDetailsBtnTap)
        
        
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
                description: "Please verify vehicle owner \(garageModel?.owner_name ?? "") to add vehicle.",
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

