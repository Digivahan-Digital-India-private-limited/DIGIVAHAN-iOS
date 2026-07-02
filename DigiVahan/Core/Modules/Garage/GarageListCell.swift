//
//  EmergencyContactCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//

import UIKit

class GarageListCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var vehicleImage: UIImageView!

    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleClass: UILabel!
    
    @IBOutlet weak var deleteBtn: UIImageView!

    var itemClickAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Card
        cardView.layer.cornerRadius = 15
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.clipsToBounds = true

        // Vehicle image
//        vehicleImage.layer.cornerRadius = 12
//        vehicleImage.clipsToBounds = true
        vehicleImage.contentMode = .scaleAspectFill


        // Card click
        cardView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(cardViewClicked)
        )
        cardView.addGestureRecognizer(tap)
        
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(deleteBtnClick)
            )
        )
        
    }
    
    @objc private func deleteBtnClick() {
        deleteAction?()
    }

    @objc private func cardViewClicked() {
        itemClickAction?()
    }
}

