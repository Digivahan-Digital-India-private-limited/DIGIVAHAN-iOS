//
//  VirtualQRListCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class NotificationListCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var ownerImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var notificationDate: UILabel!

    @IBOutlet weak var previewBtn: UIButton!

    var previewAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card
        cardView.layer.cornerRadius = 15
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.clipsToBounds = true

        ownerImage.layer.cornerRadius = 25
        ownerImage.clipsToBounds = true

        previewBtn.addTarget(
            self,
            action: #selector(previewBtnClick),
            for: .touchUpInside
        )
    }

    @objc private func previewBtnClick() {
        previewAction?()
    }
}
