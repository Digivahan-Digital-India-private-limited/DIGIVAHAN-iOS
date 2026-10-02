//
//  PopularComparisonCell.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Popular Comparison section.
//

import UIKit
import SDWebImage

class PopularComparisonCell: UICollectionViewCell {
    static let identifier = "PopularComparisonCell"
    
    // MARK: - UI Components
    private let cardBackgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "campare_bg")
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Left Car (Car 1)
    private let car1Container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let car1ImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let car1NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let car1PriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Center VS Icon
    private let vsImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vs_icon")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Right Car (Car 2)
    private let car2Container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let car2ImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let car2NameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let car2PriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 5
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(cardBackgroundImageView)
        contentView.addSubview(car1Container)
        contentView.addSubview(vsImageView)
        contentView.addSubview(car2Container)
        
        // Car 1 elements
        car1Container.addSubview(car1ImageView)
        car1Container.addSubview(car1NameLabel)
        car1Container.addSubview(car1PriceLabel)
        
        // Car 2 elements
        car2Container.addSubview(car2ImageView)
        car2Container.addSubview(car2NameLabel)
        car2Container.addSubview(car2PriceLabel)
        
        NSLayoutConstraint.activate([
            // Card Background
            cardBackgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardBackgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardBackgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardBackgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Center VS Icon
            vsImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vsImageView.widthAnchor.constraint(equalToConstant: 40),
            vsImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Left Container (Car 1)
            car1Container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            car1Container.trailingAnchor.constraint(equalTo: vsImageView.leadingAnchor, constant: -6),
            car1Container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            car1Container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Car 1 Image
            car1ImageView.topAnchor.constraint(equalTo: car1Container.topAnchor),
            car1ImageView.centerXAnchor.constraint(equalTo: car1Container.centerXAnchor),
            car1ImageView.leadingAnchor.constraint(greaterThanOrEqualTo: car1Container.leadingAnchor),
            car1ImageView.trailingAnchor.constraint(lessThanOrEqualTo: car1Container.trailingAnchor),
            car1ImageView.heightAnchor.constraint(equalToConstant: 72),
            
            // Car 1 Name
            car1NameLabel.topAnchor.constraint(equalTo: car1ImageView.bottomAnchor, constant: 4),
            car1NameLabel.leadingAnchor.constraint(equalTo: car1Container.leadingAnchor),
            car1NameLabel.trailingAnchor.constraint(equalTo: car1Container.trailingAnchor),
            
            // Car 1 Price
            car1PriceLabel.topAnchor.constraint(equalTo: car1NameLabel.bottomAnchor, constant: 2),
            car1PriceLabel.leadingAnchor.constraint(equalTo: car1Container.leadingAnchor),
            car1PriceLabel.trailingAnchor.constraint(equalTo: car1Container.trailingAnchor),
            car1PriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: car1Container.bottomAnchor),
            
            // Right Container (Car 2)
            car2Container.leadingAnchor.constraint(equalTo: vsImageView.trailingAnchor, constant: 6),
            car2Container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            car2Container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            car2Container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Car 2 Image
            car2ImageView.topAnchor.constraint(equalTo: car2Container.topAnchor),
            car2ImageView.centerXAnchor.constraint(equalTo: car2Container.centerXAnchor),
            car2ImageView.leadingAnchor.constraint(greaterThanOrEqualTo: car2Container.leadingAnchor),
            car2ImageView.trailingAnchor.constraint(lessThanOrEqualTo: car2Container.trailingAnchor),
            car2ImageView.heightAnchor.constraint(equalToConstant: 72),
            
            // Car 2 Name
            car2NameLabel.topAnchor.constraint(equalTo: car2ImageView.bottomAnchor, constant: 4),
            car2NameLabel.leadingAnchor.constraint(equalTo: car2Container.leadingAnchor),
            car2NameLabel.trailingAnchor.constraint(equalTo: car2Container.trailingAnchor),
            
            // Car 2 Price
            car2PriceLabel.topAnchor.constraint(equalTo: car2NameLabel.bottomAnchor, constant: 2),
            car2PriceLabel.leadingAnchor.constraint(equalTo: car2Container.leadingAnchor),
            car2PriceLabel.trailingAnchor.constraint(equalTo: car2Container.trailingAnchor),
            car2PriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: car2Container.bottomAnchor)
        ])
    }
    
    func configure(with model: TrendingVSCarsModel) {
        // Car 1
        let car1 = model.car1Data
        car1NameLabel.text = car1?.modelName ?? "Car 1"
        car1PriceLabel.text = formatComparisonPrice(car1?.priceDisplay, fallbackPrice: car1?.price)
        
        if let rawUrl = car1?.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !rawUrl.isEmpty {
            let firstUrl = rawUrl.components(separatedBy: ",")[0]
            if let url = URL(string: firstUrl) {
                car1ImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_vehicle_default"))
            } else {
                car1ImageView.image = UIImage(named: "ic_vehicle_default")
            }
        } else {
            car1ImageView.image = UIImage(named: "ic_vehicle_default")
        }
        
        // Car 2
        let car2 = model.car2Data
        car2NameLabel.text = car2?.modelName ?? "Car 2"
        car2PriceLabel.text = formatComparisonPrice(car2?.priceDisplay, fallbackPrice: car2?.price)
        
        if let rawUrl = car2?.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !rawUrl.isEmpty {
            let firstUrl = rawUrl.components(separatedBy: ",")[0]
            if let url = URL(string: firstUrl) {
                car2ImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_vehicle_default"))
            } else {
                car2ImageView.image = UIImage(named: "ic_vehicle_default")
            }
        } else {
            car2ImageView.image = UIImage(named: "ic_vehicle_default")
        }
    }
    
    private func formatComparisonPrice(_ price: String?, fallbackPrice: Double? = nil) -> String {
        var text = price?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty, let p = fallbackPrice, p > 0 {
            if p >= 10000000 {
                text = String(format: "₹%.2f Crore", p / 10000000)
            } else if p >= 100000 {
                text = String(format: "₹%.2f Lakh", p / 100000)
            } else {
                text = String(format: "₹%.0f", p)
            }
        }
        guard !text.isEmpty else { return "" }
        
        if text.lowercased().contains("onwards") {
            text = text.replacingOccurrences(of: "(?i)\\s*onwards", with: "\nonwards", options: .regularExpression)
        } else {
            text = "\(text)\nonwards"
        }
        return text
    }
}
