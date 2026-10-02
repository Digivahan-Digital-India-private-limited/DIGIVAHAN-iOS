//
//  TrendingVSCarDetailsVC.swift
//  DigiVahan
//
//  Created for DigiVahan Vehicle Comparison screen.
//

import UIKit
import SDWebImage

// MARK: - Comparison Data Models
class ComparisonItemModel {
    let label: String
    let leftText: String
    let rightText: String
    var highlightLeft: Bool
    var highlightRight: Bool
    let isBoolean: Bool
    
    init(label: String, leftText: String?, rightText: String?, highlightLeft: Bool = false, highlightRight: Bool = false, isBoolean: Bool = false) {
        self.label = label
        self.leftText = (leftText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) ? "N/A" : leftText!
        self.rightText = (rightText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) ? "N/A" : rightText!
        self.highlightLeft = highlightLeft
        self.highlightRight = highlightRight
        self.isBoolean = isBoolean
    }
    
    static func bool(label: String, left: Bool?, right: Bool?) -> ComparisonItemModel {
        let l = left ?? false
        let r = right ?? false
        return ComparisonItemModel(label: label, leftText: "\(l)", rightText: "\(r)", highlightLeft: l, highlightRight: r, isBoolean: true)
    }
    
    @discardableResult
    func highlightLeftPill() -> ComparisonItemModel {
        self.highlightLeft = true
        return self
    }
    
    @discardableResult
    func highlightRightPill() -> ComparisonItemModel {
        self.highlightRight = true
        return self
    }
}

class ComparisonSectionModel {
    let title: String
    let items: [ComparisonItemModel]
    var expanded: Bool
    
    init(title: String, items: [ComparisonItemModel], expanded: Bool = true) {
        self.title = title
        self.items = items
        self.expanded = expanded
    }
}

// MARK: - Main ViewController
class TrendingVSCarDetailsVC: BaseViewController {
    
    // MARK: - Properties
    var vsModel: TrendingVSCarsModel?
    private var sectionModels: [ComparisonSectionModel] = []
    
