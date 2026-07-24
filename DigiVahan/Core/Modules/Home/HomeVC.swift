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

        print("CollectionView:", nearBySerCollectionView) 
        
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
        
        print("user latitude:- \(LocationManager.shared.latitude)")
        print("user latitude:- \(LocationManager.shared.longitude)")
        
        setViewBg(myView: scanQRIconLayout)
        setViewBg(myView: checkVehicleLayout)
        setViewBg(myView: checkChallanLayout)
        setViewBg(myView: challanPayLayout)
        setViewBg(myView: activateQRLayout)
        setViewBg(myView: myGarageLayout)
        setViewBg(myView: downQRLayout)
        setViewBg(myView: orderQRLayout)
        
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
        
        // set aboutBtn
        navigationProfileBtn.isUserInteractionEnabled = true

            let navigationProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showNavigation)
            )

        navigationProfileBtn.addGestureRecognizer(navigationProfileBtnTap)
        
        // set scanBtn
        scanBtn.isUserInteractionEnabled = true
        scanQR.isUserInteractionEnabled = true

            let scanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onScanBtnClick)
            )

        scanBtn.addGestureRecognizer(scanBtnTap)
        scanQR.addGestureRecognizer(scanBtnTap)
        
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
                action: #selector(commingSoonDialog)
            )

        checkChallanBtn.addGestureRecognizer(checkChallanBtnTap)
        
        
        // set challanPayBtn
        challanPayBtn.isUserInteractionEnabled = true

            let challanPayBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(commingSoonDialog)
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
        
        getNearByServiceList()
    }
    
    @objc private func commingSoonDialog() {
        if let vc = parentViewController {
            CommonFunctions.showUnderDevelopmentDialog(from: vc)
        }
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
    
    func setViewBg(myView : UIView){
        myView.layer.cornerRadius = myView.frame.width / 2

           myView.layer.shadowColor = UIColor.black.cgColor
           myView.layer.shadowOpacity = 0.25
           myView.layer.shadowOffset = CGSize(width: 0, height: 3)
           myView.layer.shadowRadius = 8

           myView.layer.masksToBounds = false
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

        dialog.configure(
            title: "Verify Owner",
            description: "Please verify the vehicle owner before adding this vehicle.",
            hint: "Enter owner name",
            buttonTitle: "Verify"
        )

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

                        print("🆔 ID:", model._id)
                        print("📛 Title:", model.title)
                        print("🖼 Icon:", model.icon)
                        print("🛠 Service Type:", model.service_type)
                        print("📌 Status:", model.status)

                        if model.status == "true" {

                            print("✅ Added to List")

                            self.nearByServiceList.append(model)

                        } else {

                            print("⏭ Skipped (Status = \(model.status))")
                        }
                    }

                    print("========================================")
                    print("📋 Final List Count:", self.nearByServiceList.count)

                    self.nearBySerCollectionView.reloadData()

                    print("🔄 CollectionView Reloaded")

                    self.nearByServiceLayout.isHidden =
                        self.nearByServiceList.isEmpty

                    print("👁 Layout Hidden:", self.nearByServiceLayout.isHidden)

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

//    func collectionView(
//        _ collectionView: UICollectionView,
//        didSelectItemAt indexPath: IndexPath
//    ) {
//        let item = nearByServiceList[indexPath.row]
//        print("service_type:", item.service_type ?? "")
//        CommonFunctions.openNearbyService(serviceType: item.service_type ?? "")
//    }
    
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

