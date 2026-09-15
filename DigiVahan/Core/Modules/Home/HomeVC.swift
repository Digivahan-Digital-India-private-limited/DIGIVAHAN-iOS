//
//  ProfileVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework

class HomeVC: UIView, UITextFieldDelegate {
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var navigationProfileBtn: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var scanBtn: UIView!
    @IBOutlet weak var nearBySerCollectionView: UICollectionView!
    @IBOutlet weak var nearByServiceLayout: UIView!
    
    @IBOutlet weak var scanQRIconLayout: UIView!
    @IBOutlet weak var checkVehicleLayout: UIView!
    @IBOutlet weak var checkChallanLayout: UIView!
    @IBOutlet weak var challanPayLayout: UIView!
    @IBOutlet weak var activateQRLayout: UIView!
    @IBOutlet weak var myGarageLayout: UIView!
    @IBOutlet weak var downQRLayout: UIView!
    @IBOutlet weak var orderQRLayout: UIView!
    @IBOutlet weak var scanQR: UIView!
    @IBOutlet weak var myGarageBtn: UIView!
    @IBOutlet weak var myVirtualQRBtn: UIView!
    @IBOutlet weak var checkChallanBtn: UIView!
    @IBOutlet weak var challanPayBtn: UIView!
    @IBOutlet weak var orderQRBtn: UIView!
    @IBOutlet weak var activateQRBtn: UIView!
    @IBOutlet weak var checkVehicleBtn: UIView!
    
    
    
    var nearByServiceList: [NearByServiceItem] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Common Init
    private func commonInit() {

        Bundle.main.loadNibNamed(
            "Home",
            owner: self,
            options: nil
        )
        
        guard let contentView = mainContentView else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)