    // MARK: - UI Components
    private let topNavBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .custom)
        if let icon = UIImage(named: "back_arrow") {
            btn.setImage(icon.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let fallback = UIImage(systemName: "arrow.left") {
            btn.setImage(fallback, for: .normal)
            btn.tintColor = .black
        }
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Comparison"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Header Comparison Banner (matching Android bg_card2)
    private class HeaderGradientView: UIView {
        private let gradientLayer = CAGradientLayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            // Android bg_card2: gradient from white at top to #36B72E at bottom
            gradientLayer.colors = [
                UIColor.white.cgColor,
                UIColor(red: 220/255.0, green: 245/255.0, blue: 218/255.0, alpha: 1.0).cgColor,
                UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0).cgColor
            ]
            gradientLayer.locations = [0.0, 0.45, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            layer.addSublayer(gradientLayer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = bounds
        }
    }
    
    private let heroBannerView: HeaderGradientView = {
        let view = HeaderGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Car 1 Top View
    private let car1ImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let car1NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let car1PriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Center VS Label
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Car 2 Top View
    private let car2ImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let car2NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let car2PriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Sections Stack
    private let sectionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Data not found"
        label.font = UIFont(name: "Hind-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.color = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigation()
        setupScrollView()
        setupHeroBanner()
        setupSectionsContainer()
        
        updateHeroBanner()
        renderSections()
        fetchAndPopulateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Navigation Setup
    private func setupNavigation() {
        view.addSubview(topNavBarView)
        topNavBarView.addSubview(backButton)
        topNavBarView.addSubview(navTitleLabel)
        
        backButton.addTarget(self, action: #selector(onBackTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            topNavBarView.topAnchor.constraint(equalTo: view.topAnchor),
            topNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            backButton.bottomAnchor.constraint(equalTo: topNavBarView.bottomAnchor, constant: -4),
            backButton.leadingAnchor.constraint(equalTo: topNavBarView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: topNavBarView.centerXAnchor)
        ])
    }
    
    @objc private func onBackTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - ScrollView Setup
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topNavBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    // MARK: - Hero Banner Setup
    private func setupHeroBanner() {
        contentView.addSubview(heroBannerView)
        
        // Car 1 Column
        let car1Col = UIStackView(arrangedSubviews: [car1ImageView, car1NameLabel, car1PriceLabel])
        car1Col.axis = .vertical
        car1Col.spacing = 4
        car1Col.alignment = .center
        car1Col.translatesAutoresizingMaskIntoConstraints = false
        
        // Car 2 Column
        let car2Col = UIStackView(arrangedSubviews: [car2ImageView, car2NameLabel, car2PriceLabel])
        car2Col.axis = .vertical
        car2Col.spacing = 4
        car2Col.alignment = .center
        car2Col.translatesAutoresizingMaskIntoConstraints = false
        
        heroBannerView.addSubview(car1Col)
        heroBannerView.addSubview(vsLabel)
        heroBannerView.addSubview(car2Col)
        
        NSLayoutConstraint.activate([
            heroBannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroBannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroBannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroBannerView.heightAnchor.constraint(equalToConstant: 125),
            
            vsLabel.centerXAnchor.constraint(equalTo: heroBannerView.centerXAnchor),
            vsLabel.centerYAnchor.constraint(equalTo: heroBannerView.centerYAnchor),
            vsLabel.widthAnchor.constraint(equalToConstant: 36),
            
            car1Col.leadingAnchor.constraint(equalTo: heroBannerView.leadingAnchor, constant: 16),
            car1Col.trailingAnchor.constraint(equalTo: vsLabel.leadingAnchor, constant: -8),
            car1Col.centerYAnchor.constraint(equalTo: heroBannerView.centerYAnchor),
            car1ImageView.widthAnchor.constraint(equalToConstant: 72),
            car1ImageView.heightAnchor.constraint(equalToConstant: 40),
            
            car2Col.leadingAnchor.constraint(equalTo: vsLabel.trailingAnchor, constant: 8),
            car2Col.trailingAnchor.constraint(equalTo: heroBannerView.trailingAnchor, constant: -16),
            car2Col.centerYAnchor.constraint(equalTo: heroBannerView.centerYAnchor),
            car2ImageView.widthAnchor.constraint(equalToConstant: 72),
            car2ImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Sections Container Setup
    private func setupSectionsContainer() {
        contentView.addSubview(sectionsStackView)
        contentView.addSubview(emptyLabel)
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            sectionsStackView.topAnchor.constraint(equalTo: heroBannerView.bottomAnchor, constant: 14),
            sectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            sectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            sectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            emptyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: heroBannerView.bottomAnchor, constant: 40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: heroBannerView.bottomAnchor, constant: 30)
        ])
    }
    
    // MARK: - Update Hero Banner
    private func updateHeroBanner() {
        guard let vs = vsModel else { return }
        let c1 = vs.car1Data
        let c2 = vs.car2Data
        
        car1NameLabel.text = c1?.modelName ?? "Car 1"
        car1PriceLabel.text = c1?.priceDisplay ?? ""
        if let rawUrl = c1?.imageUrl?.components(separatedBy: ",")[0].trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: rawUrl) {
            car1ImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_vehicle_default"))
        } else {
            car1ImageView.image = UIImage(named: "ic_vehicle_default")
        }
        
        car2NameLabel.text = c2?.modelName ?? "Car 2"
        car2PriceLabel.text = c2?.priceDisplay ?? ""
        if let rawUrl = c2?.imageUrl?.components(separatedBy: ",")[0].trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: rawUrl) {
            car2ImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_vehicle_default"))
        } else {
            car2ImageView.image = UIImage(named: "ic_vehicle_default")
        }
    }
    
    // MARK: - Fetch and Populate Data
    private func fetchAndPopulateData() {
        guard let vs = vsModel else {
            renderSections()
            return
        }
        
        let car1Id = vs.car1Data?.car_id ?? vs.car1Data?.id ?? ""
        let car2Id = vs.car2Data?.car_id ?? vs.car2Data?.id ?? ""
        
        if car1Id.isEmpty && car2Id.isEmpty {
            renderSections()
            return
        }
        
        loadingIndicator.startAnimating()
        
        fetchSingleCarDetails(carId: car1Id) { [weak self] fullCar1 in
            guard let self = self else { return }
            if let fullCar1 = fullCar1 {
                self.vsModel?.car1Data = fullCar1
                self.updateHeroBanner()
            }
            
            self.fetchSingleCarDetails(carId: car2Id) { [weak self] fullCar2 in
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                if let fullCar2 = fullCar2 {
                    self.vsModel?.car2Data = fullCar2
                    self.updateHeroBanner()
                }
                self.renderSections()
            }
        }
    }
    
    private func fetchSingleCarDetails(carId: String, completion: @escaping (TrendingCarsModel?) -> Void) {
        guard !carId.isEmpty else {
            completion(nil)
            return
        }
        
        let url = APIEndpoints.GET_TRENDING_CARS_BY_ID + carId
        print("[ComparisonDetails] Fetching car details for: \(carId) at \(url)")
        
        NetworkManager.shared.callAPI(
            url: url,
            method: "GET",
            parameters: nil
        ) { response, status, message in
            guard status, let response = response, let carData = response["data"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            var car = TrendingCarsModel()
            car.id = carData["_id"] as? String ?? ""
            car.car_id = carData["_id"] as? String ?? ""
            car.brandName = carData["brand_name"] as? String ?? ""
            car.modelName = carData["model_name"] as? String ?? ""
            car.createdAt = carData["createdAt"] as? String ?? ""
            
            let carDetailsObj = carData["car_details"] as? [String: Any] ?? carData
            car.type = carDetailsObj["type"] as? String ?? ""
            car.price = carDetailsObj["price"] as? Double
            car.priceDisplay = carDetailsObj["price_display"] as? String ?? ""
            car.mileage = carDetailsObj["mileage"] as? String ?? ""
            car.topSpeed = carDetailsObj["top_speed"] as? String ?? ""
            car.imageUrl = carDetailsObj["image_url"] as? String ?? ""
            
            // Specifications
            if let specsObj = carDetailsObj["specifications"] as? [String: Any] {
                var specs = TrendingCarsModel.Specifications()
                specs.engine_capacity = specsObj["engine_capacity"] as? String ?? ""
                specs.transmission = specsObj["transmission"] as? String ?? ""
                specs.fuel_tank_capacity = specsObj["fuel_tank_capacity"] as? String ?? ""
                specs.seat_height = specsObj["seat_height"] as? String ?? ""
                specs.kerb_weight = specsObj["kerb_weight"] as? String ?? ""
                car.specifications = specs
            }
            
            // Detailed specifications
            if let detailsObj = carDetailsObj["detailed_specifications"] as? [String: Any] {
                var details = TrendingCarsModel.DetailedSpecifications()
                details.max_power = detailsObj["max_power"] as? String ?? ""
                details.max_torque = detailsObj["max_torque"] as? String ?? ""
                details.riding_mode = detailsObj["riding_mode"] as? String ?? ""
                details.gear_shifting_pattern = detailsObj["gear_shifting_pattern"] as? String ?? ""
                car.detailedSpecifications = details
            }
            
            // Dimensions
            if let dimObj = carDetailsObj["dimensions"] as? [String: Any] {
                var dim = TrendingCarsModel.Dimensions()
                dim.bootspace = dimObj["bootspace"] as? String ?? ""
                dim.ground_clearance = dimObj["ground_clearance"] as? String ?? ""
                dim.length = dimObj["length"] as? String ?? ""
                dim.width = dimObj["width"] as? String ?? ""
                dim.height = dimObj["height"] as? String ?? ""
                car.dimensions = dim
            }
            
            // Features
            if let featObj = carDetailsObj["features"] as? [String: Any] {
                var features = TrendingCarsModel.Features()
                features.air_conditioner = featObj["air_conditioner"] as? Bool
                features.central_locking = featObj["central_locking"] as? String
                features.power_windows = featObj["power_windows"] as? String
                features.headrest = featObj["headrest"] as? String
                features.parking_assist = featObj["parking_assist"] as? String
                features.cruise_control = featObj["cruise_control"] as? Bool
                features.music_system_count = featObj["music_system_count"] as? Int
                features.apple_carplay = featObj["apple_carplay"] as? String
                features.android_auto = featObj["android_auto"] as? String
                features.abs = featObj["abs"] as? Bool
                features.sunroof = featObj["sunroof"] as? Bool
                features.third_row_ac = featObj["third_row_ac"] as? Bool
                features.airbags = featObj["airbags"] as? [String]
                car.features = features
            }
            
            completion(car)
        }
    }
    
    // MARK: - Build Data (Matching Android buildData())
    private func buildData() -> [ComparisonSectionModel] {
        guard let vs = vsModel, let c1 = vs.car1Data, let c2 = vs.car2Data else {
            return []
        }
        
        var list: [ComparisonSectionModel] = []
        
        // 1. Overview
        var o: [ComparisonItemModel] = []
        o.append(ComparisonItemModel(label: "Maker", leftText: c1.brandName ?? "Nissan", rightText: c2.brandName ?? "Honda"))
        o.append(ComparisonItemModel(label: "Model Name", leftText: c1.modelName ?? "Magnite 2024", rightText: c2.modelName ?? "Amaze 2024"))
        o.append(ComparisonItemModel(label: "Car Type", leftText: c1.type ?? "Compact SUV", rightText: c2.type ?? "Compact Sedan"))
        o.append(ComparisonItemModel(label: "On Road Price", leftText: c1.priceDisplay ?? "₹6.00 Lakh onwards", rightText: c2.priceDisplay ?? "₹7.20 Lakh onwards").highlightLeftPill())
        o.append(ComparisonItemModel(label: "Mileage", leftText: c1.mileage ?? "17–20 kmpl (approx)", rightText: c2.mileage ?? "18–20 kmpl (Petrol, approx)").highlightLeftPill())
        o.append(ComparisonItemModel(label: "Top Speed", leftText: c1.topSpeed ?? "160 km/h (approx)", rightText: c2.topSpeed ?? "160 km/h (approx)").highlightLeftPill())
        list.append(ComparisonSectionModel(title: "Overview", items: o))
        
        // 2. Feel The Drive
        var f: [ComparisonItemModel] = []
        f.append(ComparisonItemModel(label: "Transmission Type", leftText: c1.specifications?.transmission ?? "Manual / AMT / CVT", rightText: c2.specifications?.transmission ?? "Manual / CVT Automatic").highlightRightPill())
        f.append(ComparisonItemModel(label: "Displacement", leftText: c1.specifications?.engine_capacity ?? "999 cc", rightText: c2.specifications?.engine_capacity ?? "1199 cc"))
        f.append(ComparisonItemModel(label: "Fuel Tank Capacity", leftText: c1.specifications?.fuel_tank_capacity ?? "40 Liters", rightText: c2.specifications?.fuel_tank_capacity ?? "35 Liters"))
        f.append(ComparisonItemModel(label: "Seat Height", leftText: c1.specifications?.seat_height ?? "Not Available", rightText: c2.specifications?.seat_height ?? "Not Available").highlightRightPill())
        f.append(ComparisonItemModel(label: "Kerb Weight", leftText: c1.specifications?.kerb_weight ?? "1000 kg (approx)", rightText: c2.specifications?.kerb_weight ?? "980 kg (approx)").highlightRightPill())
        f.append(ComparisonItemModel(label: "Max Power", leftText: c1.detailedSpecifications?.max_power ?? "72–100 bhp (approx)", rightText: c2.detailedSpecifications?.max_power ?? "90 bhp (approx)").highlightRightPill())
        f.append(ComparisonItemModel(label: "Max Torque", leftText: c1.detailedSpecifications?.max_torque ?? "96–160 Nm (approx)", rightText: c2.detailedSpecifications?.max_torque ?? "110 Nm (approx)").highlightRightPill())
        f.append(ComparisonItemModel(label: "Riding Mode", leftText: c1.detailedSpecifications?.riding_mode ?? "City / Highway", rightText: c2.detailedSpecifications?.riding_mode ?? "City / Highway"))
        f.append(ComparisonItemModel(label: "Gear Shifting Pattern", leftText: c1.detailedSpecifications?.gear_shifting_pattern ?? "5-Speed Manual / AMT / CVT", rightText: c2.detailedSpecifications?.gear_shifting_pattern ?? "5-Speed Manual / CVT"))
        list.append(ComparisonSectionModel(title: "Feel The Drive", items: f))
        
        // 3. Dimension & Size (Matching Android lines 360-373 & media_1790937437087.png)
        var d: [ComparisonItemModel] = []
        d.append(ComparisonItemModel(label: "Bootspace", leftText: c1.dimensions?.bootspace ?? "336 Liters", rightText: c2.dimensions?.bootspace ?? "420 Liters").highlightRightPill())
        d.append(ComparisonItemModel(label: "Ground Clearance", leftText: c1.dimensions?.ground_clearance ?? "205 mm", rightText: c2.dimensions?.ground_clearance ?? "170 mm").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Length", leftText: c1.dimensions?.length ?? "3994 mm", rightText: c2.dimensions?.length ?? "3995 mm").highlightRightPill())
        d.append(ComparisonItemModel(label: "Width", leftText: c1.dimensions?.width ?? "1758 mm", rightText: c2.dimensions?.width ?? "1695 mm").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Height", leftText: c1.dimensions?.height ?? "1572 mm", rightText: c2.dimensions?.height ?? "1501 mm").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Central Locking", leftText: c1.features?.central_locking ?? "Keyless", rightText: c2.features?.central_locking ?? "Keyless").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Power Windows", leftText: c1.features?.power_windows ?? "Front & Rear", rightText: c2.features?.power_windows ?? "Front & Rear").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Headrest", leftText: c1.features?.headrest ?? "Front & Rear", rightText: c2.features?.headrest ?? "Front & Rear").highlightLeftPill())
        d.append(ComparisonItemModel(label: "Parking Assist", leftText: c1.features?.parking_assist ?? "Rear Camera + Sensors", rightText: c2.features?.parking_assist ?? "Rear Camera + Sensors").highlightLeftPill())
        list.append(ComparisonSectionModel(title: "Dimension & Size", items: d))
        
        // 4. Interior Features (Matching Android lines 369-383)
        var i: [ComparisonItemModel] = []
        i.append(ComparisonItemModel.bool(label: "Air Conditioner", left: c1.features?.air_conditioner ?? true, right: c2.features?.air_conditioner ?? true))
        i.append(ComparisonItemModel.bool(label: "Cruise Control", left: c1.features?.cruise_control ?? false, right: c2.features?.cruise_control ?? false))
        let musicCount1 = c1.features?.music_system_count != nil ? "\(c1.features!.music_system_count!)" : "1"
        let musicCount2 = c2.features?.music_system_count != nil ? "\(c2.features!.music_system_count!)" : "1"
        i.append(ComparisonItemModel(label: "Integrated (in-dash) Music System", leftText: musicCount1, rightText: musicCount2))
        i.append(ComparisonItemModel(label: "Apple CarPlay", leftText: c1.features?.apple_carplay ?? "Wired", rightText: c2.features?.apple_carplay ?? "Wired"))
        i.append(ComparisonItemModel(label: "Android Auto", leftText: c1.features?.android_auto ?? "Wired", rightText: c2.features?.android_auto ?? "Wired").highlightLeftPill())
        i.append(ComparisonItemModel.bool(label: "Anti-Lock Braking System (ABS)", left: c1.features?.abs ?? true, right: c2.features?.abs ?? true))
        i.append(ComparisonItemModel.bool(label: "Sunroof / Moonroof", left: c1.features?.sunroof ?? false, right: c2.features?.sunroof ?? false))
        i.append(ComparisonItemModel.bool(label: "Anti-Lock Third Row AC", left: c1.features?.third_row_ac ?? false, right: c2.features?.third_row_ac ?? false))
        i.append(ComparisonItemModel(label: "Airbags", leftText: c1.features?.getAirbagsAsString() ?? "Driver, Front Passenger, Side, Curtain", rightText: c2.features?.getAirbagsAsString() ?? "Driver, Front Passenger, Side, Curtain"))
        list.append(ComparisonSectionModel(title: "Interior Features", items: i))
        
        return list
    }
    
    // MARK: - Render Sections
    private func renderSections() {
        // Save current expanded states if available
        var stateMap: [String: Bool] = [:]
        for model in sectionModels {
            stateMap[model.title] = model.expanded
        }
        
        for view in sectionsStackView.arrangedSubviews {
            sectionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        self.sectionModels = buildData()
        
        if sectionModels.isEmpty {
            emptyLabel.isHidden = false
            return
        }
        emptyLabel.isHidden = true
        
        for (index, section) in sectionModels.enumerated() {
            if let saved = stateMap[section.title] {
                section.expanded = saved
            }
            let cardView = makeSectionCard(for: section, at: index)
            sectionsStackView.addArrangedSubview(cardView)
        }
    }
    
    // MARK: - Section Card Factory (Matching Android CardView + Expand/Collapse)
    private func makeSectionCard(for section: ComparisonSectionModel, at index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.layer.borderWidth = 0.6
        card.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Single vertical UIStackView holding header and rows
        // UIStackView automatically shrinks its frame to 0 for hidden subviews!
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.alignment = .fill
        cardStack.distribution = .fill
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        
        // Header
        let headerView = UIView()
        headerView.isUserInteractionEnabled = true
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = section.title
        titleLabel.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        let toggleImageView = UIImageView()
        if let chev = UIImage(systemName: "chevron.down") {
            toggleImageView.image = chev.withRenderingMode(.alwaysTemplate)
        }
        toggleImageView.tintColor = UIColor(red: 198/255.0, green: 168/255.0, blue: 90/255.0, alpha: 1.0) // #C6A85A
        toggleImageView.contentMode = .scaleAspectFit
        toggleImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(toggleImageView)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleImageView.leadingAnchor, constant: -8),
            
            toggleImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            toggleImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            toggleImageView.widthAnchor.constraint(equalToConstant: 18),
            toggleImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // Rows Stack
        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 12
        rowsStack.alignment = .fill
        rowsStack.distribution = .fill
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for item in section.items {
            let row = makeComparisonRow(item: item)
            rowsStack.addArrangedSubview(row)
        }
        
        cardStack.addArrangedSubview(headerView)
        cardStack.addArrangedSubview(rowsStack)
        
        // Pinned to all 4 edges of card with padding
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        rowsStack.isHidden = !section.expanded
        toggleImageView.transform = section.expanded ? .identity : CGAffineTransform(rotationAngle: .pi)
        
        // Tap gesture on entire header layout
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHeaderTapped(_:)))
        headerView.addGestureRecognizer(tap)
        headerView.tag = index
        
        return card
    }
    
    @objc private func onHeaderTapped(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view, headerView.tag < sectionModels.count else { return }
        let index = headerView.tag
        let section = sectionModels[index]
        section.expanded = !section.expanded
        
        guard let cardStack = headerView.superview as? UIStackView,
              let rowsStack = cardStack.arrangedSubviews.first(where: { $0 !== headerView }),
              let toggleImageView = headerView.subviews.compactMap({ $0 as? UIImageView }).first else {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            rowsStack.isHidden = !section.expanded
            toggleImageView.transform = section.expanded ? .identity : CGAffineTransform(rotationAngle: .pi)
            self.contentView.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Row Factory (Matching Android item_row_compare.xml & item_row_boolean.xml)
    private func makeComparisonRow(item: ComparisonItemModel) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .fill
        container.distribution = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Label on top
        let label = UILabel()
        label.text = item.label
        label.font = UIFont(name: "Hind-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        container.addArrangedSubview(label)
        
        // 2. Horizontal row of 2 pills with 10pt space
        let pillsRow = UIStackView()
        pillsRow.axis = .horizontal
        pillsRow.distribution = .fillEqually
        pillsRow.spacing = 10
        pillsRow.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPill = makePillView(text: item.leftText, isHighlighted: item.highlightLeft, isBoolean: item.isBoolean)
        let rightPill = makePillView(text: item.rightText, isHighlighted: item.highlightRight, isBoolean: item.isBoolean)
        
        pillsRow.addArrangedSubview(leftPill)
        pillsRow.addArrangedSubview(rightPill)
        
        let heightConstraint = pillsRow.heightAnchor.constraint(equalToConstant: 38)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        
        container.addArrangedSubview(pillsRow)
        return container
    }
    
    // MARK: - Pill Factory (Matching bg_pill_green & bg_pill_gray)
    private func makePillView(text: String, isHighlighted: Bool, isBoolean: Bool) -> UIView {
        let pill = UIView()
        pill.layer.cornerRadius = 19 // 38 / 2 = capsule
        pill.clipsToBounds = true
        pill.translatesAutoresizingMaskIntoConstraints = false
        
        if isHighlighted {
            // Android bg_pill_green: solid #D8F0DE, stroke 1dp #B7E2C3
            pill.backgroundColor = UIColor(red: 216/255.0, green: 240/255.0, blue: 222/255.0, alpha: 1.0) // #D8F0DE
            pill.layer.borderWidth = 1
            pill.layer.borderColor = UIColor(red: 183/255.0, green: 226/255.0, blue: 195/255.0, alpha: 1.0).cgColor // #B7E2C3
        } else {
            // Android bg_pill_gray: solid #EFEFEF
            pill.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0) // #EFEFEF
            pill.layer.borderWidth = 0
            pill.layer.borderColor = UIColor.clear.cgColor
        }
        
        if isBoolean {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            let isPositive = isHighlighted || text.lowercased() == "true" || text.lowercased() == "yes"
            if isPositive {
                if let checkImg = UIImage(systemName: "checkmark") {
                    iv.image = checkImg.withRenderingMode(.alwaysTemplate)
                }
                iv.tintColor = UIColor(red: 46/255.0, green: 125/255.0, blue: 50/255.0, alpha: 1.0) // #2E7D32
            } else {
                if let crossImg = UIImage(systemName: "xmark") {
                    iv.image = crossImg.withRenderingMode(.alwaysTemplate)
                }
                iv.tintColor = UIColor(red: 198/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1.0) // #C62828
            }
            
            pill.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: pill.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 18),
                iv.heightAnchor.constraint(equalToConstant: 18)
            ])
        } else {
            let label = UILabel()
            label.text = text
            label.font = UIFont(name: "Hind-Regular", size: 12.5) ?? UIFont.systemFont(ofSize: 12.5)
            label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
            label.textAlignment = .center
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.70
            label.translatesAutoresizingMaskIntoConstraints = false
            
            pill.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 6),
                label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -6),
                label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
            ])
        }
        
        return pill
    }
}
