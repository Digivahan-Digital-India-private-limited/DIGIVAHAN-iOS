//
//  ActionCardCell.swift
//  DigiVahan
//
//  Created for DigiVahan Home Action Cards Carousel.
//

import UIKit

class ActionCardCell: UICollectionViewCell {
    static let identifier = "ActionCardCell"
    
    // MARK: - Subviews
    let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 231/255, green: 245/255, blue: 228/255, alpha: 1.0) // #E7F5E4
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 54/255, green: 183/255, blue: 46/255, alpha: 1.0) // #36B72E
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Hind-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onActionTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(bannerImageView)
        cardContainerView.addSubview(titleLabel)
        cardContainerView.addSubview(descriptionLabel)
        cardContainerView.addSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        cardContainerView.addGestureRecognizer(cardTap)
        
        NSLayoutConstraint.activate([
            // Container with 16pt horizontal margins
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Banner image on the left
            bannerImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 12),
            bannerImageView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            bannerImageView.widthAnchor.constraint(equalToConstant: 100),
            bannerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: bannerImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 18),
            
            // Description
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Action button
            actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            actionButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    @objc private func buttonPressed() {
        onActionTapped?()
    }
    
    func configure(title: String, subtitle: String, buttonTitle: String, imageName: String, onAction: (() -> Void)?) {
        titleLabel.text = title
        descriptionLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        bannerImageView.image = UIImage(named: imageName)
        self.onActionTapped = onAction
    }
}
