//
//  TipsDetailsVC.swift
//  DigiVahan
//
//  Created for DigiVahan Tips Details screen.
//

import UIKit
import SDWebImage

class TipsDetailsVC: BaseViewController {
    
    // MARK: - Properties
    var tipsItemDetails: TipsItemModel?
    
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
        label.text = "Tips"
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
    
    // Main Card Container (Matching Android activity_tips_details.xml CardView)
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.image = UIImage(named: "tips_temp_img")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let pointsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigation()
        setupScrollView()
        setupCardView()
        populateData()
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
    
    // MARK: - Card View Setup
    private func setupCardView() {
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(headerImageView)
        cardContainerView.addSubview(pointsStackView)
        
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            headerImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 470.0 / 1024.0),
            
            pointsStackView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 12),
            pointsStackView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 14),
            pointsStackView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -14),
            pointsStackView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Populate Data
    private func populateData() {
        guard let item = tipsItemDetails else { return }
        
        // Header Banner Image
        if let rawBanner = item.banner?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawBanner.isEmpty,
           let url = URL(string: rawBanner) {
            headerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "tips_temp_img"))
        } else {
            headerImageView.image = UIImage(named: "tips_temp_img")
        }
        
        // Clear previous rows
        for subview in pointsStackView.arrangedSubviews {
            pointsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Add point rows
        for (index, point) in item.points.enumerated() {
            let row = makePointRow(point: point, isLast: index == item.points.count - 1)
            pointsStackView.addArrangedSubview(row)
        }
    }
    
    // MARK: - Point Row Factory (Matching Android tips_details_item_design.xml)
    private func makePointRow(point: TipsItemModel.Point, isLast: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let fallbackIcon = UIImage(named: "tips_icon1") ?? UIImage(systemName: "lightbulb.fill")
        if let rawIcon = point.icon?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawIcon.isEmpty,
           let url = URL(string: rawIcon) {
            iconImageView.sd_setImage(with: url, placeholderImage: fallbackIcon)
        } else {
            iconImageView.image = fallbackIcon
            if UIImage(named: "tips_icon1") == nil {
                iconImageView.tintColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
            }
        }
        container.addSubview(iconImageView)
        
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textContainer)
        
        let messageLabel = UILabel()
        messageLabel.text = point.message
        messageLabel.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(messageLabel)
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0) // #DDDDDD
        separatorLine.isHidden = isLast
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Text Container
            textContainer.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            textContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            textContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            // Message Label
            messageLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            // Separator Line
            separatorLine.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor)
        ])
        
        return container
    }
}
