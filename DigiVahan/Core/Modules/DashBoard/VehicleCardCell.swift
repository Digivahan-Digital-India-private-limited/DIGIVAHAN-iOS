//
//  VehicleCardCell.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Garage Vehicle Cards Carousel.
//

import UIKit

// MARK: - Vehicle Card Inner Layout (Gradient-Backed)
/// Custom view whose backing layer is a CAGradientLayer, ensuring the expired alert gradient
/// is always 100% synchronized with Auto Layout bounds and never zero-sized or misplaced.
class VehicleCardInnerLayout: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    func applyExpiredStyle() {
        // Red border #FF8282 (stork_color in Android, 2dp)
        layer.cornerRadius = 8
        layer.borderWidth = 1.8
        layer.borderColor = UIColor(red: 255/255, green: 130/255, blue: 130/255, alpha: 1.0).cgColor
        
        // Multi-stop gradient matching Android puc_expired_background.xml & design screenshot
        // Top: #E79898 (soft pink/red) -> Mid: #F5DCDA -> Bottom: #FDFBFB (clean off-white)
        gradientLayer.colors = [
            UIColor(red: 231/255, green: 152/255, blue: 152/255, alpha: 1.0).cgColor,
            UIColor(red: 245/255, green: 220/255, blue: 218/255, alpha: 1.0).cgColor,
            UIColor(red: 253/255, green: 251/255, blue: 251/255, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.45, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    func applyNormalStyle() {
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        gradientLayer.colors = nil
        backgroundColor = .clear
    }
}

class VehicleCardCell: UICollectionViewCell {
    static let identifier = "VehicleCardCell"
    
    // MARK: - UI Components
    
    /// Shadow container (renders outer card shadow)
    let shadowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Card container (rounded 12dp matching Android cardCornerRadius)
    let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bgImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bg_card5") ?? UIImage(named: "bg_card4")
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Horizontal Layout inside card container (10dp padding)
    let mainCardLayout: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Left Column (Vehicle Image + Number Plate)
    
    let leftContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let ivCar: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let numberPlateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let numberPlateBgImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "number_plate_bg")
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let tvCarNo: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Right Column (cardLayout)
    
    /// The entire right-side container box.
    /// When normal: transparent, no border.
    /// When expired: bordered box with pink border (#FF8282) and soft gradient background (#E79898 -> #FBFBFB).
    let cardLayout: VehicleCardInnerLayout = {
        let view = VehicleCardInnerLayout()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 1. Normal State: Car Details Layout
    
    let carDetailsLayout: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let carDetailsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 1.5
        sv.alignment = .leading
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let tvCarOwner: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 14.5) ?? UIFont.boldSystemFont(ofSize: 14.5)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tvCarMaker: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 11.5) ?? UIFont.systemFont(ofSize: 11.5)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tvCarModel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 11.5) ?? UIFont.systemFont(ofSize: 11.5)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tvRegistrationDate: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 8.5) ?? UIFont.systemFont(ofSize: 8.5)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 2. Expired State: PUC & Insurance Expiry Layout
    
    let pucInsuranceExpiryLayout: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let ivExpiryWarning: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "read_light_icon")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let expiryContentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 3
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // PUC Layout
    let pucLayout: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let tvPucTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor(red: 239/255, green: 59/255, blue: 59/255, alpha: 1.0) // #ef3b3b
        label.text = "PUC EXPIRED"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tvPucDate: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Insurance Layout
    let insuranceLayout: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 1
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let tvInsuranceTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 11.5) ?? UIFont.boldSystemFont(ofSize: 11.5)
        label.textColor = UIColor(red: 239/255, green: 59/255, blue: 59/255, alpha: 1.0) // #ef3b3b
        label.text = "INSURANCE EXPIRED"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tvInsuranceDate: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Details Button (carCardBtn)
    
    let carCardBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0) // #36b72e
        button.setTitle("View Details", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onViewDetailsTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(shadowContainerView)
        shadowContainerView.addSubview(cardContainerView)
        
        cardContainerView.addSubview(bgImageView)
        cardContainerView.addSubview(mainCardLayout)
        
        // Split into Left Column and Right Column (cardLayout)
        mainCardLayout.addSubview(leftContainerView)
        mainCardLayout.addSubview(cardLayout)
        
        // Left Column Subviews
        leftContainerView.addSubview(ivCar)
        leftContainerView.addSubview(numberPlateView)
        numberPlateView.addSubview(numberPlateBgImageView)
        numberPlateView.addSubview(tvCarNo)
        
        // Right Column: Normal Details
        cardLayout.addSubview(carDetailsLayout)
        carDetailsLayout.addSubview(carDetailsStackView)
        carDetailsStackView.addArrangedSubview(tvCarOwner)
        carDetailsStackView.addArrangedSubview(tvCarMaker)
        carDetailsStackView.addArrangedSubview(tvCarModel)
        carDetailsStackView.addArrangedSubview(tvRegistrationDate)
        
        // Right Column: Expired Layout
        cardLayout.addSubview(pucInsuranceExpiryLayout)
        pucInsuranceExpiryLayout.addSubview(ivExpiryWarning)
        pucInsuranceExpiryLayout.addSubview(expiryContentStackView)
        
        expiryContentStackView.addArrangedSubview(pucLayout)
        pucLayout.addArrangedSubview(tvPucTitle)
        pucLayout.addArrangedSubview(tvPucDate)
        
        expiryContentStackView.addArrangedSubview(insuranceLayout)
        insuranceLayout.addArrangedSubview(tvInsuranceTitle)
        insuranceLayout.addArrangedSubview(tvInsuranceDate)
        
        // Right Column: View Details Button (carCardBtn)
        cardLayout.addSubview(carCardBtn)
        
        // Action Handlers
        carCardBtn.addTarget(self, action: #selector(detailsPressed), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(detailsPressed))
        cardContainerView.addGestureRecognizer(tap)
        cardContainerView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            // Outer shadow / card container pinned to contentView
            shadowContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            shadowContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            shadowContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shadowContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            cardContainerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            
            // Background Image
            bgImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            
            // MainCardLayout inside padding (10pt)
            mainCardLayout.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 10),
            mainCardLayout.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -10),
            mainCardLayout.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 10),
            mainCardLayout.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -10),
            
            // Left Container (~124pt width)
            leftContainerView.leadingAnchor.constraint(equalTo: mainCardLayout.leadingAnchor),
            leftContainerView.topAnchor.constraint(equalTo: mainCardLayout.topAnchor),
            leftContainerView.bottomAnchor.constraint(equalTo: mainCardLayout.bottomAnchor),
            leftContainerView.widthAnchor.constraint(equalToConstant: 124),
            
            // Vehicle Image (110 x 66)
            ivCar.topAnchor.constraint(equalTo: leftContainerView.topAnchor, constant: 6),
            ivCar.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor),
            ivCar.widthAnchor.constraint(equalToConstant: 110),
            ivCar.heightAnchor.constraint(equalToConstant: 66),
            
            // Number Plate (120 x 25)
            numberPlateView.topAnchor.constraint(equalTo: ivCar.bottomAnchor, constant: 6),
            numberPlateView.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor),
            numberPlateView.widthAnchor.constraint(equalToConstant: 120),
            numberPlateView.heightAnchor.constraint(equalToConstant: 25),
            
            numberPlateBgImageView.topAnchor.constraint(equalTo: numberPlateView.topAnchor),
            numberPlateBgImageView.bottomAnchor.constraint(equalTo: numberPlateView.bottomAnchor),
            numberPlateBgImageView.leadingAnchor.constraint(equalTo: numberPlateView.leadingAnchor),
            numberPlateBgImageView.trailingAnchor.constraint(equalTo: numberPlateView.trailingAnchor),
            
            // Plate text offset from IND flag
            tvCarNo.centerYAnchor.constraint(equalTo: numberPlateView.centerYAnchor),
            tvCarNo.leadingAnchor.constraint(equalTo: numberPlateView.leadingAnchor, constant: 18),
            tvCarNo.trailingAnchor.constraint(equalTo: numberPlateView.trailingAnchor, constant: -4),
            
            // Right Container (cardLayout)
            cardLayout.leadingAnchor.constraint(equalTo: leftContainerView.trailingAnchor, constant: 8),
            cardLayout.trailingAnchor.constraint(equalTo: mainCardLayout.trailingAnchor),
            cardLayout.topAnchor.constraint(equalTo: mainCardLayout.topAnchor),
            cardLayout.bottomAnchor.constraint(equalTo: mainCardLayout.bottomAnchor),
            
            // 1. Normal State: carDetailsLayout
            carDetailsLayout.leadingAnchor.constraint(equalTo: cardLayout.leadingAnchor, constant: 4),
            carDetailsLayout.trailingAnchor.constraint(equalTo: cardLayout.trailingAnchor, constant: -4),
            carDetailsLayout.topAnchor.constraint(greaterThanOrEqualTo: cardLayout.topAnchor, constant: 2),
            carDetailsLayout.bottomAnchor.constraint(lessThanOrEqualTo: carCardBtn.topAnchor, constant: -4),
            carDetailsLayout.centerYAnchor.constraint(equalTo: cardLayout.centerYAnchor, constant: -16),
            
            carDetailsStackView.topAnchor.constraint(equalTo: carDetailsLayout.topAnchor),
            carDetailsStackView.bottomAnchor.constraint(equalTo: carDetailsLayout.bottomAnchor),
            carDetailsStackView.leadingAnchor.constraint(equalTo: carDetailsLayout.leadingAnchor),
            carDetailsStackView.trailingAnchor.constraint(equalTo: carDetailsLayout.trailingAnchor),
            
            // 2. Expired State: pucInsuranceExpiryLayout (Centered horizontally and vertically above button)
            pucInsuranceExpiryLayout.centerXAnchor.constraint(equalTo: cardLayout.centerXAnchor),
            pucInsuranceExpiryLayout.centerYAnchor.constraint(equalTo: cardLayout.centerYAnchor, constant: -16),
            pucInsuranceExpiryLayout.topAnchor.constraint(greaterThanOrEqualTo: cardLayout.topAnchor, constant: 2),
            pucInsuranceExpiryLayout.bottomAnchor.constraint(lessThanOrEqualTo: carCardBtn.topAnchor, constant: -4),
            pucInsuranceExpiryLayout.leadingAnchor.constraint(greaterThanOrEqualTo: cardLayout.leadingAnchor, constant: 4),
            pucInsuranceExpiryLayout.trailingAnchor.constraint(lessThanOrEqualTo: cardLayout.trailingAnchor, constant: -4),
            
            // Warning Siren Light (28x28, vertically centered with text stack)
            ivExpiryWarning.leadingAnchor.constraint(equalTo: pucInsuranceExpiryLayout.leadingAnchor),
            ivExpiryWarning.centerYAnchor.constraint(equalTo: expiryContentStackView.centerYAnchor),
            ivExpiryWarning.widthAnchor.constraint(equalToConstant: 28),
            ivExpiryWarning.heightAnchor.constraint(equalToConstant: 28),
            
            // Expiry Text Stack
            expiryContentStackView.leadingAnchor.constraint(equalTo: ivExpiryWarning.trailingAnchor, constant: 8),
            expiryContentStackView.trailingAnchor.constraint(equalTo: pucInsuranceExpiryLayout.trailingAnchor),
            expiryContentStackView.topAnchor.constraint(equalTo: pucInsuranceExpiryLayout.topAnchor),
            expiryContentStackView.bottomAnchor.constraint(equalTo: pucInsuranceExpiryLayout.bottomAnchor),
            
            // View Details Button (carCardBtn) - centered horizontally at bottom of cardLayout
            carCardBtn.centerXAnchor.constraint(equalTo: cardLayout.centerXAnchor),
            carCardBtn.widthAnchor.constraint(equalToConstant: 116),
            carCardBtn.bottomAnchor.constraint(equalTo: cardLayout.bottomAnchor, constant: -7),
            carCardBtn.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    @objc private func detailsPressed() {
        onViewDetailsTapped?()
    }
    
    // MARK: - Date Expiry Check Helper
    
    private func checkDateExpired(_ dateStr: String?) -> Bool {
        guard let dateStr = dateStr?.trimmingCharacters(in: .whitespacesAndNewlines),
              !dateStr.isEmpty,
              dateStr.lowercased() != "n/a",
              dateStr != "0",
              let targetDate = TimeUtils.parseDateSafely(dateStr)
        else {
            return false
        }
        
        return targetDate < Date()
    }
    
    // MARK: - Configuration
    
    func configure(with model: GarageItemModel, onDetails: (() -> Void)?) {
        self.onViewDetailsTapped = onDetails
        
        let vehicleNumber = model.vehicle_number ?? ""
        let ownerName = model.owner_name ?? ""
        let registrationDate = model.registration_date ?? ""
        
        // 1. Vehicle Number
        tvCarNo.text = vehicleNumber.isEmpty ? "KA 18 EQ 0001" : vehicleNumber
        
        // 2. Owner Name (masked, e.g. A**T V***A or S******P)
        tvCarOwner.text = ownerName.isEmpty ? "Owner" : ownerName
        
        // 3. Maker and Model
        let makerName = model.makers_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let modelName = model.makers_model?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let vehicleName = model.vehicle_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !makerName.isEmpty && !modelName.isEmpty {
            tvCarMaker.text = makerName
            tvCarMaker.isHidden = false
            tvCarModel.text = modelName
            tvCarModel.isHidden = false
        } else if !vehicleName.isEmpty {
            if vehicleName.contains("\n") {
                let parts = vehicleName.components(separatedBy: "\n")
                tvCarMaker.text = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                tvCarMaker.isHidden = false
                tvCarModel.text = parts.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                tvCarModel.isHidden = false
            } else {
                tvCarMaker.text = vehicleName
                tvCarMaker.isHidden = false
                if !modelName.isEmpty && modelName != vehicleName {
                    tvCarModel.text = modelName
                    tvCarModel.isHidden = false
                } else {
                    tvCarModel.text = ""
                    tvCarModel.isHidden = true
                }
            }
        } else if !modelName.isEmpty {
            tvCarMaker.text = modelName
            tvCarMaker.isHidden = false
            tvCarModel.text = ""
            tvCarModel.isHidden = true
        } else {
            tvCarMaker.text = "Vehicle Details"
            tvCarMaker.isHidden = false
            tvCarModel.text = ""
            tvCarModel.isHidden = true
        }
        
        // 4. Registration Date
        if !registrationDate.isEmpty {
            let formattedDate = TimeUtils.convertDateFormat(registrationDate, outputFormat: "dd-MM-yyyy")
            tvRegistrationDate.text = "Registered on \(formattedDate)"
            tvRegistrationDate.isHidden = false
        } else {
            tvRegistrationDate.text = ""
            tvRegistrationDate.isHidden = true
        }
        
        // 5. Vehicle Placeholder Icon
        ivCar.image = CommonFunctions.getVehiclePlaceholder(
            vehicleClass: model.vehicle_class,
            vehicleName: model.vehicle_name,
            makersModel: model.makers_model,
            category: model.category
        )
        
        // 6. Check Expiry Conditions:
        // - if PUC expired only -> show only PUC
        // - if Insurance expired only -> show only Insurance
        // - if both expired -> show both
        // - if neither expired -> show normal vehicle info
        let isPucExpired = checkDateExpired(model.pollution_expiry)
        let isInsuranceExpired = checkDateExpired(model.insurance_expiry)
        
        if isPucExpired || isInsuranceExpired {
            // === EXPIRED DESIGN ===
            // Card background turns coral/pink #F89898 (R.color.card_color)
            bgImageView.isHidden = true
            cardContainerView.backgroundColor = UIColor(red: 248/255, green: 152/255, blue: 152/255, alpha: 1.0)
            
            // Right container (cardLayout) gets bordered box with soft gradient
            cardLayout.applyExpiredStyle()
            
            // Switch layouts
            carDetailsLayout.isHidden = true
            pucInsuranceExpiryLayout.isHidden = false
            
            // Condition 1: If PUC expired, show PUC
            if isPucExpired {
                pucLayout.isHidden = false
                let pucDateStr = TimeUtils.convertDateFormat(model.pollution_expiry, outputFormat: "dd-MM-yyyy")
                tvPucDate.text = "On \(pucDateStr)"
            } else {
                pucLayout.isHidden = true
            }
            
            // Condition 2: If Insurance expired, show Insurance
            if isInsuranceExpired {
                insuranceLayout.isHidden = false
                let insDateStr = TimeUtils.convertDateFormat(model.insurance_expiry, outputFormat: "dd-MM-yyyy")
                tvInsuranceDate.text = "On \(insDateStr)"
            } else {
                insuranceLayout.isHidden = true
            }
        } else {
            // === NORMAL DESIGN ===
            // Card background has normal bg_card5 / mint-to-cream gradient
            bgImageView.isHidden = false
            cardContainerView.backgroundColor = .clear
            
            // Right container (cardLayout) is transparent, no border
            cardLayout.applyNormalStyle()
            
            // Switch layouts
            carDetailsLayout.isHidden = false
            pucInsuranceExpiryLayout.isHidden = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
