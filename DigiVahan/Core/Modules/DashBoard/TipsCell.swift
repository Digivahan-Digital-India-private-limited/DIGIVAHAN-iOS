//
//  TipsCell.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Tips section.
//

import UIKit
import SDWebImage

class TipsCell: UICollectionViewCell {
    static let identifier = "TipsCell"
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 5
        view.layer.borderWidth = 0.6
        view.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.image = UIImage(named: "tips_temp_img")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(bannerImageView)
        
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            bannerImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            bannerImageView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])
    }
    
    func configure(with model: TipsItemModel) {
        if let rawUrl = model.banner?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawUrl.isEmpty,
           let url = URL(string: rawUrl) {
            bannerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "tips_temp_img"))
        } else {
            bannerImageView.image = UIImage(named: "tips_temp_img")
        }
    }
}
