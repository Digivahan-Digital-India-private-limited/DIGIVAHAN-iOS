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
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nearByServiceHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var actionCardsCollectionView: UICollectionView!
    @IBOutlet weak var actionCardsPageControl: UIPageControl!
    @IBOutlet weak var scanBtnWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var scanBtnLabel: UILabel?
    @IBOutlet weak var scanBtnIcon: UIImageView?
    
    struct ActionCardItem {
        let title: String
        let subtitle: String
        let buttonTitle: String
        let imageName: String
        let actionType: ActionCardType
    }

    enum ActionCardType {
        case scanQR
        case addVehicle
        case activateQR
    }

    let actionCardList: [ActionCardItem] = [
        ActionCardItem(
            title: "Scan QR Code",
            subtitle: "Scan Digivahan QR code to contact the vehicle owner.",
            buttonTitle: "Scan Now",
            imageName: "banner_scan_qr",
            actionType: .scanQR
        ),
        ActionCardItem(
            title: "Add Vehicle",
            subtitle: "Add your vehicle to the garage",
            buttonTitle: "Add Vehicle",
            imageName: "banner_add_vehicle",
            actionType: .addVehicle
        ),
        ActionCardItem(
            title: "Activate QR Code",
            subtitle: "Scan Digivahan QR code to activate it.",
            buttonTitle: "Scan Now",
            imageName: "banner_activate_qr",
            actionType: .activateQR
        )
    ]
    
    private var actionCardTimer: Timer?
    private var isScanBtnShrunk: Bool = false
    private var lastScrollOffsetY: CGFloat = 0
    
    var nearByServiceList: [NearByServiceItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        actionCardsCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // Auto scroll timer commented out
        // if newSuperview == nil {
        //     stopActionCardTimer()
        // } else {
        //     startActionCardTimer()
        // }
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
        
        setupBackgroundBalls()
        
        scrollView?.backgroundColor = .clear
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.alwaysBounceVertical = true
        scrollView?.delegate = self
        
        setupScanButton()
        setupActionCards()
        
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
        downQRLayout?.isUserInteractionEnabled = false

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
        orderQRLayout?.isUserInteractionEnabled = false

            let orderQRBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onOrderQRBtnClick)
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
    

    
    // MARK: - Background Design Balls (Constant / Non-Scrolling)
    private func setupBackgroundBalls() {
        guard let container = mainContainerView ?? mainContentView else { return }
        
        container.backgroundColor = UIColor(named: "bgColor") ?? UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        container.clipsToBounds = true
        
        // 1. Top-Right Peach Ball
        let peachBall = UIView()
        peachBall.backgroundColor = UIColor(red: 247/255, green: 228/255, blue: 194/255, alpha: 1.0) // #F7E4C2
        peachBall.layer.cornerRadius = 95
        peachBall.clipsToBounds = true
        peachBall.isUserInteractionEnabled = false
        peachBall.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Middle-Left Pastel Green Ball
        let greenBall = UIView()
        greenBall.backgroundColor = UIColor(red: 188/255, green: 226/255, blue: 185/255, alpha: 1.0) // #BCE2B9
        greenBall.layer.cornerRadius = 95
        greenBall.clipsToBounds = true
        greenBall.isUserInteractionEnabled = false
        greenBall.translatesAutoresizingMaskIntoConstraints = false
        
        // Insert behind all scrollable content so they remain fixed during scrolling
        container.insertSubview(peachBall, at: 0)
        container.insertSubview(greenBall, at: 1)
        
        NSLayoutConstraint.activate([
            // Top-right peach ball: partial circle in top right
            peachBall.topAnchor.constraint(equalTo: container.topAnchor, constant: -20),
            peachBall.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 35),
            peachBall.widthAnchor.constraint(equalToConstant: 190),
            peachBall.heightAnchor.constraint(equalToConstant: 190),
            
            // Middle-left pastel green ball: semicircle protruding from the left edge
            greenBall.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -40),
            greenBall.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -95),
            greenBall.widthAnchor.constraint(equalToConstant: 190),
            greenBall.heightAnchor.constraint(equalToConstant: 190)
        ])
    }
    
    // MARK: - Action Cards Setup & Auto-Scroll
    private func setupActionCards() {
        guard let cv = actionCardsCollectionView else { return }
        
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(ActionCardCell.self, forCellWithReuseIdentifier: ActionCardCell.identifier)
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }
        
        actionCardsPageControl?.numberOfPages = actionCardList.count
        actionCardsPageControl?.currentPage = 0
        actionCardsPageControl?.pageIndicatorTintColor = UIColor(red: 196/255, green: 232/255, blue: 194/255, alpha: 1.0)
        actionCardsPageControl?.currentPageIndicatorTintColor = UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0)
        actionCardsPageControl?.addTarget(self, action: #selector(onPageControlChanged(_:)), for: .valueChanged)
        
        cv.reloadData()
        // startActionCardTimer() // Auto-scroll commented out
    }
    
    @objc private func onPageControlChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        guard page < actionCardList.count else { return }
        let indexPath = IndexPath(item: page, section: 0)
        actionCardsCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    /*
    // MARK: - Auto Scroll Timer (Commented Out)
    private func startActionCardTimer() {
        stopActionCardTimer()
        guard !actionCardList.isEmpty else { return }
        actionCardTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.actionCardList.isEmpty, let cv = self.actionCardsCollectionView else { return }
            let currentPage = self.actionCardsPageControl?.currentPage ?? 0
            let nextPage = (currentPage + 1) % self.actionCardList.count
            let indexPath = IndexPath(item: nextPage, section: 0)
            cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.actionCardsPageControl?.currentPage = nextPage
        }
    }
    
    private func stopActionCardTimer() {
        actionCardTimer?.invalidate()
        actionCardTimer = nil
    }
    */
    
    private func handleActionCardTap(_ type: ActionCardType) {
        switch type {
        case .scanQR:
            onScanBtnClick()
        case .addVehicle:
            onMyGarageBtnClick()
        case .activateQR:
            onActivateQRBtnClick()
        }
    }
    
    // MARK: - Floating Scan Button Setup & Animation
    private func setupScanButton() {
        guard let btn = scanBtn else { return }
        btn.layer.cornerRadius = 25
        btn.clipsToBounds = true
        btn.backgroundColor = UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0)
        
        scanBtnWidthConstraint?.constant = 135
        scanBtnLabel?.isHidden = false
        scanBtnLabel?.alpha = 1.0
        isScanBtnShrunk = false
    }
    
    private func shrinkScanButton() {
        guard !isScanBtnShrunk else { return }
        isScanBtnShrunk = true
        
        scanBtnWidthConstraint?.constant = 50
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.scanBtnLabel?.alpha = 0
            self.scanBtnLabel?.isHidden = true
            self.scanBtn?.layer.cornerRadius = 25
            self.scanBtn?.layoutIfNeeded()
            self.layoutIfNeeded()
        }, completion: nil)
    }

    private func expandScanButton() {
        guard isScanBtnShrunk else { return }
        isScanBtnShrunk = false
        
        scanBtnWidthConstraint?.constant = 135
        self.scanBtnLabel?.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.scanBtnLabel?.alpha = 1.0
            self.scanBtn?.layer.cornerRadius = 25
            self.scanBtn?.layoutIfNeeded()
            self.layoutIfNeeded()
        }, completion: nil)
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
                viewControllerID: "VirtualQRListVC",
                data: [
                    "mode": "virtualQR"
                ]
            )
        }
    }

    @objc private func onOrderQRBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "VirtualQRListVC",
                data: [
                    "mode": "orderQR"
                ]
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
                        self.nearByServiceHeightConstraint?.constant = 0
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
                    let isServicesEmpty = self.nearByServiceList.isEmpty
                    self.nearByServiceLayout.isHidden = isServicesEmpty
                    self.nearByServiceHeightConstraint?.constant = isServicesEmpty ? 0 : 265.67

                } else {

                    print("❌ API Failed")
                    print("💬 Error:", message)

                    self.nearByServiceLayout.isHidden = true
                    self.nearByServiceHeightConstraint?.constant = 0
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
        if collectionView == actionCardsCollectionView {
            return actionCardList.count
        }
        return nearByServiceList.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == actionCardsCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActionCardCell.identifier,
                for: indexPath
            ) as! ActionCardCell
            
            let item = actionCardList[indexPath.item]
            cell.configure(
                title: item.title,
                subtitle: item.subtitle,
                buttonTitle: item.buttonTitle,
                imageName: item.imageName
            ) { [weak self] in
                self?.handleActionCardTap(item.actionType)
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NearByServiceCell",
            for: indexPath
        ) as! NearByServiceCell
        
        print(collectionView.visibleCells)
        print(collectionView.numberOfSections)
        
        print("Creating cell \(indexPath.row)")

        cell.serviceBtn.tag = indexPath.row
        cell.serviceBtn.isUserInteractionEnabled = true
        
        CommonFunctions.setViewBg(myView: cell.serviceImageBg)

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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == actionCardsCollectionView {
            let width = collectionView.bounds.width > 0 ? collectionView.bounds.width : UIScreen.main.bounds.width
            return CGSize(width: width, height: 160)
        }
        
        let itemsPerRow: CGFloat = 4
        let padding: CGFloat = 10
        let totalPadding = padding * (itemsPerRow + 1)
        let width = (collectionView.bounds.width - totalPadding) / itemsPerRow
        return CGSize(width: width, height: 90)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == actionCardsCollectionView {
            return 0
        }
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == actionCardsCollectionView {
            return 0
        }
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if collectionView == actionCardsCollectionView {
            return .zero
        }
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: - UIScrollViewDelegate (Shrink/Expand Scan Button & Carousel Paging)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let currentOffset = scrollView.contentOffset.y
            let delta = currentOffset - lastScrollOffsetY
            
            // If near top, always expand
            if currentOffset <= 20 {
                expandScanButton()
            } else if delta > 6 && currentOffset > 30 {
                // Scrolling down -> shrink to circle
                shrinkScanButton()
            } else if delta < -6 {
                // Scrolling up -> expand to pill
                expandScanButton()
            }
            
            lastScrollOffsetY = currentOffset
        } else if scrollView == actionCardsCollectionView {
            guard scrollView.bounds.width > 0 else { return }
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            if page >= 0 && page < actionCardList.count {
                actionCardsPageControl?.currentPage = page
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // if scrollView == actionCardsCollectionView {
        //     stopActionCardTimer()
        // }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == actionCardsCollectionView {
            guard scrollView.bounds.width > 0 else { return }
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            if page >= 0 && page < actionCardList.count {
                actionCardsPageControl?.currentPage = page
            }
            // startActionCardTimer() // Auto-scroll commented out
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == actionCardsCollectionView {
            guard scrollView.bounds.width > 0 else { return }
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            if page >= 0 && page < actionCardList.count {
                actionCardsPageControl?.currentPage = page
            }
        }
    }
}

