//
//  VirtualQRListCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class VirtualQRListCell: UITableViewCell {

    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleNumber: UILabel!

    @IBOutlet weak var previewBtn: UIButton!

    var previewAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        vehicleImage.layer.cornerRadius = 25
        vehicleImage.clipsToBounds = true

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
