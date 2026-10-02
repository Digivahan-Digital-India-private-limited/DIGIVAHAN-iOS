//
//  OrderQRPageVC.swift
//  DigiVahan
//
//  Created for DigiVahan Order QR Code Review & Checkout.
//

import UIKit

class OrderQRPageVC: BaseViewController {

    // MARK: - Properties
    var vehicleDetails: GarageItemModel?
    var orderType: String = "vehicle"
    var qrFor: String = ""
    
    private var quantity: Int = 2
    private var addressList: [AddressBookModel] = []
    private var selectedAddress: AddressBookModel?

    // MARK: - UI Components - Top Navigation Bar
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
        label.text = "Review your order"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let navDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Scroll & Content View
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Stepper Header
    private let stepperContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 242/255.0, green: 249/255.0, blue: 241/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        if let img = UIImage(named: "splash_logo") {
            iv.image = img
        } else if let appLogo = UIImage(named: "app_logo") {
            iv.image = appLogo
        }
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let step1Circle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12.5
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "1"
        label.font = UIFont(name: "Hind-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    private let stepLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let step2Circle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        view.layer.cornerRadius = 12.5
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "2"
        label.font = UIFont(name: "Hind-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    // MARK: - Product Card (QR & Details)
    private let qrFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 251/255.0, green: 192/255.0, blue: 45/255.0, alpha: 1.0).cgColor // Gold/Yellow border
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let orderMeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 232/255.0, green: 245/255.0, blue: 233/255.0, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 200/255.0, green: 230/255.0, blue: 201/255.0, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Order Me"
        label.font = UIFont(name: "Hind-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 46/255.0, green: 125/255.0, blue: 50/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 1),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        return view
    }()

    private let qrImageView: UIImageView = {
        let iv = UIImageView()
        if let img = UIImage(named: "tempQR") {
            iv.image = img
        } else if let icon = UIImage(named: "white_qr_icon") {
            iv.image = icon
        }
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let vehicleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cancelableLabel: UILabel = {
        let label = UILabel()
        label.text = "Cancelable"
        label.font = UIFont(name: "Hind-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoCircleBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        view.layer.cornerRadius = 9
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "!"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.text = "Qty"
        label.font = UIFont(name: "Hind-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let qtyPillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 254/255.0, green: 247/255.0, blue: 238/255.0, alpha: 1.0)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 230/255.0, green: 220/255.0, blue: 205/255.0, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let qtyValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(white: 0.35, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Seller Bar
    private let sellerDividerTop: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let soldByLabel: UILabel = {
        let label = UILabel()
        label.text = "Sold by : DIGIVAHAN"
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sellerSectionGap: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Delivery Address Card
    private let deliveryTruckIcon: UIImageView = {
        let iv = UIImageView()
        if let icon = UIImage(systemName: "box.truck.fill") {
            iv.image = icon.withTintColor(UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0), renderingMode: .alwaysOriginal)
        } else if let fallback = UIImage(systemName: "shippingbox.fill") {
            iv.image = fallback.withTintColor(UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0), renderingMode: .alwaysOriginal)
        }
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let addressNameLabel: UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.font = UIFont(name: "Hind-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addressDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1.0)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let changeAddressButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Hind-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let addressSectionGap: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Price Details
    private let priceDetailsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Price Details"
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productPriceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Product Price (Free)"
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productPriceValueLabel: UILabel = {
        let label = UILabel()
        let fullText = "+ ₹0 (₹299)"
        let attr = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: "(₹299)") {
            let nsRange = NSRange(range, in: fullText)
            attr.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            attr.addAttribute(.foregroundColor, value: UIColor.gray, range: nsRange)
        }
        label.attributedText = attr
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let deliveryChargeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delivery charge"
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let deliveryChargeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Free"
        label.font = UIFont(name: "Hind-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceDivider1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let orderTotalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Total"
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let orderTotalValueLabel: UILabel = {
        let label = UILabel()
        label.text = "₹0"
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceDivider2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = "Important: After placing this order, any previously generated QR code will be invalid and unusable."
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Bottom Action Button
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        parseReceivedData()
        setupQuantity()
        setupUI()
        setupActions()
        fetchDeliveryAddresses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup Data
    private func parseReceivedData() {
        if let data = receivedData as? [String: Any] {
            if let details = data["vehicleDetails"] as? GarageItemModel {
                self.vehicleDetails = details
            }
            if let type = data["orderType"] as? String {
                self.orderType = type
            }
            if let q = data["qrFor"] as? String {
                self.qrFor = q
            }
        }
    }

    private func setupQuantity() {
        let type = CommonFunctions.getVehicleType(vehicleDetails?.vehicle_class, vehicleDetails?.category)
        if type == .twoWheeler {
            quantity = 1
        } else {
            quantity = 2
        }
        qtyValueLabel.text = "\(quantity)"

        let displayName = vehicleDetails?.makers_model ?? vehicleDetails?.vehicle_name ?? "Order QR"
        vehicleTitleLabel.text = displayName
    }

    // MARK: - UI Layout
    private func setupUI() {
        view.addSubview(topNavBarView)
        topNavBarView.addSubview(backButton)
        topNavBarView.addSubview(navTitleLabel)
        topNavBarView.addSubview(navDividerLine)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Stepper
        contentView.addSubview(stepperContainerView)
        stepperContainerView.addSubview(logoImageView)
        stepperContainerView.addSubview(step1Circle)
        stepperContainerView.addSubview(stepLine)
        stepperContainerView.addSubview(step2Circle)

        // Product
        contentView.addSubview(qrFrameView)
        qrFrameView.addSubview(orderMeBadge)
        qrFrameView.addSubview(qrImageView)

        contentView.addSubview(vehicleTitleLabel)
        contentView.addSubview(cancelableLabel)
        contentView.addSubview(infoCircleBadge)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(qtyPillView)
        qtyPillView.addSubview(qtyValueLabel)

        // Seller
        contentView.addSubview(sellerDividerTop)
        contentView.addSubview(soldByLabel)
        contentView.addSubview(sellerSectionGap)

        // Address
        contentView.addSubview(deliveryTruckIcon)
        contentView.addSubview(addressNameLabel)
        contentView.addSubview(addressDetailLabel)
        contentView.addSubview(changeAddressButton)
        contentView.addSubview(addressSectionGap)

        // Price details
        contentView.addSubview(priceDetailsTitleLabel)
        contentView.addSubview(productPriceTitleLabel)
        contentView.addSubview(productPriceValueLabel)
        contentView.addSubview(deliveryChargeTitleLabel)
        contentView.addSubview(deliveryChargeValueLabel)
        contentView.addSubview(priceDivider1)
        contentView.addSubview(orderTotalTitleLabel)
        contentView.addSubview(orderTotalValueLabel)
        contentView.addSubview(priceDivider2)
        contentView.addSubview(disclaimerLabel)

        contentView.addSubview(continueButton)

        NSLayoutConstraint.activate([
            // Top Nav
            topNavBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topNavBarView.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: topNavBarView.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: topNavBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            navTitleLabel.centerXAnchor.constraint(equalTo: topNavBarView.centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: topNavBarView.centerYAnchor),

            navDividerLine.leadingAnchor.constraint(equalTo: topNavBarView.leadingAnchor),
            navDividerLine.trailingAnchor.constraint(equalTo: topNavBarView.trailingAnchor),
            navDividerLine.bottomAnchor.constraint(equalTo: topNavBarView.bottomAnchor),
            navDividerLine.heightAnchor.constraint(equalToConstant: 0.5),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: topNavBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Stepper
            stepperContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stepperContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepperContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stepperContainerView.heightAnchor.constraint(equalToConstant: 95),

            logoImageView.topAnchor.constraint(equalTo: stepperContainerView.topAnchor, constant: 10),
            logoImageView.centerXAnchor.constraint(equalTo: stepperContainerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 110),
            logoImageView.heightAnchor.constraint(equalToConstant: 38),

            stepLine.centerYAnchor.constraint(equalTo: step1Circle.centerYAnchor),
            stepLine.centerXAnchor.constraint(equalTo: stepperContainerView.centerXAnchor),
            stepLine.widthAnchor.constraint(equalToConstant: 120),
            stepLine.heightAnchor.constraint(equalToConstant: 2),

            step1Circle.trailingAnchor.constraint(equalTo: stepLine.leadingAnchor, constant: 4),
            step1Circle.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            step1Circle.widthAnchor.constraint(equalToConstant: 25),
            step1Circle.heightAnchor.constraint(equalToConstant: 25),

            step2Circle.leadingAnchor.constraint(equalTo: stepLine.trailingAnchor, constant: -4),
            step2Circle.centerYAnchor.constraint(equalTo: step1Circle.centerYAnchor),
            step2Circle.widthAnchor.constraint(equalToConstant: 25),
            step2Circle.heightAnchor.constraint(equalToConstant: 25),

            // Product Section
            qrFrameView.topAnchor.constraint(equalTo: stepperContainerView.bottomAnchor, constant: 16),
            qrFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            qrFrameView.widthAnchor.constraint(equalToConstant: 135),
            qrFrameView.heightAnchor.constraint(equalToConstant: 135),

            orderMeBadge.topAnchor.constraint(equalTo: qrFrameView.topAnchor, constant: 6),
            orderMeBadge.centerXAnchor.constraint(equalTo: qrFrameView.centerXAnchor),

            qrImageView.topAnchor.constraint(equalTo: orderMeBadge.bottomAnchor, constant: 4),
            qrImageView.centerXAnchor.constraint(equalTo: qrFrameView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 100),
            qrImageView.heightAnchor.constraint(equalToConstant: 100),

            vehicleTitleLabel.topAnchor.constraint(equalTo: qrFrameView.topAnchor, constant: 4),
            vehicleTitleLabel.leadingAnchor.constraint(equalTo: qrFrameView.trailingAnchor, constant: 14),
            vehicleTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            cancelableLabel.topAnchor.constraint(equalTo: vehicleTitleLabel.bottomAnchor, constant: 8),
            cancelableLabel.leadingAnchor.constraint(equalTo: vehicleTitleLabel.leadingAnchor),

            infoCircleBadge.leadingAnchor.constraint(equalTo: cancelableLabel.trailingAnchor, constant: 6),
            infoCircleBadge.centerYAnchor.constraint(equalTo: cancelableLabel.centerYAnchor),
            infoCircleBadge.widthAnchor.constraint(equalToConstant: 18),
            infoCircleBadge.heightAnchor.constraint(equalToConstant: 18),

            qtyLabel.topAnchor.constraint(equalTo: cancelableLabel.bottomAnchor, constant: 12),
            qtyLabel.leadingAnchor.constraint(equalTo: vehicleTitleLabel.leadingAnchor),

            qtyPillView.leadingAnchor.constraint(equalTo: qtyLabel.trailingAnchor, constant: 12),
            qtyPillView.centerYAnchor.constraint(equalTo: qtyLabel.centerYAnchor),
            qtyPillView.widthAnchor.constraint(equalToConstant: 80),
            qtyPillView.heightAnchor.constraint(equalToConstant: 28),

            qtyValueLabel.centerXAnchor.constraint(equalTo: qtyPillView.centerXAnchor),
            qtyValueLabel.centerYAnchor.constraint(equalTo: qtyPillView.centerYAnchor),

            // Seller
            sellerDividerTop.topAnchor.constraint(equalTo: qrFrameView.bottomAnchor, constant: 16),
            sellerDividerTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sellerDividerTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sellerDividerTop.heightAnchor.constraint(equalToConstant: 1),

            soldByLabel.topAnchor.constraint(equalTo: sellerDividerTop.bottomAnchor, constant: 10),
            soldByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            soldByLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            sellerSectionGap.topAnchor.constraint(equalTo: soldByLabel.bottomAnchor, constant: 10),
            sellerSectionGap.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sellerSectionGap.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sellerSectionGap.heightAnchor.constraint(equalToConstant: 6),

            // Delivery Address
            deliveryTruckIcon.topAnchor.constraint(equalTo: sellerSectionGap.bottomAnchor, constant: 14),
            deliveryTruckIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deliveryTruckIcon.widthAnchor.constraint(equalToConstant: 24),
            deliveryTruckIcon.heightAnchor.constraint(equalToConstant: 24),

            addressNameLabel.topAnchor.constraint(equalTo: sellerSectionGap.bottomAnchor, constant: 14),
            addressNameLabel.leadingAnchor.constraint(equalTo: deliveryTruckIcon.trailingAnchor, constant: 10),
            addressNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: changeAddressButton.leadingAnchor, constant: -8),

            addressDetailLabel.topAnchor.constraint(equalTo: addressNameLabel.bottomAnchor, constant: 4),
            addressDetailLabel.leadingAnchor.constraint(equalTo: addressNameLabel.leadingAnchor),
            addressDetailLabel.trailingAnchor.constraint(lessThanOrEqualTo: changeAddressButton.leadingAnchor, constant: -8),

            changeAddressButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            changeAddressButton.centerYAnchor.constraint(equalTo: deliveryTruckIcon.centerYAnchor, constant: 10),
            changeAddressButton.heightAnchor.constraint(equalToConstant: 28),

            addressSectionGap.topAnchor.constraint(equalTo: addressDetailLabel.bottomAnchor, constant: 14),
            addressSectionGap.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addressSectionGap.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addressSectionGap.heightAnchor.constraint(equalToConstant: 6),

            // Price Details
            priceDetailsTitleLabel.topAnchor.constraint(equalTo: addressSectionGap.bottomAnchor, constant: 14),
            priceDetailsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            productPriceTitleLabel.topAnchor.constraint(equalTo: priceDetailsTitleLabel.bottomAnchor, constant: 10),
            productPriceTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            productPriceValueLabel.centerYAnchor.constraint(equalTo: productPriceTitleLabel.centerYAnchor),
            productPriceValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            deliveryChargeTitleLabel.topAnchor.constraint(equalTo: productPriceTitleLabel.bottomAnchor, constant: 10),
            deliveryChargeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deliveryChargeValueLabel.centerYAnchor.constraint(equalTo: deliveryChargeTitleLabel.centerYAnchor),
            deliveryChargeValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            priceDivider1.topAnchor.constraint(equalTo: deliveryChargeTitleLabel.bottomAnchor, constant: 12),
            priceDivider1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceDivider1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceDivider1.heightAnchor.constraint(equalToConstant: 1),

            orderTotalTitleLabel.topAnchor.constraint(equalTo: priceDivider1.bottomAnchor, constant: 12),
            orderTotalTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            orderTotalValueLabel.centerYAnchor.constraint(equalTo: orderTotalTitleLabel.centerYAnchor),
            orderTotalValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            priceDivider2.topAnchor.constraint(equalTo: orderTotalTitleLabel.bottomAnchor, constant: 12),
            priceDivider2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceDivider2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceDivider2.heightAnchor.constraint(equalToConstant: 1),

            disclaimerLabel.topAnchor.constraint(equalTo: priceDivider2.bottomAnchor, constant: 14),
            disclaimerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            disclaimerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Continue Button
            continueButton.topAnchor.constraint(equalTo: disclaimerLabel.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - Actions & Wiring
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        changeAddressButton.addTarget(self, action: #selector(changeAddressTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func changeAddressTapped() {
        showAddressBottomSheet()
    }

    @objc private func continueButtonTapped() {
        guard let address = selectedAddress else {
            showToast(message: "Please select delivery address")
            showAddressBottomSheet()
            return
        }

        let alert = UIAlertController(
            title: "Confirm Order",
            message: "Place order for \(vehicleTitleLabel.text ?? "Vehicle") (Qty: \(quantity)) to \(address.name ?? "selected address")?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Place Order", style: .default, handler: { [weak self] _ in
            self?.placeOrder()
        }))
        present(alert, animated: true)
    }

    private func placeOrder() {
        LoadingManager.shared.show(on: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            LoadingManager.shared.hide()
            self.showSuccessAlert()
        }
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Order Placed Successfully",
            message: "Your QR code order for \(vehicleTitleLabel.text ?? "") has been placed. You can track it under My Orders in your profile.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }

    // MARK: - Fetch Saved Delivery Addresses
    private func fetchDeliveryAddresses() {
        let userId = PreferenceManager.shared.getUserId()
        guard !userId.isEmpty else { return }

        let params: [String: Any] = [
            "user_id": userId,
            "details_type": "address_book"
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, _ in
            guard let self = self else { return }

            if status, let response = response, let dataArray = response["data"] as? [[String: Any]] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dataArray)
                    let list = try JSONDecoder().decode([AddressBookModel].self, from: jsonData)
                    self.addressList = list

                    if let defaultAddr = list.first(where: { $0.default_status == true }) ?? list.first {
                        self.selectAddress(defaultAddr)
                    }
                } catch {
                    print("Error decoding address book:", error)
                }
            }
        }
    }

    private func selectAddress(_ address: AddressBookModel) {
        self.selectedAddress = address
        addressNameLabel.text = "\(address.name ?? "") \(address.contact_no ?? "")".trimmingCharacters(in: .whitespaces)
        addressDetailLabel.text = address.formattedAddress.isEmpty ? "N/A" : address.formattedAddress
    }

    // MARK: - Address Bottom Sheet & Add Address Dialog
    private func showAddressBottomSheet() {
        let actionSheet = UIAlertController(
            title: "Select Delivery Address",
            message: addressList.isEmpty ? "No saved address found. Add a new delivery address to proceed." : "Choose your delivery address",
            preferredStyle: .actionSheet
        )

        for addr in addressList {
            let label = "\(addr.name ?? "") - \(addr.formattedAddress)"
            let isCurrent = (addr._id != nil && addr._id == selectedAddress?._id)
            let checkmark = isCurrent ? "✓ " : ""
            actionSheet.addAction(UIAlertAction(title: "\(checkmark)\(label)", style: .default, handler: { [weak self] _ in
                self?.selectAddress(addr)
            }))
        }

        actionSheet.addAction(UIAlertAction(title: "+ Add New Address", style: .default, handler: { [weak self] _ in
            self?.showAddAddressDialog()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = changeAddressButton
            popover.sourceRect = changeAddressButton.bounds
        }

        present(actionSheet, animated: true)
    }

    private func showAddAddressDialog() {
        let alert = UIAlertController(
            title: "Add Delivery Address",
            message: "Enter your complete shipping address details",
            preferredStyle: .alert
        )

        alert.addTextField { tf in tf.placeholder = "Full Name" }
        alert.addTextField { tf in tf.placeholder = "Contact Number"; tf.keyboardType = .phonePad }
        alert.addTextField { tf in tf.placeholder = "House / Flat / Building No." }
        alert.addTextField { tf in tf.placeholder = "Road / Area / Street" }
        alert.addTextField { tf in tf.placeholder = "City" }
        alert.addTextField { tf in tf.placeholder = "State" }
        alert.addTextField { tf in tf.placeholder = "Pincode"; tf.keyboardType = .numberPad }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save Address", style: .default, handler: { [weak self, weak alert] _ in
            guard let self = self, let tfs = alert?.textFields else { return }
            let name = tfs[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let phone = tfs[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let house = tfs[2].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let area = tfs[3].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let city = tfs[4].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let state = tfs[5].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let pincode = tfs[6].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            guard !name.isEmpty, !phone.isEmpty, !pincode.isEmpty else {
                self.showToast(message: "Please fill Name, Phone and Pincode")
                return
            }

            self.saveNewAddress(name: name, phone: phone, house: house, area: area, city: city, state: state, pincode: pincode)
        }))

        present(alert, animated: true)
    }

    private func saveNewAddress(
        name: String,
        phone: String,
        house: String,
        area: String,
        city: String,
        state: String,
        pincode: String
    ) {
        let userId = PreferenceManager.shared.getUserId()
        let params: [String: Any] = [
            "user_id": userId,
            "name": name,
            "contact_no": phone,
            "house_no_building": house,
            "street_name": area,
            "road_or_area": area,
            "landmark": "",
            "city": city,
            "state": state,
            "pincode": pincode,
            "default_status": true
        ]

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.ADD_USER_ADDRESS,
            method: "POST",
            parameters: params
        ) { [weak self] _, status, _ in
            guard let self = self else { return }
            LoadingManager.shared.hide()

            let newModel = AddressBookModel(
                _id: UUID().uuidString,
                name: name,
                contact_no: phone,
                house_no_building: house,
                street_name: area,
                landmark: "",
                road_or_area: area,
                city: city,
                state: state,
                pincode: pincode,
                default_status: true
            )
            self.addressList.insert(newModel, at: 0)
            self.selectAddress(newModel)
            self.showToast(message: status ? "Address saved successfully" : "Address selected")
        }
    }
}
