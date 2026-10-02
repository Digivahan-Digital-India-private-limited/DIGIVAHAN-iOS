//
//  DashBoardVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework
import CoreLocation

// MARK: - Fuel Gradient Header View
class FuelGradientHeaderView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
    
    func setupGradient() {
        backgroundColor = .clear
        gradientLayer.colors = [
            UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0).cgColor,
            UIColor(red: 168/255, green: 233/255, blue: 164/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}

class DashBoardVC: UIView, UITextFieldDelegate {
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationProfileBtn: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var greatingText: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    // MARK: - Garage Section Outlets
    @IBOutlet weak var garageSectionView: UIView!
    @IBOutlet weak var garageCollectionView: UICollectionView!
    @IBOutlet weak var garagePageControl: UIPageControl!
    @IBOutlet weak var emptyGarageView: UIView!
    @IBOutlet weak var emptyAddVehicleBtn: UIButton!
    
    // MARK: - Fuel Price Card Outlets
    @IBOutlet weak var fuelCardView: UIView!
    @IBOutlet weak var fuelHeaderView: FuelGradientHeaderView!
    @IBOutlet weak var fuelTitleLabel: UILabel!
    @IBOutlet weak var fuelStateContainer: UIView!
    @IBOutlet weak var fuelStateButton: UIButton!
    @IBOutlet weak var fuelStateLabel: UILabel!
    @IBOutlet weak var fuelDropdownArrow: UIImageView!
    @IBOutlet weak var fuelPricesContainerView: UIView!
    @IBOutlet weak var fuelPricesStackView: UIStackView!
    @IBOutlet weak var petrolPriceLabel: UILabel!
    @IBOutlet weak var dieselPriceLabel: UILabel!
    @IBOutlet weak var cngPriceLabel: UILabel!
    
    // MARK: - Vehicle Info Cards Outlet
    @IBOutlet weak var vehicleDocCardsView: VehicleDocCardsView!
    
    // MARK: - Trending Cars Views (Programmatic)
    var trendingCarsSectionView: UIView?
    var trendingCarsCollectionView: UICollectionView?
    
    // MARK: - Popular Comparison Views (Programmatic)
    var popularComparisonSectionView: UIView?
    var popularComparisonCollectionView: UICollectionView?
    
    // MARK: - Tips Views (Programmatic)
    var tipsSectionView: UIView?
    var tipsCollectionView: UICollectionView?
    private var tipsCollectionViewHeightConstraint: NSLayoutConstraint?
    
    var garageItemList: [GarageItemModel] = []
    var fuelItemDataList: [FuelItemModel] = []
    var trendingCarsList: [TrendingCarsModel] = []
    var popularComparisonList: [TrendingVSCarsModel] = []
    var tipsList: [TipsItemModel] = []
    private var tipsAutoScrollTimer: Timer?
    private var currentTipsIndex: Int = 0
    var selectedStateIndex: Int = 0
    var selectedGarageVehicleIndex: Int = 0
    
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
            "DashBoard",
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
        
        setUI()
    }
    
    func setUI() {
        setupBackgroundBalls()
        
        scrollView?.backgroundColor = .clear
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.alwaysBounceVertical = true
        
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        userProfileImage.clipsToBounds = true
        userProfileImage.contentMode = .scaleAspectFill
        
        loadUserProfile()
    
        // Navigation Profile Button Tap
        navigationProfileBtn.isUserInteractionEnabled = true
        let navigationProfileBtnTap = UITapGestureRecognizer(
            target: self,
            action: #selector(showNavigation)
        )
        navigationProfileBtn.addGestureRecognizer(navigationProfileBtnTap)
        
        // Setup Garage CollectionView
        if let cv = garageCollectionView {
            cv.delegate = self
            cv.dataSource = self
            cv.isPagingEnabled = false
            cv.decelerationRate = .fast
            cv.showsHorizontalScrollIndicator = false
            cv.showsVerticalScrollIndicator = false
            cv.clipsToBounds = false
            cv.register(VehicleCardCell.self, forCellWithReuseIdentifier: VehicleCardCell.identifier)
        }
        
        // Setup Garage PageControl
        if let pc = garagePageControl {
            pc.hidesForSinglePage = true
            pc.pageIndicatorTintColor = UIColor(white: 0.74, alpha: 1.0)
            pc.currentPageIndicatorTintColor = UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0)
        }
        
        // Setup Empty Garage View
        if let emptyView = emptyGarageView {
            emptyView.layer.cornerRadius = 20
            emptyView.clipsToBounds = true
            emptyView.isUserInteractionEnabled = true
            let emptyTap = UITapGestureRecognizer(target: self, action: #selector(onAddVehicleClicked))
            emptyView.addGestureRecognizer(emptyTap)
        }
        
        if let addBtn = emptyAddVehicleBtn {
            addBtn.layer.cornerRadius = 10
            addBtn.clipsToBounds = true
            addBtn.addTarget(self, action: #selector(onAddVehicleClicked), for: .touchUpInside)
        }
        
        vehicleDocCardsView?.isHidden = true
        
        // Fetch Garage vehicles from server
        fetchGarageVehicles()
        
        // Setup Fuel Price Card
        setupFuelCardUI()
        fetchFuelPrices()
        
        // Setup Trending Cars UI & Data
        setupTrendingCarsUI()
        setDefaultTrendingCars()
        fetchTrendingCars()
        
        // Setup Popular Comparison UI & Data
        setupPopularComparisonUI()
        setDefaultPopularComparisons()
        fetchPopularComparisons()
        
        // Setup Tips UI & Data
        setupTipsUI()
        setDefaultTips()
        fetchTips()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if trendingCarsSectionView == nil {
            setupTrendingCarsUI()
            setDefaultTrendingCars()
        }
        if popularComparisonSectionView == nil {
            setupPopularComparisonUI()
            setDefaultPopularComparisons()
        }
        if tipsSectionView == nil {
            setupTipsUI()
            setDefaultTips()
        }
        if let cv = tipsCollectionView {
            let cardSize = getTipsCardSize(for: cv)
            if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout, layout.itemSize != cardSize {
                layout.itemSize = cardSize
                layout.invalidateLayout()
            }
            let neededHeight = cardSize.height + 8
            if tipsCollectionViewHeightConstraint?.constant != neededHeight {
                tipsCollectionViewHeightConstraint?.constant = neededHeight
            }
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
    
    @objc private func onAddVehicleClicked() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "GarageListVC"
            )
        }
    }
    
    private func openVehicleInfo(for model: GarageItemModel) {
        if let vc = parentViewController {
            let sharedData: [String: Any] = [
                "vehicleData": model
            ]
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "VehicleInfoVC",
                data: sharedData
            )
        }
    }
    
    // MARK: - Fetch Garage Vehicles
    func fetchGarageVehicles() {
        let userId = PreferenceManager.shared.getUserId()
        guard !userId.isEmpty else { return }

        let url = APIEndpoints.GET_VEHICLE_LIST + userId

        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in
            guard let self = self else { return }

            if status {
                guard
                    let response = response,
                    let data = response["data"] as? [String: Any],
                    let vehicles = data["vehicles"] as? [[String: Any]]
                else {
                    self.updateGarageUI([])
                    return
                }

                var parsedList: [GarageItemModel] = []

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

                    if let vehicleDoc = vehicle["vehicle_doc"] as? [String: Any],
                       let documents = vehicleDoc["documents"] as? [[String: Any]] {
                        var documentList: [VehicleDocuments] = []
                        for document in documents {
                            var doc = VehicleDocuments()
                            doc.doc_name = document["doc_name"] as? String ?? ""
                            doc.doc_type = document["doc_type"] as? String ?? ""
                            doc.doc_number = document["doc_number"] as? String ?? ""
                            doc.doc_url = document["doc_url"] as? String ?? ""
                            doc.public_id = document["public_id"] as? String ?? ""
                            doc.uploaded_at = document["uploaded_at"] as? String ?? ""
                            documentList.append(doc)
                        }
                        model.vehicleDocumentsArrayList = documentList
                    }

                    parsedList.append(model)
                }

                self.updateGarageUI(parsedList)
            } else {
                self.updateGarageUI([])
            }
        }
    }
    
    private func updateGarageUI(_ list: [GarageItemModel]) {
        self.garageItemList = list

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if list.isEmpty {
                self.garageCollectionView?.isHidden = true
                self.garagePageControl?.isHidden = true
                self.emptyGarageView?.isHidden = false
                self.vehicleDocCardsView?.isHidden = true
            } else {
                self.garageCollectionView?.isHidden = false
                self.garagePageControl?.isHidden = list.count <= 1
                self.emptyGarageView?.isHidden = true
                self.garagePageControl?.numberOfPages = list.count
                self.garagePageControl?.currentPage = 0
                self.garageCollectionView?.reloadData()
                self.vehicleDocCardsView?.isHidden = false
                self.selectedGarageVehicleIndex = 0
                if let first = list.first {
                    self.vehicleDocCardsView?.configure(with: first)
                }
            }
        }
    }
    
    func loadUserProfile() {
        self.greatingText.text = CommonFunctions.getTimeGreeting()
        
        let user = PreferenceManager.shared.getUser()

        guard let user = user else {
            userProfileImage.image = UIImage(named: "defaultProfileIcon")
            return
        }

        let imageURL = user.profilePic
        
        userName.text = user.firstName + " " + user.lastName
        
        if imageURL.isEmpty {
            userProfileImage.image = UIImage(named: "defaultProfileIcon")
            return
        }

        userProfileImage.sd_setImage(
            with: URL(string: imageURL),
            placeholderImage: UIImage(
                named: "defaultProfileIcon"
            )
        )
    }

    // MARK: - Background Design Balls (Constant / Non-Scrolling)
    private func setupBackgroundBalls() {
        guard let container = mainContentView else { return }
        
        // Prevent duplicate balls
        if container.viewWithTag(9901) != nil { return }
        
        container.backgroundColor = UIColor(named: "bgColor") ?? UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        container.clipsToBounds = true
        
        // 1. Top-Right Peach Ball
        let peachBall = UIView()
        peachBall.tag = 9901
        peachBall.backgroundColor = UIColor(red: 247/255, green: 228/255, blue: 194/255, alpha: 1.0) // #F7E4C2
        peachBall.layer.cornerRadius = 95
        peachBall.clipsToBounds = true
        peachBall.isUserInteractionEnabled = false
        peachBall.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Middle-Left Pastel Green Ball
        let greenBall = UIView()
        greenBall.tag = 9902
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

    // MARK: - Fuel Price Card
    func setupFuelCardUI() {
        guard let cardView = fuelCardView else { return }
        
        cardView.backgroundColor = .clear
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = false
        
        // Elevation / Shadow matching Android elevation = 4dp
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        
        // Setup top header gradient if needed
        fuelHeaderView?.setupGradient()
        
        // Bottom white container (radius 8 on bottom corners, 1dp border #dddddd)
        if let inner = fuelPricesContainerView {
            inner.layer.cornerRadius = 8
            inner.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            inner.layer.borderWidth = 1
            inner.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0).cgColor
            inner.clipsToBounds = true
        }
        
        // State dropdown button pill container (radius 10)
        if let container = fuelStateContainer {
            container.layer.cornerRadius = 10
            container.clipsToBounds = true
        }
        
        if let btn = fuelStateButton {
            btn.addTarget(self, action: #selector(onFuelStateButtonTapped), for: .touchUpInside)
        }
        
        if let arrow = fuelDropdownArrow {
            let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
            arrow.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: config) ?? UIImage(named: "arrow1")
            arrow.tintColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
        }
        
        // Default initial preview
        fuelStateLabel?.text = "Assam"
        let defaultAssam = FuelItemModel(state: "Assam", petrol: "102.13", diesel: "93.44", cng: "87")
        updateFuelPriceLabels(with: defaultAssam)
    }
    
    // MARK: - Fetch Fuel Prices
    func fetchFuelPrices() {
        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_FUEL_PRICE,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in
            guard let self = self else { return }
            
            guard status, let response = response,
                  let data = response["data"] as? [String: Any],
                  let statesArray = data["states"] as? [[String: Any]] else {
                return
            }
            
            var list: [FuelItemModel] = []
            for stateDict in statesArray {
                var model = FuelItemModel()
                model.state = stateDict["state"] as? String
                if let petrol = stateDict["petrol"] {
                    model.petrol = self.formatPriceValue(petrol)
                }
                if let diesel = stateDict["diesel"] {
                    model.diesel = self.formatPriceValue(diesel)
                }
                if let cng = stateDict["cng"] {
                    model.cng = self.formatPriceValue(cng)
                }
                list.append(model)
            }
            
            DispatchQueue.main.async {
                self.fuelItemDataList = list
                self.fuelCardView?.isHidden = list.isEmpty
                self.setupFuelStateMenu()
                self.autoSelectInitialState()
            }
        }
    }
    
    private func setupFuelStateMenu() {
        guard let btn = fuelStateButton, !fuelItemDataList.isEmpty else { return }
        
        if #available(iOS 14.0, *) {
            var actions: [UIAction] = []
            for (index, item) in fuelItemDataList.enumerated() {
                let stateName = item.state?.replacingOccurrences(of: "_", with: " ") ?? ""
                let isSelected = (index == selectedStateIndex)
                let action = UIAction(title: stateName, state: isSelected ? .on : .off) { [weak self] _ in
                    self?.selectFuelState(at: index)
                }
                actions.append(action)
            }
            btn.menu = UIMenu(title: "Select State", children: actions)
            btn.showsMenuAsPrimaryAction = true
        }
    }
    
    @objc private func onFuelStateButtonTapped() {
        guard !fuelItemDataList.isEmpty, let parentVC = parentViewController else { return }
        
        let alert = UIAlertController(title: "Select State", message: nil, preferredStyle: .actionSheet)
        for (index, item) in fuelItemDataList.enumerated() {
            let stateName = item.state?.replacingOccurrences(of: "_", with: " ") ?? ""
            let action = UIAlertAction(title: stateName, style: .default) { [weak self] _ in
                self?.selectFuelState(at: index)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popover = alert.popoverPresentationController, let btn = fuelStateButton {
            popover.sourceView = btn
            popover.sourceRect = btn.bounds
        }
        
        parentVC.present(alert, animated: true, completion: nil)
    }
    
    private func selectFuelState(at index: Int) {
        guard index >= 0 && index < fuelItemDataList.count else { return }
        selectedStateIndex = index
        let item = fuelItemDataList[index]
        let stateName = item.state?.replacingOccurrences(of: "_", with: " ") ?? ""
        
        UserDefaults.standard.set(stateName, forKey: "selected_fuel_state")
        
        fuelStateLabel?.text = stateName
        updateFuelPriceLabels(with: item)
        setupFuelStateMenu()
    }
    
    private func updateFuelPriceLabels(with item: FuelItemModel) {
        if isValidFuelPrice(item.petrol) {
            petrolPriceLabel?.attributedText = formattedPriceString(title: "Petrol:", price: "₹\(item.petrol ?? "")")
            petrolPriceLabel?.isHidden = false
        } else {
            petrolPriceLabel?.isHidden = true
        }
        
        if isValidFuelPrice(item.diesel) {
            dieselPriceLabel?.attributedText = formattedPriceString(title: "Diesel:", price: "₹\(item.diesel ?? "")")
            dieselPriceLabel?.isHidden = false
        } else {
            dieselPriceLabel?.isHidden = true
        }
        
        if isValidFuelPrice(item.cng) {
            cngPriceLabel?.attributedText = formattedPriceString(title: "CNG:", price: "₹\(item.cng ?? "")")
            cngPriceLabel?.isHidden = false
        } else {
            cngPriceLabel?.isHidden = true
        }
    }
    
    private func formattedPriceString(title: String, price: String) -> NSAttributedString {
        let fullText = "\(title)\n\(price)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        
        let font = UIFont(name: "Hind-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        let color = UIColor(red: 50/255, green: 168/255, blue: 82/255, alpha: 1.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: fullText, attributes: attributes)
    }
    
    private func isValidFuelPrice(_ price: String?) -> Bool {
        guard let price = price?.trimmingCharacters(in: .whitespacesAndNewlines), !price.isEmpty else {
            return false
        }
        let lower = price.lowercased()
        if lower == "0" || lower == "0.0" || lower == "0.00" || lower == "na" || lower == "n/a" {
            return false
        }
        return true
    }
    
    private func formatPriceValue(_ value: Any) -> String {
        if let dbl = value as? Double {
            if dbl == floor(dbl) {
                return String(format: "%.0f", dbl)
            } else {
                return "\(dbl)"
            }
        } else if let intVal = value as? Int {
            return "\(intVal)"
        } else if let str = value as? String {
            return str
        }
        return "\(value)"
    }
    
    private func autoSelectInitialState() {
        guard !fuelItemDataList.isEmpty else { return }
        
        let stateNames = fuelItemDataList.map { $0.state?.replacingOccurrences(of: "_", with: " ") ?? "" }
        
        if let saved = UserDefaults.standard.string(forKey: "selected_fuel_state"), !saved.isEmpty {
            let index = getStateIndex(from: stateNames, userState: saved)
            selectFuelState(at: index)
            return
        }
        
        if let lat = LocationManager.shared.latitude, let lon = LocationManager.shared.longitude {
            let loc = CLLocation(latitude: lat, longitude: lon)
            CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
                guard let self = self else { return }
                if let adminArea = placemarks?.first?.administrativeArea {
                    let index = self.getStateIndex(from: stateNames, userState: adminArea)
                    self.selectFuelState(at: index)
                } else {
                    let defaultIndex = self.getStateIndex(from: stateNames, userState: "Assam")
                    self.selectFuelState(at: defaultIndex)
                }
            }
            return
        }
        
        let defaultIndex = getStateIndex(from: stateNames, userState: "Assam")
        selectFuelState(at: defaultIndex)
    }
    
    private func getStateIndex(from stateList: [String], userState: String?) -> Int {
        guard let userState = userState?.trimmingCharacters(in: .whitespacesAndNewlines), !userState.isEmpty else {
            return 0
        }
        let normalizedUserState = userState.replacingOccurrences(of: " ", with: "").lowercased()
        for (i, state) in stateList.enumerated() {
            let normalized = state.replacingOccurrences(of: " ", with: "").lowercased()
            if normalized == normalizedUserState || normalizedUserState.contains(normalized) || normalized.contains(normalizedUserState) {
                return i
            }
        }
        return 0
    }
    
    // MARK: - Setup Trending Cars UI (Programmatic)
    private func setupTrendingCarsUI() {
        guard let container = vehicleDocCardsView?.superview else {
            print("[TrendingCars] vehicleDocCardsView superview is nil")
            return
        }
        
        // Prevent duplicate creation
        if let existing = container.viewWithTag(9910) {
            self.trendingCarsSectionView = existing
            self.trendingCarsCollectionView = existing.viewWithTag(9911) as? UICollectionView
            return
        }
        
        let sectionView = UIView()
        sectionView.tag = 9910
        sectionView.backgroundColor = .clear
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Trending new cars"
        titleLabel.font = UIFont(name: "Hind-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 42/255.0, green: 62/255.0, blue: 44/255.0, alpha: 1.0) // #2A3E2C
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 180, height: 80)
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.tag = 9911
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TrendingCarCell.self, forCellWithReuseIdentifier: TrendingCarCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(cv)
        
        self.trendingCarsSectionView = sectionView
        self.trendingCarsCollectionView = cv
        
        container.addSubview(sectionView)
        
        // Find bottom target view whose top was anchored to vehicleDocCardsView bottom
        var bottomTargetView: UIView?
        for constraint in container.constraints {
            let isTopToBottom = (constraint.firstAttribute == .top && constraint.secondAttribute == .bottom)
            let isSecondDoc = (constraint.secondItem as? UIView == vehicleDocCardsView)
            let isFirstDoc = (constraint.firstItem as? UIView == vehicleDocCardsView)
            
            if isTopToBottom && isSecondDoc {
                bottomTargetView = constraint.firstItem as? UIView
                constraint.isActive = false
                break
            } else if constraint.firstAttribute == .bottom && constraint.secondAttribute == .top && isFirstDoc {
                bottomTargetView = constraint.secondItem as? UIView
                constraint.isActive = false
                break
            }
        }
        
        // Fallback: search for UIImageView in container other than userProfileImage
        if bottomTargetView == nil {
            bottomTargetView = container.subviews.compactMap { $0 as? UIImageView }.first { $0 != userProfileImage }
        }
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            
            // CollectionView
            cv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            cv.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            cv.heightAnchor.constraint(equalToConstant: 88),
            cv.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -4),
            
            // SectionView inside container
            sectionView.topAnchor.constraint(equalTo: vehicleDocCardsView.bottomAnchor, constant: 16),
            sectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        if let bottomTarget = bottomTargetView {
            bottomTarget.topAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: 16).isActive = true
        }
        
        print("[TrendingCars] setupTrendingCarsUI completed successfully.")
    }
    
    // MARK: - Default Trending Cars
    private func setDefaultTrendingCars() {
        if !self.trendingCarsList.isEmpty { return }
        self.trendingCarsList = [
            TrendingCarsModel(
                brandName: "Nissan",
                modelName: "Magnite 2024",
                type: "Compact SUV",
                price: 600000,
                priceDisplay: "₹6.00 Lakh onwards",
                mileage: "17–20 kmpl\n(approx)",
                topSpeed: "160 km/h\n(approx)",
                imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191366/notification_file/Trending%20Car/fseyoew4iew0wucznprh.png",
                specifications: TrendingCarsModel.Specifications(
                    engine_capacity: "999 cc",
                    transmission: "Manual / AMT / CVT",
                    fuel_tank_capacity: "40 Liters",
                    seat_height: "Not Available",
                    kerb_weight: "1000 kg (approx)"
                ),
                detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                    max_power: "72–100 bhp (approx)",
                    max_torque: "96–160 Nm (approx)",
                    riding_mode: "City / Highway"
                )
            ),
            TrendingCarsModel(
                brandName: "Maruti Suzuki",
                modelName: "e Vitara",
                type: "Electric SUV",
                price: 2200000,
                priceDisplay: "₹22 Lakh",
                mileage: "500 km range",
                topSpeed: "150 km/h",
                imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191419/notification_file/Trending%20Car/xupv05m24a6m2h69n86g.png",
                specifications: TrendingCarsModel.Specifications(
                    engine_capacity: "Electric",
                    transmission: "Automatic",
                    fuel_tank_capacity: "61 kWh Battery",
                    seat_height: "Not Available",
                    kerb_weight: "1700 kg"
                ),
                detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                    max_power: "174 bhp",
                    max_torque: "189 Nm",
                    riding_mode: "Eco / Normal / Sport"
                )
            ),
            TrendingCarsModel(
                brandName: "Mahindra",
                modelName: "XEV 9e",
                type: "Electric SUV Coupe",
                price: 3500000,
                priceDisplay: "₹35 Lakh",
                mileage: "656 km range",
                topSpeed: "200 km/h",
                imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191282/notification_file/Trending%20Car/dugm7cp819hkpvrerbsi.png",
                specifications: TrendingCarsModel.Specifications(
                    engine_capacity: "Electric",
                    transmission: "Automatic",
                    fuel_tank_capacity: "79 kWh Battery",
                    seat_height: "Not Available",
                    kerb_weight: "2100 kg"
                ),
                detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                    max_power: "282 bhp",
                    max_torque: "380 Nm",
                    riding_mode: "Sprint / Cruise / Range"
                )
            ),
            TrendingCarsModel(
                brandName: "Mercedes-Benz",
                modelName: "G-Class",
                type: "Luxury SUV",
                price: 25500000,
                priceDisplay: "₹2.55 Crore",
                mileage: "8.5 kmpl",
                topSpeed: "220 km/h",
                imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772189258/notification_file/Trending%20Car/zzd9uy4d0o1tbclyotej.png",
                specifications: TrendingCarsModel.Specifications(
                    engine_capacity: "2925 cc",
                    transmission: "9G-TRONIC Automatic",
                    fuel_tank_capacity: "100 Liters",
                    seat_height: "Not Available",
                    kerb_weight: "2485 kg"
                ),
                detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                    max_power: "326 bhp",
                    max_torque: "700 Nm",
                    riding_mode: "Comfort / Sport / Individual / Trail"
                )
            )
        ]
        self.trendingCarsCollectionView?.reloadData()
    }
    
    // MARK: - Fetch Trending Cars
    func fetchTrendingCars() {
        let url = APIEndpoints.GET_TRENDING_CARS
        print("[TrendingCars] Fetching from: \(url)")
        
        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in
            guard let self = self else { return }
            print("[TrendingCars] API Status: \(status), message: \(message)")
            
            if status, let response = response, let carsArray = response["data"] as? [[String: Any]], !carsArray.isEmpty {
                print("[TrendingCars] Successfully received \(carsArray.count) cars from server")
                var parsedList: [TrendingCarsModel] = []
                for carObj in carsArray {
                    var car = TrendingCarsModel()
                    car.id = carObj["_id"] as? String ?? ""
                    car.brandName = carObj["brand_name"] as? String ?? ""
                    car.modelName = carObj["model_name"] as? String ?? ""
                    car.createdAt = carObj["createdAt"] as? String ?? ""
                    
                    if let carDetails = carObj["car_details"] as? [String: Any] {
                        car.type = carDetails["type"] as? String ?? ""
                        if let priceNum = carDetails["price"] as? NSNumber {
                            car.price = priceNum.doubleValue
                        }
                        car.priceDisplay = carDetails["price_display"] as? String ?? ""
                        car.mileage = carDetails["mileage"] as? String ?? ""
                        car.topSpeed = carDetails["top_speed"] as? String ?? ""
                        car.imageUrl = carDetails["image_url"] as? String ?? ""
                        
                        if let specsObj = carDetails["specifications"] as? [String: Any] {
                            var specs = TrendingCarsModel.Specifications()
                            specs.engine_capacity = specsObj["engine_capacity"] as? String
                            specs.transmission = specsObj["transmission"] as? String
                            specs.fuel_tank_capacity = specsObj["fuel_tank_capacity"] as? String
                            specs.seat_height = specsObj["seat_height"] as? String
                            specs.kerb_weight = specsObj["kerb_weight"] as? String
                            car.specifications = specs
                        }
                        
                        if let detailsObj = carDetails["detailed_specifications"] as? [String: Any] {
                            var details = TrendingCarsModel.DetailedSpecifications()
                            details.max_power = detailsObj["max_power"] as? String
                            details.max_torque = detailsObj["max_torque"] as? String
                            details.riding_mode = detailsObj["riding_mode"] as? String
                            details.gear_shifting_pattern = detailsObj["gear_shifting_pattern"] as? String
                            car.detailedSpecifications = details
                        }
                        
                        if let dimObj = carDetails["dimensions"] as? [String: Any] {
                            var dim = TrendingCarsModel.Dimensions()
                            dim.bootspace = dimObj["bootspace"] as? String
                            dim.ground_clearance = dimObj["ground_clearance"] as? String
                            dim.length = dimObj["length"] as? String
                            dim.width = dimObj["width"] as? String
                            dim.height = dimObj["height"] as? String
                            car.dimensions = dim
                        }
                    }
                    parsedList.append(car)
                }
                
                DispatchQueue.main.async {
                    self.trendingCarsList = parsedList
                    self.trendingCarsSectionView?.isHidden = false
                    self.trendingCarsCollectionView?.reloadData()
                    print("[TrendingCars] Reloaded collection view with \(parsedList.count) items.")
                }
            } else {
                print("[TrendingCars] Keeping existing/default cars, API response: \(String(describing: response))")
            }
        }
    }
    
    // MARK: - Open Trending Car Details
    func openTrendingCarDetails(for model: TrendingCarsModel) {
        guard let parentVC = parentViewController else {
            print("[TrendingCars] openTrendingCarDetails: parentViewController is nil")
            return
        }
        let detailsVC = TrendingCarDetailsVC()
        detailsVC.carModel = model
        if let nav = parentVC.navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: detailsVC)
            nav.modalPresentationStyle = .fullScreen
            parentVC.present(nav, animated: true)
        }
    }
    
    // MARK: - Setup Popular Comparison UI (Programmatic)
    private func setupPopularComparisonUI() {
        guard let container = vehicleDocCardsView?.superview else {
            print("[PopularComparison] vehicleDocCardsView superview is nil")
            return
        }
        
        // Prevent duplicate creation
        if let existing = container.viewWithTag(9920) {
            self.popularComparisonSectionView = existing
            self.popularComparisonCollectionView = existing.viewWithTag(9921) as? UICollectionView
            return
        }
        
        guard let trendingSection = self.trendingCarsSectionView else {
            print("[PopularComparison] trendingCarsSectionView is nil, deferring setup")
            return
        }
        
        let sectionView = UIView()
        sectionView.tag = 9920
        sectionView.backgroundColor = .clear
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Popular comparison"
        titleLabel.font = UIFont(name: "Hind-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 42/255.0, green: 62/255.0, blue: 44/255.0, alpha: 1.0) // #2A3E2C
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 325, height: 175)
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.tag = 9921
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(PopularComparisonCell.self, forCellWithReuseIdentifier: PopularComparisonCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(cv)
        
        self.popularComparisonSectionView = sectionView
        self.popularComparisonCollectionView = cv
        
        container.addSubview(sectionView)
        
        // Find bottom target view whose top was anchored to trendingSection.bottomAnchor
        var bottomTargetView: UIView?
        for constraint in container.constraints {
            let isTopToBottom = (constraint.firstAttribute == .top && constraint.secondAttribute == .bottom)
            let isSecondTrending = (constraint.secondItem as? UIView == trendingSection)
            let isFirstTrending = (constraint.firstItem as? UIView == trendingSection)
            
            if isTopToBottom && isSecondTrending {
                bottomTargetView = constraint.firstItem as? UIView
                constraint.isActive = false
                break
            } else if constraint.firstAttribute == .bottom && constraint.secondAttribute == .top && isFirstTrending {
                bottomTargetView = constraint.secondItem as? UIView
                constraint.isActive = false
                break
            }
        }
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            
            // CollectionView
            cv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            cv.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            cv.heightAnchor.constraint(equalToConstant: 185),
            cv.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -4),
            
            // SectionView inside container
            sectionView.topAnchor.constraint(equalTo: trendingSection.bottomAnchor, constant: 16),
            sectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        if let bottomTarget = bottomTargetView {
            bottomTarget.topAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: 16).isActive = true
        }
        
        print("[PopularComparison] setupPopularComparisonUI completed successfully.")
    }
    
    // MARK: - Default Popular Comparisons
    private func setDefaultPopularComparisons() {
        if !self.popularComparisonList.isEmpty { return }
        self.popularComparisonList = [
            TrendingVSCarsModel(
                comparisonId: "comp_1",
                createdAt: "",
                car1Data: TrendingCarsModel(
                    id: "69a17ea2935fd69e1be81ed9",
                    car_id: "69a17ea2935fd69e1be81ed9",
                    brandName: "Nissan",
                    modelName: "Magnite 2024",
                    type: "Compact SUV",
                    price: 600000,
                    priceDisplay: "₹6.00 Lakh onwards",
                    mileage: "17–20 kmpl (approx)",
                    topSpeed: "160 km/h (approx)",
                    imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191366/notification_file/Trending%20Car/fseyoew4iew0wucznprh.png",
                    specifications: TrendingCarsModel.Specifications(
                        engine_capacity: "999 cc",
                        transmission: "Manual / AMT / CVT",
                        fuel_tank_capacity: "40 Liters",
                        seat_height: "Not Available",
                        kerb_weight: "1000 kg (approx)"
                    ),
                    detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                        max_power: "72–100 bhp (approx)",
                        max_torque: "96–160 Nm (approx)",
                        riding_mode: "City / Highway",
                        gear_shifting_pattern: "5-Speed Manual / AMT / CVT"
                    ),
                    dimensions: TrendingCarsModel.Dimensions(
                        bootspace: "336 Liters",
                        ground_clearance: "205 mm",
                        length: "3994 mm",
                        width: "1758 mm",
                        height: "1572 mm"
                    ),
                    features: TrendingCarsModel.Features(
                        air_conditioner: true,
                        central_locking: "Keyless",
                        power_windows: "Front & Rear",
                        headrest: "Front & Rear",
                        parking_assist: "Rear Camera + Sensors",
                        cruise_control: false,
                        music_system_count: 1,
                        apple_carplay: "Wired",
                        android_auto: "Wired",
                        abs: true,
                        sunroof: false,
                        third_row_ac: false,
                        airbags: ["Driver", "Front Passenger", "Side", "Curtain"]
                    )
                ),
                car2Data: TrendingCarsModel(
                    id: "69a17e1b435928f96397df58",
                    car_id: "69a17e1b435928f96397df58",
                    brandName: "Honda",
                    modelName: "Amaze 2024",
                    type: "Compact Sedan",
                    price: 720000,
                    priceDisplay: "₹7.20 Lakh onwards",
                    mileage: "18–20 kmpl (Petrol, approx)",
                    topSpeed: "160 km/h (approx)",
                    imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191200/notification_file/Trending%20Car/zvhiagn8m8dwg4qqooje.png",
                    specifications: TrendingCarsModel.Specifications(
                        engine_capacity: "1199 cc",
                        transmission: "Manual / CVT Automatic",
                        fuel_tank_capacity: "35 Liters",
                        seat_height: "Not Available",
                        kerb_weight: "980 kg (approx)"
                    ),
                    detailedSpecifications: TrendingCarsModel.DetailedSpecifications(
                        max_power: "90 bhp (approx)",
                        max_torque: "110 Nm (approx)",
                        riding_mode: "City / Highway",
                        gear_shifting_pattern: "5-Speed Manual / CVT"
                    ),
                    dimensions: TrendingCarsModel.Dimensions(
                        bootspace: "420 Liters",
                        ground_clearance: "170 mm",
                        length: "3995 mm",
                        width: "1695 mm",
                        height: "1501 mm"
                    ),
                    features: TrendingCarsModel.Features(
                        air_conditioner: true,
                        central_locking: "Keyless",
                        power_windows: "Front & Rear",
                        headrest: "Front & Rear",
                        parking_assist: "Rear Camera + Sensors",
                        cruise_control: false,
                        music_system_count: 1,
                        apple_carplay: "Wired",
                        android_auto: "Wired",
                        abs: true,
                        sunroof: false,
                        third_row_ac: false,
                        airbags: ["Driver", "Front Passenger", "Side", "Curtain"]
                    )
                )
            ),
            TrendingVSCarsModel(
                comparisonId: "comp_2",
                createdAt: "",
                car1Data: TrendingCarsModel(
                    brandName: "Maruti Suzuki",
                    modelName: "e Vitara",
                    type: "Electric SUV",
                    price: 2200000,
                    priceDisplay: "₹22 Lakh",
                    imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191419/notification_file/Trending%20Car/xupv05m24a6m2h69n86g.png"
                ),
                car2Data: TrendingCarsModel(
                    brandName: "Mahindra",
                    modelName: "XEV 9e",
                    type: "Electric SUV",
                    price: 3500000,
                    priceDisplay: "₹35 Lakh",
                    imageUrl: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772191282/notification_file/Trending%20Car/dugm7cp819hkpvrerbsi.png"
                )
            )
        ]
        self.popularComparisonCollectionView?.reloadData()
    }
    
    // MARK: - Fetch Popular Comparisons
    func fetchPopularComparisons() {
        let url = APIEndpoints.GET_COMPARE_VEHICLE_DATA_SET
        print("[PopularComparison] Fetching from: \(url)")
        
        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in
            guard let self = self else { return }
            print("[PopularComparison] API Status: \(status), message: \(message)")
            
            var comparisonsArray: [[String: Any]] = []
            if status, let response = response {
                if let arr = response["data"] as? [[String: Any]] {
                    comparisonsArray = arr
                } else if let dataObj = response["data"] as? [String: Any], let comps = dataObj["comparisons"] as? [[String: Any]] {
                    comparisonsArray = comps
                }
            }
            
            if !comparisonsArray.isEmpty {
                print("[PopularComparison] Successfully received \(comparisonsArray.count) comparisons from server")
                var parsedList: [TrendingVSCarsModel] = []
                for item in comparisonsArray {
                    var vsModel = TrendingVSCarsModel()
                    vsModel.comparisonId = item["_id"] as? String ?? ""
                    vsModel.createdAt = item["createdAt"] as? String ?? ""
                    
                    let car1Obj = item["car_1"] as? [String: Any] ?? item["car_1_data"] as? [String: Any]
                    if let car1 = car1Obj {
                        var c1 = TrendingCarsModel()
                        c1.id = car1["_id"] as? String ?? ""
                        c1.car_id = car1["_id"] as? String ?? ""
                        c1.brandName = car1["brand_name"] as? String ?? ""
                        c1.modelName = car1["model_name"] as? String ?? ""
                        let details = car1["car_details"] as? [String: Any] ?? car1
                        c1.type = details["type"] as? String ?? ""
                        c1.priceDisplay = details["price_display"] as? String ?? ""
                        c1.mileage = details["mileage"] as? String ?? ""
                        c1.topSpeed = details["top_speed"] as? String ?? ""
                        c1.imageUrl = details["image_url"] as? String ?? ""
                        vsModel.car1Data = c1
                    }
                    
                    let car2Obj = item["car_2"] as? [String: Any] ?? item["car_2_data"] as? [String: Any]
                    if let car2 = car2Obj {
                        var c2 = TrendingCarsModel()
                        c2.id = car2["_id"] as? String ?? ""
                        c2.car_id = car2["_id"] as? String ?? ""
                        c2.brandName = car2["brand_name"] as? String ?? ""
                        c2.modelName = car2["model_name"] as? String ?? ""
                        let details = car2["car_details"] as? [String: Any] ?? car2
                        c2.type = details["type"] as? String ?? ""
                        c2.priceDisplay = details["price_display"] as? String ?? ""
                        c2.mileage = details["mileage"] as? String ?? ""
                        c2.topSpeed = details["top_speed"] as? String ?? ""
                        c2.imageUrl = details["image_url"] as? String ?? ""
                        vsModel.car2Data = c2
                    }
                    parsedList.append(vsModel)
                }
                
                DispatchQueue.main.async {
                    self.popularComparisonList = parsedList
                    self.popularComparisonSectionView?.isHidden = false
                    self.popularComparisonCollectionView?.reloadData()
                    print("[PopularComparison] Reloaded collection view with \(parsedList.count) items.")
                }
            } else {
                print("[PopularComparison] Keeping existing/default comparisons.")
            }
        }
    }
    
    // MARK: - Open Popular Comparison Details
    func openPopularComparisonDetails(for model: TrendingVSCarsModel) {
        guard let parentVC = parentViewController else {
            print("[PopularComparison] openPopularComparisonDetails: parentViewController is nil")
            return
        }
        let detailsVC = TrendingVSCarDetailsVC()
        detailsVC.vsModel = model
        if let nav = parentVC.navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: detailsVC)
            nav.modalPresentationStyle = .fullScreen
            parentVC.present(nav, animated: true)
        }
    }
    
    // MARK: - Tips Card Size Helper (Exact 1024x470 Aspect Ratio)
    private func getTipsCardSize(for collectionView: UICollectionView) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let cvWidth = collectionView.bounds.width > 32 ? collectionView.bounds.width : screenWidth
        let cellWidth = cvWidth - 32 // 16pt inset on each side
        let innerWidth = cellWidth - 8 // 4pt leading/trailing margin in cell
        let innerHeight = round(innerWidth * (470.0 / 1024.0))
        let cellHeight = innerHeight + 8 // 4pt top/bottom margin in cell
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - Setup Tips UI
    func setupTipsUI() {
        guard let container = vehicleDocCardsView.superview else {
            print("[Tips] vehicleDocCardsView.superview is nil")
            return
        }
        
        // Prevent duplicate creation
        if let existing = container.viewWithTag(9930) {
            self.tipsSectionView = existing
            self.tipsCollectionView = existing.viewWithTag(9931) as? UICollectionView
            return
        }
        
        guard let comparisonSection = self.popularComparisonSectionView else {
            print("[Tips] popularComparisonSectionView is nil, deferring setup")
            return
        }
        
        let sectionView = UIView()
        sectionView.tag = 9930
        sectionView.backgroundColor = .clear
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Tips"
        titleLabel.font = UIFont(name: "Hind-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 42/255.0, green: 62/255.0, blue: 44/255.0, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.tag = 9931
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.delegate = self
        cv.dataSource = self
        cv.register(TipsCell.self, forCellWithReuseIdentifier: TipsCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(cv)
        
        let initialCardSize = getTipsCardSize(for: cv)
        layout.itemSize = initialCardSize
        
        let heightConstraint = cv.heightAnchor.constraint(equalToConstant: initialCardSize.height + 8)
        self.tipsCollectionViewHeightConstraint = heightConstraint
        
        self.tipsSectionView = sectionView
        self.tipsCollectionView = cv
        
        container.addSubview(sectionView)
        
        // Find bottom target view whose top was anchored to comparisonSection.bottomAnchor
        var bottomTargetView: UIView?
        for constraint in container.constraints {
            let isTopToBottom = (constraint.firstAttribute == .top && constraint.secondAttribute == .bottom)
            let isSecondComp = (constraint.secondItem as? UIView == comparisonSection)
            let isFirstComp = (constraint.firstItem as? UIView == comparisonSection)
            
            if isTopToBottom && isSecondComp {
                bottomTargetView = constraint.firstItem as? UIView
                constraint.isActive = false
                break
            } else if constraint.firstAttribute == .bottom && constraint.secondAttribute == .top && isFirstComp {
                bottomTargetView = constraint.secondItem as? UIView
                constraint.isActive = false
                break
            }
        }
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            
            // CollectionView
            cv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            cv.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            heightConstraint,
            cv.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -4),
            
            // SectionView inside container
            sectionView.topAnchor.constraint(equalTo: comparisonSection.bottomAnchor, constant: 16),
            sectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        if let bottomTarget = bottomTargetView {
            bottomTarget.topAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: 16).isActive = true
        }
        
        print("[Tips] setupTipsUI completed successfully.")
    }
    
    // MARK: - Default Tips
    private func setDefaultTips() {
        if !self.tipsList.isEmpty { return }
        self.tipsList = [
            TipsItemModel(
                id: "default_1",
                banner: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192931/tips_tricks/banner/bcn4ehldgaxdqwdhlgzh.png",
                title: "SAVE FUEL, SAVE MONEY",
                summary: "Smart driving techniques se fuel efficiency ko kaafi had tak badhaya ja sakta hai.",
                points: [
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192930/tips_tricks/icons/nck0yq0o9u29a24m4r6z.png", message: "Drive at Steady Speed \nEk steady aur moderate speed maintain karne se engine par unnecessary load nahi padta aur fuel consumption kam hota hai."),
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192930/tips_tricks/icons/ztt3pypo1yivz5y3v7b4.png", message: "Avoid Sudden Braking \nBar-bar tez accelerate aur achanak brake lagane se bachein kyunki isse fuel bohot jaldi khatam hota hai."),
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192930/tips_tricks/icons/e33d2k05gcmjhy1y4qow.png", message: "Turn Off Engine at Signals \nLambe traffic signals ya 30 seconds se zyada wait karte waqt engine band kar dena fuel bachat me madad karta hai."),
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192930/tips_tricks/icons/q1ev3w5x2c1x5v2x2x2x.png", message: "Maintain Proper Tire Pressure \nTires me sahi hawa hone se road friction reduce hota hai aur car smoothly chalti hai jisse fuel save hota hai.")
                ]
            ),
            TipsItemModel(
                id: "default_2",
                banner: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192770/tips_tricks/banner/mdf2g0h6v8bshuvb2bso.png",
                title: "ROAD TRIP READY: PLAN SMART",
                summary: "Ek safe aur enjoyable road trip ke liye proper preparation zaroori hai.",
                points: [
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192769/tips_tricks/icons/t6h5g8b9c1d2e3f4a5b6.png", message: "Plan Your Route & Stops \nPehle se route check karna aur rest stops plan karna long drive ko comfortable aur stress-free banata hai."),
                    TipsItemModel.Point(icon: "https://res.cloudinary.com/dikbzoeh7/image/upload/v1772192769/tips_tricks/icons/a1b2c3d4e5f6g7h8i9j0.png", message: "Keep Documents Handy \nDriving license, RC, insurance aur pollution certificate digital ya hard copy me ready rakhein.")
                ]
            )
        ]
        self.tipsCollectionView?.reloadData()
        self.startTipsAutoScroll()
    }
    
    // MARK: - Fetch Tips
    func fetchTips() {
        let url = APIEndpoints.GET_TIPS_TRICKS
        print("[Tips] Fetching from: \(url)")
        
        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { [weak self] response, status, message in
            guard let self = self else { return }
            print("[Tips] API Status: \(status), message: \(message)")
            
            var tipsArray: [[String: Any]] = []
            if status, let response = response {
                if let arr = response["data"] as? [[String: Any]] {
                    tipsArray = arr
                }
            }
            
            if !tipsArray.isEmpty {
                var parsedList: [TipsItemModel] = []
                for item in tipsArray {
                    var model = TipsItemModel()
                    model.id = item["_id"] as? String ?? item["id"] as? String
                    model.banner = item["banner"] as? String
                    model.banner_public_id = item["banner_public_id"] as? String
                    model.title = item["title"] as? String
                    model.summary = item["summary"] as? String
                    
                    if let pointsArr = item["points"] as? [[String: Any]] {
                        for pt in pointsArr {
                            let point = TipsItemModel.Point(
                                icon: pt["icon"] as? String,
                                message: pt["message"] as? String,
                                icon_public_id: pt["icon_public_id"] as? String
                            )
                            model.points.append(point)
                        }
                    }
                    parsedList.append(model)
                }
                
                DispatchQueue.main.async {
                    self.tipsList = parsedList
                    self.tipsSectionView?.isHidden = false
                    self.tipsCollectionView?.reloadData()
                    self.startTipsAutoScroll()
                    print("[Tips] Reloaded collection view with \(parsedList.count) items.")
                }
            } else {
                print("[Tips] Keeping existing/default tips.")
            }
        }
    }
    
    // MARK: - Tips Auto-scroll
    func startTipsAutoScroll() {
        stopTipsAutoScroll()
        guard tipsList.count > 1 else { return }
        tipsAutoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            guard let self = self, let cv = self.tipsCollectionView, !self.tipsList.isEmpty else { return }
            self.currentTipsIndex = (self.currentTipsIndex + 1) % self.tipsList.count
            cv.scrollToItem(at: IndexPath(item: self.currentTipsIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func stopTipsAutoScroll() {
        tipsAutoScrollTimer?.invalidate()
        tipsAutoScrollTimer = nil
    }
    
    // MARK: - Open Tips Details
    func openTipsDetails(for model: TipsItemModel) {
        guard let parentVC = parentViewController else {
            print("[Tips] openTipsDetails: parentViewController is nil")
            return
        }
        let detailsVC = TipsDetailsVC()
        detailsVC.tipsItemDetails = model
        if let nav = parentVC.navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: detailsVC)
            nav.modalPresentationStyle = .fullScreen
            parentVC.present(nav, animated: true)
        }
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension DashBoardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var cardInset: CGFloat { return 26 }
    private var cardSpacing: CGFloat { return 14 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trendingCarsCollectionView {
            return trendingCarsList.count
        }
        if collectionView == popularComparisonCollectionView {
            return popularComparisonList.count
        }
        if collectionView == tipsCollectionView {
            return tipsList.count
        }
        return garageItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trendingCarsCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrendingCarCell.identifier,
                for: indexPath
            ) as! TrendingCarCell
            let item = trendingCarsList[indexPath.item]
            cell.configure(with: item)
            return cell
        }
        
        if collectionView == popularComparisonCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopularComparisonCell.identifier,
                for: indexPath
            ) as! PopularComparisonCell
            let item = popularComparisonList[indexPath.item]
            cell.configure(with: item)
            return cell
        }
        
        if collectionView == tipsCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TipsCell.identifier,
                for: indexPath
            ) as! TipsCell
            let item = tipsList[indexPath.item]
            cell.configure(with: item)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VehicleCardCell.identifier,
            for: indexPath
        ) as! VehicleCardCell
        
        let item = garageItemList[indexPath.item]
        cell.configure(with: item) { [weak self] in
            self?.openVehicleInfo(for: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trendingCarsCollectionView {
            guard indexPath.item < trendingCarsList.count else { return }
            let car = trendingCarsList[indexPath.item]
            openTrendingCarDetails(for: car)
        } else if collectionView == popularComparisonCollectionView {
            guard indexPath.item < popularComparisonList.count else { return }
            let comp = popularComparisonList[indexPath.item]
            openPopularComparisonDetails(for: comp)
        } else if collectionView == tipsCollectionView {
            guard indexPath.item < tipsList.count else { return }
            let item = tipsList[indexPath.item]
            openTipsDetails(for: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trendingCarsCollectionView {
            return CGSize(width: 180, height: 80)
        }
        if collectionView == popularComparisonCollectionView {
            return CGSize(width: 325, height: 175)
        }
        if collectionView == tipsCollectionView {
            return getTipsCardSize(for: collectionView)
        }
        let width = collectionView.bounds.width > 0 ? collectionView.bounds.width : UIScreen.main.bounds.width
        let cardWidth = width - (cardInset * 2)
        return CGSize(width: cardWidth, height: 146)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == trendingCarsCollectionView {
            return UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        }
        if collectionView == popularComparisonCollectionView {
            return UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        }
        if collectionView == tipsCollectionView {
            return UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        }
        return UIEdgeInsets(top: 2, left: cardInset, bottom: 2, right: cardInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == trendingCarsCollectionView {
            return 14
        }
        if collectionView == popularComparisonCollectionView {
            return 14
        }
        if collectionView == tipsCollectionView {
            return 14
        }
        return cardSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == trendingCarsCollectionView {
            return 14
        }
        if collectionView == popularComparisonCollectionView {
            return 14
        }
        if collectionView == tipsCollectionView {
            return 14
        }
        return cardSpacing
    }
    
    // MARK: - UIScrollViewDelegate (Snapping carousel without auto-scroll)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tipsCollectionView {
            stopTipsAutoScroll()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tipsCollectionView && !decelerate {
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.bounds.width / 2), y: scrollView.bounds.height / 2)
            if let indexPath = tipsCollectionView?.indexPathForItem(at: center) {
                currentTipsIndex = indexPath.item
            }
            startTipsAutoScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tipsCollectionView {
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.bounds.width / 2), y: scrollView.bounds.height / 2)
            if let indexPath = tipsCollectionView?.indexPathForItem(at: center) {
                currentTipsIndex = indexPath.item
            }
            startTipsAutoScroll()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == garageCollectionView {
            let width = scrollView.bounds.width > 0 ? scrollView.bounds.width : UIScreen.main.bounds.width
            let cardWidth = width - (cardInset * 2)
            let itemWidth = cardWidth + cardSpacing
            guard itemWidth > 0 else { return }
            
            let estimatedIndex = scrollView.contentOffset.x / itemWidth
            let targetIndex: CGFloat
            if velocity.x > 0.2 {
                targetIndex = ceil(estimatedIndex)
            } else if velocity.x < -0.2 {
                targetIndex = floor(estimatedIndex)
            } else {
                targetIndex = round(estimatedIndex)
            }
            
            let maxIndex = CGFloat(max(0, garageItemList.count - 1))
            let clampedIndex = max(0, min(maxIndex, targetIndex))
            
            targetContentOffset.pointee = CGPoint(x: clampedIndex * itemWidth, y: 0)
            let page = Int(clampedIndex)
            garagePageControl?.currentPage = page
            updateDocCardsForSelectedVehicle(at: page)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == garageCollectionView {
            let width = scrollView.bounds.width > 0 ? scrollView.bounds.width : UIScreen.main.bounds.width
            let cardWidth = width - (cardInset * 2)
            let itemWidth = cardWidth + cardSpacing
            guard itemWidth > 0 else { return }
            let page = Int(round(scrollView.contentOffset.x / itemWidth))
            if page >= 0 && page < garageItemList.count {
                garagePageControl?.currentPage = page
                updateDocCardsForSelectedVehicle(at: page)
            }
        }
    }
    
    private func updateDocCardsForSelectedVehicle(at index: Int) {
        guard index >= 0 && index < garageItemList.count else { return }
        if selectedGarageVehicleIndex != index {
            selectedGarageVehicleIndex = index
            vehicleDocCardsView?.configure(with: garageItemList[index])
        }
    }
}
