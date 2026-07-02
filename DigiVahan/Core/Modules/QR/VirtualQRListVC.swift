//
//  VirtualQRListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit
import SDWebImage

class VirtualQRListVC: BaseViewController {

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var garageItemList: [GarageItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getGarageVehicleList()
    }

    private func setUI() {

        title = "My Virtual QR Code"
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

                        self.garageItemList.append(model)
                    }

                    print("✅ Total Vehicles =", self.garageItemList.count)


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
    
}

extension VirtualQRListVC: UITableViewDelegate, UITableViewDataSource {

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

        let garageListItem = garageItemList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "VirtualQRListCell",
            for: indexPath
        ) as! VirtualQRListCell

        cell.selectionStyle = .none

        // Name
        cell.vehicleName.text = garageListItem.vehicle_name
        cell.ownerName.text = garageListItem.owner_name

        // Number
        cell.vehicleNumber.text = garageListItem.vehicle_number

        // Image
        cell.vehicleImage.image = UIImage(
            named: "ic_vehicle_default"
        )

        // Preview button click
        cell.previewAction = { [weak self] in

            guard let self = self else { return }

            self.previewGarage(garageListItem)
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let garageListItem = garageItemList[indexPath.row]

        previewGarage(garageListItem)
    }
    
    
    func previewGarage(_ garageListItem: GarageItemModel) {
        
        print("Preview action called")
        
        let sharedData: [String: Any] = [
            "garageDetails": garageListItem
        ]

        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "VirtualQRInfoVC",
            data: sharedData
        )
    }
}