        NSLayoutConstraint.activate([

            contentView.topAnchor.constraint(equalTo: topAnchor),

            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),

            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)

        ])
        
        nearBySerCollectionView.register( UINib( nibName: "NearByServiceCell", bundle: nil ), forCellWithReuseIdentifier: "NearByServiceCell" )
        
        setUI()

    }
    
    func setUI() {
        
        loadUserProfile()
        
        CommonFunctions.setViewBg(myView: scanQRIconLayout)
        CommonFunctions.setViewBg(myView: checkVehicleLayout)
        CommonFunctions.setViewBg(myView: checkChallanLayout)
        CommonFunctions.setViewBg(myView: challanPayLayout)
        CommonFunctions.setViewBg(myView: activateQRLayout)
        CommonFunctions.setViewBg(myView: myGarageLayout)
        CommonFunctions.setViewBg(myView: downQRLayout)
        CommonFunctions.setViewBg(myView: orderQRLayout)
        
//        nearBySerCollectionView.delegate = self
//        nearBySerCollectionView.dataSource = self
        
        nearBySerCollectionView.delegate = self
        nearBySerCollectionView.dataSource = self
        nearBySerCollectionView.reloadData()
        
        if let layout = nearBySerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            
            layout.sectionInset = UIEdgeInsets( top: 10, left: 10, bottom: 10, right: 10 )
        }
        
        // set navigationProfileBtn
        navigationProfileBtn.isUserInteractionEnabled = true

            let navigationProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showNavigation)
            )

        navigationProfileBtn.addGestureRecognizer(navigationProfileBtnTap)
        
        // set scanBtn
        scanQR.isUserInteractionEnabled = true

            let scanQRTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onScanBtnClick)
            )

        scanQR.addGestureRecognizer(scanQRTap)
        
        scanBtn.isUserInteractionEnabled = true

            let scanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onScanBtnClick)
            )

        scanBtn.addGestureRecognizer(scanBtnTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(testTap))
        nearBySerCollectionView.addGestureRecognizer(tap)
        
        // set garageBtn
        myGarageBtn.isUserInteractionEnabled = true

            let myGarageBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onMyGarageBtnClick)
            )

        myGarageBtn.addGestureRecognizer(myGarageBtnTap)
        
        // set myVirtualQRBtn
        myVirtualQRBtn.isUserInteractionEnabled = true

            let myVirtualQRBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onMyVirtualQRBtnClick)
            )

        myVirtualQRBtn.addGestureRecognizer(myVirtualQRBtnTap)
        
        
        // set checkChallanBtn
        checkChallanBtn.isUserInteractionEnabled = true

            let checkChallanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onCheckVehicleChallanBtnClick)
            )

        checkChallanBtn.addGestureRecognizer(checkChallanBtnTap)
        
        
        // set challanPayBtn
        challanPayBtn.isUserInteractionEnabled = true

            let challanPayBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onPayVehicleChallanBtnClick)
            )

        challanPayBtn.addGestureRecognizer(challanPayBtnTap)
        
        
        // set orderQRBtn
        orderQRBtn.isUserInteractionEnabled = true

            let orderQRBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(commingSoonDialog)
            )

        orderQRBtn.addGestureRecognizer(orderQRBtnTap)
        
        
        // set activateQRBtn
        activateQRBtn.isUserInteractionEnabled = true

            let activateQRBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onActivateQRBtnClick)
            )

        activateQRBtn.addGestureRecognizer(activateQRBtnTap)
        
        
        // set activateQRBtn
        checkVehicleBtn.isUserInteractionEnabled = true

            let checkVehicleBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onCheckVehicleBtnClick)
            )

        checkVehicleBtn.addGestureRecognizer(checkVehicleBtnTap)
        
        getNearByServiceList()
    }
    

    
    private func loadUserProfile() {
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill

        let user = PreferenceManager.shared.getUser()

        guard let user = user else {
            userProfileImage.image =
            UIImage(named: "defaultProfileIcon")
            return
        }

        let imageURL = user.profilePic
                
        if imageURL.isEmpty {
            userProfileImage.image =
            UIImage(named: "defaultProfileIcon")
            return
        }

        userProfileImage.sd_setImage(
            with: URL(string: imageURL),
            placeholderImage: UIImage(
                named: "defaultProfileIcon"
            )
        )
        
    }
    
    @objc private func commingSoonDialog() {
        if let vc = parentViewController {
            CommonFunctions.showUnderDevelopmentDialog(from: vc)
        }
    }
    
    @objc private func onCheckVehicleBtnClick() {
        checkVehicle()
    }
    
    @objc private func onCheckVehicleChallanBtnClick() {
        checkVehicleChallan()
    }
    
    @objc private func onPayVehicleChallanBtnClick() {
        payVehicleChallan()
    }
    
    @objc private func onMyVirtualQRBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "VirtualQRListVC"
            )
        }
    }
    
    @objc private func onMyGarageBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "GarageListVC"
            )
        }
    }
    
    @objc func testTap() {
        print("🔥 CollectionView Tapped")
    }
    
    
    @objc private func onScanBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                        from: vc,
                        storyboardName: "Main",
                        viewControllerID: "ScanVC",
                        data: [
                            "scanType": "connect"
                        ]
                    )
        }
        
    }
    
    @objc private func onActivateQRBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                        from: vc,
                        storyboardName: "Main",
                        viewControllerID: "ScanVC",
                        data: [
                            "scanType": "activate"
                        ]
                    )
        }
        
    }
    
    
    @objc private func showNavigation() {

        let dialog = NavigationView(
            frame: UIScreen.main.bounds
        )

        dialog.configure()

        dialog.onProceed = { value in
            print(value)
        }

        if let vc = parentViewController {
            vc.view.addSubview(dialog)
            dialog.showAnimated()
        }
    }
    
    @objc func nearByItemClicked(_ sender: UITapGestureRecognizer) {

        guard let card = sender.view else { return }

        let index = card.tag
        
        let notificationListItem = self.nearByServiceList[index]
        
        if (notificationListItem.service_type != nil){
//            showToast(message: "Unable to find service")
            CommonFunctions.openNearbyService(serviceType: notificationListItem.service_type ?? "")
        } else {
//            showToast(message: "Unable to find location")
        }
        
    }
    
    
    func getNearByServiceList() {

        print("========================================")
        print("🚀 Fetching Near By Services...")

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_NEAR_BY_SERVICES,
            method: "GET"
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            DispatchQueue.main.async {

                print("========================================")
                print("📥 API Response Received")
                print("✅ Status:", status)
                print("💬 Message:", message)

                if let response = response {
                    print("📦 Raw Response:")
                    print(response)
                }

                if status {

                    guard let dataArray = response?["data"] as? [[String: Any]] else {

                        print("❌ 'data' array not found")
                        self.nearByServiceLayout.isHidden = true
                        return
                    }

                    print("📊 Total Items Received: \(dataArray.count)")

                    self.nearByServiceList.removeAll()

                    for (index, item) in dataArray.enumerated() {

                        print("----------------------------------------")
                        print("📌 Item \(index + 1)")
                        print(item)

                        var model = NearByServiceItem()

                        model._id = item["_id"] as? String ?? ""
                        model.title = item["title"] as? String ?? ""
                        model.icon = item["icon"] as? String ?? ""
                        model.icon_public_id = item["icon_public_id"] as? String ?? ""
                        model.service_type = item["service_type"] as? String ?? ""
                        model.status = item["status"] as? String ?? ""
                        model.createdAt = item["createdAt"] as? String ?? ""
                        model.updatedAt = item["updatedAt"] as? String ?? ""
                        model.__v = item["__v"] as? Int ?? 0

                        if model.status == "true" {
                            self.nearByServiceList.append(model)

                        } else {

                            print("⏭ Skipped (Status = \(model.status))")
                        }
                    }

                    print("========================================")

                    self.nearBySerCollectionView.reloadData()
                    self.nearByServiceLayout.isHidden =
                        self.nearByServiceList.isEmpty


                } else {

                    print("❌ API Failed")
                    print("💬 Error:", message)

                    self.nearByServiceLayout.isHidden = true
                }

                print("========================================")
            }
        }
    }
    
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {

        guard let card = sender.view else { return }

        let index = card.tag
        
        if let vc = parentViewController {
            if let url = URL(string: "comgooglemaps://") {
                print("Can Open Google Maps:", UIApplication.shared.canOpenURL(url))
            }
            print("service_type:", nearByServiceList[index].service_type ?? "")
            CommonFunctions.openNearbyService(serviceType: nearByServiceList[index].service_type ?? "")
        }
    }
    
    private func checkVehicle() {
        
        let vc = parentViewController
        
        let dialog = AddVehicleCustomDialog(
            frame: UIScreen.main.bounds
        )
        
        dialog.configure(
            title: "Check Vehicle",
            description: "Please enter vehicle number to check details.",
            hint: "Vehicle Number",
            buttonTitle: "Check"
        )
        
        dialog.onProceed = { vehicleNumber in
            
            var vehicleExist = false
            
            if vehicleNumber.isEmpty {
                vc?.showToast(message: "Please enter vehicle Number")
                return
            }
            
            if let vc = self.parentViewController {
                LoadingManager.shared.show(on: vc.view)
            }
            
            let params: [String: Any] = [
                "vehicle_number": vehicleNumber
            ]
            
            NetworkManager.shared.callAPI(
                url: APIEndpoints.CHECK_VEHICLE,
                method: "POST",
                parameters: params
            ) { [weak self] response, status, message in

                guard let self = self else { return }

                LoadingManager.shared.hide()

                if status {

                    do {

                        if let vc = parentViewController {
                            vc.showToast(message: message)
                            
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
                            
                            NavigationManager.pushScreen(
                                from: vc,
                                viewControllerID: "VehicleInfoVC",
                                data: [
                                    "vehicleData": model,
                                    "vehicleDataType": "check"
                                ]
                            )
                            

                        }

                    } catch {

                        if let vc = self.parentViewController {
                            NavigationManager.moveToScreen(
                                from: vc,
                                viewControllerID: "EmptyLayoutVC"
                            )
                        }
                    }

                } else {

                    if message.lowercased() == "no internet connection" {

    //                    self.showNoInternetDialog()

                    } else {

                        vc?.showToast(message: "Vehicle not found")
                        if let vc = self.parentViewController {
                            NavigationManager.moveToScreen(
                                from: vc,
                                viewControllerID: "EmptyLayoutVC"
                            )
                        }
                    }
                }
            }
            
        }
        
        
        
        vc?.view.addSubview(dialog)
        
    }

    
    private func checkVehicleChallan() {
        
        let vc = parentViewController
        
        let dialog = AddVehicleCustomDialog(
            frame: UIScreen.main.bounds
        )
        
        dialog.configure(
            title: "Check Challan",
            description: "Please enter vehicle number to check Challan details.",
            hint: "Vehicle Number",
            buttonTitle: "Check"
        )
        
        dialog.onProceed = { vehicleNumber in
                        
            if vehicleNumber.isEmpty {
                vc?.showToast(message: "Please enter vehicle Number")
                return
            }
            
            if let vc = self.parentViewController {
                
                NavigationManager.pushScreen(
                    from: vc,
                    viewControllerID: "ChallanListVC",
                    data: [
                        "vehicleId": vehicleNumber,
                        "garage": "true"
                    ]
                )
                   
            }
            
            
        }
        
        vc?.view.addSubview(dialog)
        
    }
    
    
    private func payVehicleChallan() {
        
        let vc = parentViewController
        
        let dialog = payVehicleChallanCustomDialog(
            frame: UIScreen.main.bounds
        )
        
        dialog.configure(
            title: "Pay Challan",
            description: "Please enter your vehicle & challan number to Pay the challan.\nNote: Please make sure that your challan is unpaid.",
            hint: "Vehicle Number",
            buttonTitle: "Pay"
        )
                
        
        dialog.onProceed = { vehicleNumber, challanNumber in
                        
            if vehicleNumber.isEmpty {
                vc?.showToast(message: "Please enter vehicle Number")
                return
            } else if challanNumber.isEmpty {
                vc?.showToast(message: "Please enter challan Number")
                return
            }
            
            self.payChallan(vehicleNumber: vehicleNumber, challanNumbers: challanNumber)
            
            
        }
        
        vc?.view.addSubview(dialog)
        
    }
    
    func payChallan(vehicleNumber : String, challanNumbers : String) {
        
        let vc = parentViewController
        
        let params: [String: Any] = [
            "vehicleNumber": vehicleNumber,
            "challanNumbers": [
                challanNumbers
            ]
        ]

        if let vc = self.parentViewController {
            LoadingManager.shared.show(on: vc.view)
        }

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
                        
                        if let vc = self.parentViewController {
                            
                            NavigationManager.pushScreen(
                                from: vc,
                                storyboardName: "Main",
                                viewControllerID: "WebViewVC",
                                data: [
                                    "policyType": "challanPay",
                                    "paymentUrl": paymentUrl
                                ]
                            )
                               
                        }

                    } else {

                        vc?.showToast(message: "Unable to make a payment")
                        if let vc = self.parentViewController {
                            NavigationManager.moveToScreen(
                                from: vc,
                                viewControllerID: "EmptyLayoutVC"
                            )
                        }
                    }

                    

                } catch {
                    vc?.showToast(message: "Unable to make a payment")
                    if let vc = self.parentViewController {
                        NavigationManager.moveToScreen(
                            from: vc,
                            viewControllerID: "EmptyLayoutVC"
                        )
                    }
                }

            } else {

                if message.lowercased() == "no internet connection" {

//                    self.showNoInternetDialog()

                } else {

                    vc?.showToast(message: "No Challan found")
                    if let vc = self.parentViewController {
                        NavigationManager.moveToScreen(
                            from: vc,
                            viewControllerID: "EmptyLayoutVC"
                        )
                    }
                   
                }
            }
        }

    }

   
}

