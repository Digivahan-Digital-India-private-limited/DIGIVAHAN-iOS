//
//  TrendingCarCell.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Trending New Cars section.
//

import UIKit
import SDWebImage

class TrendingCarCell: UICollectionViewCell {
    static let identifier = "TrendingCarCell"
    
    // MARK: - Capsule Background View
    private class TrendingCarCapsuleView: UIView {
        private let fillLayer = CAShapeLayer()
        private let borderGradientLayer = CAGradientLayer()
        private let borderMaskLayer = CAShapeLayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            backgroundColor = .clear
            
            fillLayer.fillColor = UIColor(red: 226/255.0, green: 240/255.0, blue: 223/255.0, alpha: 1.0).cgColor // #E2F0DF
            layer.addSublayer(fillLayer)
            
            borderGradientLayer.colors = [
                UIColor(white: 0.94, alpha: 1.0).cgColor, // #F0F0F0
                UIColor(white: 0.15, alpha: 0.85).cgColor // #262626
            ]
            borderGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.5)
            borderGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            borderMaskLayer.fillColor = UIColor.clear.cgColor
            borderMaskLayer.strokeColor = UIColor.black.cgColor
            borderMaskLayer.lineWidth = 2.0
            borderGradientLayer.mask = borderMaskLayer
            
            layer.addSublayer(borderGradientLayer)
        }
        
    override func layoutSubviews() {
            super.layoutSubviews()
            
            guard bounds.width > 0, bounds.height > 0 else { return }
            
            let w = bounds.width
            let h = bounds.height
            let rRight = h / 2.0
            
            let path = UIBezierPath()
            // Start at top-left behind the circle
            path.move(to: CGPoint(x: 1, y: 1))
            path.addLine(to: CGPoint(x: max(1, w - rRight), y: 1))
            // Right semicircle cap
            path.addArc(
                withCenter: CGPoint(x: max(1, w - rRight), y: h / 2.0),
                radius: rRight - 1,
                startAngle: -CGFloat.pi / 2.0,
                endAngle: CGFloat.pi / 2.0,
                clockwise: true
            )
            // Bottom line returning behind the circle
            path.addLine(to: CGPoint(x: 1, y: h - 1))
            path.addLine(to: CGPoint(x: 1, y: 1))
            path.close()
            
            fillLayer.path = path.cgPath
            borderMaskLayer.path = path.cgPath
            borderGradientLayer.frame = bounds
        }
    }
    
    // MARK: - Circular Car Container View (profile_bg1)
    private class TrendingCarCircleView: UIView {
        private let fillCircleLayer = CAShapeLayer()
        private let strokeGradientLayer = CAGradientLayer()
        private let strokeMaskLayer = CAShapeLayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            backgroundColor = .clear
            
            fillCircleLayer.fillColor = UIColor.white.cgColor
            layer.addSublayer(fillCircleLayer)
            
            strokeGradientLayer.colors = [
                UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0).cgColor, // #36B72E (top)
                UIColor.black.cgColor // #000000 (bottom)
            ]
            strokeGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            strokeGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            strokeMaskLayer.fillColor = UIColor.clear.cgColor
            strokeMaskLayer.strokeColor = UIColor.black.cgColor
            strokeMaskLayer.lineWidth = 2.8
            strokeGradientLayer.mask = strokeMaskLayer
            
            layer.addSublayer(strokeGradientLayer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard bounds.width > 0, bounds.height > 0 else { return }
            
            let path = UIBezierPath(ovalIn: bounds.insetBy(dx: 1.4, dy: 1.4))
            fillCircleLayer.path = path.cgPath
            strokeMaskLayer.path = path.cgPath
            strokeGradientLayer.frame = bounds
        }
    }
    
    // MARK: - Subviews
    private let capsuleView = TrendingCarCapsuleView()
    private let circleContainerView = TrendingCarCircleView()
    
    let carImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "ic_vehicle_default")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let carNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 13.5) ?? UIFont.boldSystemFont(ofSize: 13.5)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(white: 0.15, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 11) ?? UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor(red: 0x45/255.0, green: 0x5A/255.0, blue: 0x64/255.0, alpha: 1.0) // #455A64
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1.5
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        
        capsuleView.isUserInteractionEnabled = false
        circleContainerView.isUserInteractionEnabled = false
        textStackView.isUserInteractionEnabled = false
        
        capsuleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(capsuleView)
        
        circleContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleContainerView)
        
        circleContainerView.addSubview(carImageView)
        
        textStackView.addArrangedSubview(carNameLabel)
        textStackView.addArrangedSubview(brandLabel)
        textStackView.addArrangedSubview(priceLabel)
        capsuleView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            // Capsule: starts at x=25, height=70, vertically centered
            capsuleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            capsuleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            capsuleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            capsuleView.heightAnchor.constraint(equalToConstant: 70),
            
            // Circle container: 80x80 pinned to leading
            circleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            circleContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleContainerView.widthAnchor.constraint(equalToConstant: 80),
            circleContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Car Image inside circle
            carImageView.centerXAnchor.constraint(equalTo: circleContainerView.centerXAnchor),
            carImageView.centerYAnchor.constraint(equalTo: circleContainerView.centerYAnchor),
            carImageView.widthAnchor.constraint(equalToConstant: 60),
            carImageView.heightAnchor.constraint(equalToConstant: 44),
            
            // Text stack inside capsule: paddingLeft 56 (clears circle), paddingRight 14
            textStackView.leadingAnchor.constraint(equalTo: capsuleView.leadingAnchor, constant: 56),
            textStackView.trailingAnchor.constraint(equalTo: capsuleView.trailingAnchor, constant: -14),
            textStackView.centerYAnchor.constraint(equalTo: capsuleView.centerYAnchor)
        ])
    }
    
    func configure(with model: TrendingCarsModel) {
        carNameLabel.text = cleanModelName(model.modelName)
        brandLabel.text = model.brandName ?? ""
        priceLabel.text = cleanPriceDisplay(model.priceDisplay, fallbackPrice: model.price)
        
        if let rawUrl = model.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !rawUrl.isEmpty {
            let firstUrl = rawUrl.components(separatedBy: ",")[0]
            if let url = URL(string: firstUrl) {
                carImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_vehicle_default"))
            } else {
                carImageView.image = UIImage(named: "ic_vehicle_default")
            }
        } else {
            carImageView.image = UIImage(named: "ic_vehicle_default")
        }
    }
    
    private func cleanModelName(_ name: String?) -> String {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return "" }
        var clean = name
        if let parenIndex = clean.firstIndex(of: "(") {
            clean = String(clean[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        clean = clean.replacingOccurrences(of: "\\s+\\d{4}$", with: "", options: .regularExpression)
        return clean.isEmpty ? name : clean
    }

    private func cleanPriceDisplay(_ price: String?, fallbackPrice: Double?) -> String {
        if var price = price?.trimmingCharacters(in: .whitespacesAndNewlines), !price.isEmpty {
            if let range = price.range(of: " onwards", options: .caseInsensitive) {
                price = String(price[..<range.lowerBound])
            }
            price = price.replacingOccurrences(of: "\\s*\\(Expected\\)", with: "", options: [.caseInsensitive, .regularExpression])
            price = price.trimmingCharacters(in: .whitespaces)
            if !price.isEmpty { return price }
        }
        if let p = fallbackPrice, p > 0 {
            if p >= 10000000 {
                return String(format: "₹%.2f Crore", p / 10000000)
            } else if p >= 100000 {
                return String(format: "₹%.2f Lakh", p / 100000)
            } else {
                return String(format: "₹%.0f", p)
            }
        }
        return ""
    }
}
