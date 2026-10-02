//
//  TrendingCarDetailsVC.swift
//  DigiVahan
//
//  Created for DigiVahan Trending Car Details screen.
//

import UIKit
import SDWebImage

class TrendingCarDetailsVC: BaseViewController {
    
    // MARK: - Properties
    var carModel: TrendingCarsModel?
    private var imageList: [String] = []
    private var slideTimer: Timer?
    private var currentImageIndex: Int = 0
    
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
        label.text = "Trending Car"
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
    
    // MARK: - Hero Section (Gradient & Slider)
    private class HeroGradientView: UIView {
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
            // Gradient matching bg_card2 in Android: top white fading to #36B72E at bottom
            gradientLayer.colors = [
                UIColor.white.cgColor,
                UIColor(red: 215/255.0, green: 245/255.0, blue: 213/255.0, alpha: 1.0).cgColor,
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
    
    private let heroContainerView: HeroGradientView = {
        let view = HeroGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.clipsToBounds = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let imageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = UIColor(red: 35/255.0, green: 130/255.0, blue: 30/255.0, alpha: 1.0)
        pc.pageIndicatorTintColor = UIColor(red: 180/255.0, green: 220/255.0, blue: 175/255.0, alpha: 0.9)
        pc.hidesForSinglePage = false
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    // MARK: - Card 1: Price & Info
    private let priceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exShowroomLabel: UILabel = {
        let label = UILabel()
        label.text = "ex. showroom price"
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 100/255.0, green: 105/255.0, blue: 110/255.0, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verticalDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.88, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let brandNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let modelNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let carTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let carMileageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let carTopSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Card 2: Specifications
    private let specsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let specsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Specifications"
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let engineCapacityBadge = BadgeView()
    private let transmissionBadge = BadgeView()
    private let fuelTankBadge = BadgeView()
    
    // MARK: - Card 3: Detailed Specifications
    private let detailedSpecsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailedSpecsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Detailed Specifications"
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxPowerBadge = BadgeView()
    private let maxTorqueBadge = BadgeView()
    private let ridingModeBadge = BadgeView()
    private let seatHeightBadge = BadgeView()
    private let kerbWeightBadge = BadgeView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigation()
        setupScrollView()
        setupHeroSection()
        setupPriceCard()
        setupSpecsCard()
        setupDetailedSpecsCard()
        
        populateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startAutoSlideTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoSlideTimer()
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
    
    // MARK: - Hero Section Setup
    private func setupHeroSection() {
        contentView.addSubview(heroContainerView)
        heroContainerView.addSubview(imageScrollView)
        imageScrollView.addSubview(imageStackView)
        heroContainerView.addSubview(pageControl)
        
        imageScrollView.delegate = self
        
        NSLayoutConstraint.activate([
            heroContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroContainerView.heightAnchor.constraint(equalToConstant: 240),
            
            imageScrollView.topAnchor.constraint(equalTo: heroContainerView.topAnchor, constant: 8),
            imageScrollView.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: 195),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.trailingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.bottomAnchor),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.heightAnchor),
            
            pageControl.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 0),
            pageControl.centerXAnchor.constraint(equalTo: heroContainerView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    // MARK: - Price Card Setup
    private func setupPriceCard() {
        contentView.addSubview(priceCardView)
        
        let topRow = UIStackView(arrangedSubviews: [carPriceLabel, exShowroomLabel])
        topRow.axis = .horizontal
        topRow.distribution = .fill
        topRow.alignment = .center
        topRow.translatesAutoresizingMaskIntoConstraints = false
        priceCardView.addSubview(topRow)
        
        priceCardView.addSubview(verticalDividerLine)
        
        let leftCol = UIStackView(arrangedSubviews: [brandNameLabel, modelNameLabel, carTypeLabel])
        leftCol.axis = .vertical
        leftCol.spacing = 3
        leftCol.alignment = .leading
        leftCol.translatesAutoresizingMaskIntoConstraints = false
        priceCardView.addSubview(leftCol)
        
        let rightCol = UIStackView(arrangedSubviews: [carMileageLabel, carTopSpeedLabel])
        rightCol.axis = .vertical
        rightCol.spacing = 3
        rightCol.alignment = .leading
        rightCol.translatesAutoresizingMaskIntoConstraints = false
        priceCardView.addSubview(rightCol)
        
        NSLayoutConstraint.activate([
            priceCardView.topAnchor.constraint(equalTo: heroContainerView.bottomAnchor, constant: 12),
            priceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topRow.topAnchor.constraint(equalTo: priceCardView.topAnchor, constant: 12),
            topRow.leadingAnchor.constraint(equalTo: priceCardView.leadingAnchor, constant: 12),
            topRow.trailingAnchor.constraint(equalTo: priceCardView.trailingAnchor, constant: -12),
            
            verticalDividerLine.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 8),
            verticalDividerLine.centerXAnchor.constraint(equalTo: priceCardView.centerXAnchor, constant: 10),
            verticalDividerLine.widthAnchor.constraint(equalToConstant: 1),
            verticalDividerLine.bottomAnchor.constraint(equalTo: priceCardView.bottomAnchor, constant: -12),
            
            leftCol.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 8),
            leftCol.leadingAnchor.constraint(equalTo: priceCardView.leadingAnchor, constant: 12),
            leftCol.trailingAnchor.constraint(equalTo: verticalDividerLine.leadingAnchor, constant: -8),
            leftCol.bottomAnchor.constraint(lessThanOrEqualTo: priceCardView.bottomAnchor, constant: -12),
            
            rightCol.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 8),
            rightCol.leadingAnchor.constraint(equalTo: verticalDividerLine.trailingAnchor, constant: 8),
            rightCol.trailingAnchor.constraint(equalTo: priceCardView.trailingAnchor, constant: -12),
            rightCol.bottomAnchor.constraint(lessThanOrEqualTo: priceCardView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Specs Card Setup
    private func setupSpecsCard() {
        contentView.addSubview(specsCardView)
        specsCardView.addSubview(specsTitleLabel)
        
        let row1 = makeSpecRow(title: "Engine Capacity", badge: engineCapacityBadge)
        let row2 = makeSpecRow(title: "Transmission", badge: transmissionBadge)
        let row3 = makeSpecRow(title: "Fuel Tank capacity", badge: fuelTankBadge)
        
        let rowsStack = UIStackView(arrangedSubviews: [row1, row2, row3])
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        specsCardView.addSubview(rowsStack)
        
        NSLayoutConstraint.activate([
            specsCardView.topAnchor.constraint(equalTo: priceCardView.bottomAnchor, constant: 16),
            specsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            specsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            specsTitleLabel.topAnchor.constraint(equalTo: specsCardView.topAnchor, constant: 12),
            specsTitleLabel.leadingAnchor.constraint(equalTo: specsCardView.leadingAnchor, constant: 12),
            specsTitleLabel.trailingAnchor.constraint(equalTo: specsCardView.trailingAnchor, constant: -12),
            
            rowsStack.topAnchor.constraint(equalTo: specsTitleLabel.bottomAnchor, constant: 10),
            rowsStack.leadingAnchor.constraint(equalTo: specsCardView.leadingAnchor, constant: 12),
            rowsStack.trailingAnchor.constraint(equalTo: specsCardView.trailingAnchor, constant: -12),
            rowsStack.bottomAnchor.constraint(equalTo: specsCardView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Detailed Specs Card Setup
    private func setupDetailedSpecsCard() {
        contentView.addSubview(detailedSpecsCardView)
        detailedSpecsCardView.addSubview(detailedSpecsTitleLabel)
        
        let row1 = makeSpecRow(title: "Max Power", badge: maxPowerBadge)
        let row2 = makeSpecRow(title: "Max Torque", badge: maxTorqueBadge)
        let row3 = makeSpecRow(title: "Riding Mode", badge: ridingModeBadge)
        let row4 = makeSpecRow(title: "Seat Height", badge: seatHeightBadge)
        let row5 = makeSpecRow(title: "Kerb Weight", badge: kerbWeightBadge)
        
        let rowsStack = UIStackView(arrangedSubviews: [row1, row2, row3, row4, row5])
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        detailedSpecsCardView.addSubview(rowsStack)
        
        NSLayoutConstraint.activate([
            detailedSpecsCardView.topAnchor.constraint(equalTo: specsCardView.bottomAnchor, constant: 16),
            detailedSpecsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailedSpecsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailedSpecsCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            detailedSpecsTitleLabel.topAnchor.constraint(equalTo: detailedSpecsCardView.topAnchor, constant: 12),
            detailedSpecsTitleLabel.leadingAnchor.constraint(equalTo: detailedSpecsCardView.leadingAnchor, constant: 12),
            detailedSpecsTitleLabel.trailingAnchor.constraint(equalTo: detailedSpecsCardView.trailingAnchor, constant: -12),
            
            rowsStack.topAnchor.constraint(equalTo: detailedSpecsTitleLabel.bottomAnchor, constant: 10),
            rowsStack.leadingAnchor.constraint(equalTo: detailedSpecsCardView.leadingAnchor, constant: 12),
            rowsStack.trailingAnchor.constraint(equalTo: detailedSpecsCardView.trailingAnchor, constant: -12),
            rowsStack.bottomAnchor.constraint(equalTo: detailedSpecsCardView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Spec Row Helper
    private func makeSpecRow(title: String, badge: BadgeView) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLabel)
        row.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: badge.leadingAnchor, constant: -8),
            
            badge.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            badge.topAnchor.constraint(equalTo: row.topAnchor),
            badge.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            badge.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.52),
            badge.heightAnchor.constraint(equalToConstant: 34),
            
            row.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return row
    }
    
    // MARK: - Populate Data
    private func populateData() {
        guard let car = carModel else { return }
        
        // 1. Images
        imageList.removeAll()
        if let rawUrls = car.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !rawUrls.isEmpty {
            let splitUrls = rawUrls.components(separatedBy: ",")
            for u in splitUrls {
                let trimmed = u.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    imageList.append(trimmed)
                }
            }
        }
        
        setupImageSlider()
        
        // 2. Price
        var priceText = car.priceDisplay?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if priceText.isEmpty, let price = car.price, price > 0 {
            if price >= 10000000 {
                priceText = String(format: "₹%.2f Crore", price / 10000000)
            } else if price >= 100000 {
                priceText = String(format: "₹%.2f Lakh", price / 100000)
            } else {
                priceText = String(format: "₹%.0f", price)
            }
        }
        if !priceText.isEmpty && !priceText.lowercased().contains("onwards") {
            priceText = "\(priceText) onwards"
        }
        carPriceLabel.text = priceText
        
        // 3. Info labels
        brandNameLabel.text = "Brand Name : " + safeValue(car.brandName)
        modelNameLabel.text = "Model Name : " + safeValue(car.modelName)
        carTypeLabel.text = "Type : " + safeValue(car.type)
        
        carMileageLabel.text = "Mileage : " + safeValue(car.mileage)
        carTopSpeedLabel.text = "Top Speed : " + safeValue(car.topSpeed)
        
        // 4. Specifications
        let specs = car.specifications
        engineCapacityBadge.setText(safeValue(specs?.engine_capacity))
        transmissionBadge.setText(safeValue(specs?.transmission))
        fuelTankBadge.setText(safeValue(specs?.fuel_tank_capacity))
        
        // 5. Detailed Specifications
        let detailedSpecs = car.detailedSpecifications
        maxPowerBadge.setText(safeValue(detailedSpecs?.max_power))
        maxTorqueBadge.setText(safeValue(detailedSpecs?.max_torque))
        ridingModeBadge.setText(safeValue(detailedSpecs?.riding_mode))
        
        let seatHeightVal = specs?.seat_height?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let seatHeightVal = seatHeightVal, !seatHeightVal.isEmpty, seatHeightVal.lowercased() != "n/a", seatHeightVal.lowercased() != "na" {
            seatHeightBadge.setText(seatHeightVal)
        } else {
            seatHeightBadge.setText("Not Available")
        }
        
        kerbWeightBadge.setText(safeValue(specs?.kerb_weight))
    }
    
    private func safeValue(_ value: String?) -> String {
        guard let val = value?.trimmingCharacters(in: .whitespacesAndNewlines), !val.isEmpty else {
            return "N/A"
        }
        return val
    }
    
    // MARK: - Image Slider Setup
    private func setupImageSlider() {
        for subview in imageStackView.arrangedSubviews {
            imageStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        if imageList.isEmpty {
            let iv = makeCarImageView(url: nil)
            imageStackView.addArrangedSubview(iv)
            iv.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor).isActive = true
            pageControl.numberOfPages = 1
            pageControl.isHidden = true
            return
        }
        
        for urlStr in imageList {
            let iv = makeCarImageView(url: urlStr)
            imageStackView.addArrangedSubview(iv)
            iv.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
        
        pageControl.numberOfPages = imageList.count
        pageControl.currentPage = 0
        pageControl.isHidden = imageList.count <= 1
    }
    
    private func makeCarImageView(url: String?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)
        
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iv.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            iv.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            iv.heightAnchor.constraint(equalToConstant: 185)
        ])
        
        if let urlStr = url, let imgUrl = URL(string: urlStr) {
            iv.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: "ic_vehicle_default"))
        } else {
            iv.image = UIImage(named: "ic_vehicle_default")
        }
        
        return container
    }
    
    // MARK: - Auto Slide Timer
    private func startAutoSlideTimer() {
        stopAutoSlideTimer()
        guard imageList.count > 1 else { return }
        slideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.advanceSlide()
        }
    }
    
    private func stopAutoSlideTimer() {
        slideTimer?.invalidate()
        slideTimer = nil
    }
    
    private func advanceSlide() {
        guard imageList.count > 1 else { return }
        let nextIndex = (currentImageIndex + 1) % imageList.count
        let offset = CGFloat(nextIndex) * imageScrollView.bounds.width
        imageScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        currentImageIndex = nextIndex
        pageControl.currentPage = nextIndex
    }
}

// MARK: - UIScrollViewDelegate
extension TrendingCarDetailsVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imageScrollView {
            let pageWidth = scrollView.bounds.width
            guard pageWidth > 0 else { return }
            let page = Int(round(scrollView.contentOffset.x / pageWidth))
            currentImageIndex = page
            pageControl.currentPage = page
        }
    }
}

// MARK: - Badge View for Specification Values
private class BadgeView: UIView {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0) // #F2F2F2
        layer.cornerRadius = 8
        clipsToBounds = true
        
        label.font = UIFont(name: "Hind-Regular", size: 13.5) ?? UIFont.systemFont(ofSize: 13.5)
        label.textColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 46/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: borderRightConstraint)
        ])
    }
    
    private var borderRightConstraint: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        return trailingAnchor
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}