extension HomeVC:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {

            return nearByServiceList.count
        }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NearByServiceCell",
            for: indexPath
        ) as! NearByServiceCell
        
        print(collectionView.visibleCells)
        print(collectionView.numberOfSections)
        
        print("Creating cell \(indexPath.row)")

        cell.serviceBtn.tag = indexPath.row
        cell.serviceBtn.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(cardViewClicked(_:))
        )

        cell.serviceBtn.gestureRecognizers?.removeAll()
        cell.serviceBtn.addGestureRecognizer(tap)
        
        cell.serviceTitle.text = nearByServiceList[indexPath.row].title


        if let imageUrl = nearByServiceList[indexPath.row].icon {

            cell.serviceImage.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: UIImage(named: "emptyImage")
            )

        } else {

            cell.serviceImage.image = UIImage(named: "emptyImage")
        }
        
        DispatchQueue.main.async {

            print("Collection Frame:", self.nearBySerCollectionView.frame)
            print("Collection Bounds:", self.nearBySerCollectionView.bounds)
        }

        return cell
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {
        
        let itemsPerRow: CGFloat = 4
        let padding: CGFloat = 10
        
        let totalPadding = padding * (itemsPerRow + 1)
        let width = (collectionView.bounds.width - totalPadding) / itemsPerRow
        
        return CGSize(width: width, height: 90)
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int ) -> CGFloat {
        return 10
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int ) -> CGFloat
    {
        return 10
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int ) -> UIEdgeInsets {
        return UIEdgeInsets( top: 10, left: 10, bottom: 10, right: 10 )
    }
    
}

