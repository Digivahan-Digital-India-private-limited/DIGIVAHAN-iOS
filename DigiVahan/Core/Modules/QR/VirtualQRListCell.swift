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

        vehicleImage.clipsToBounds = false

        previewBtn.addTarget(
            self,
            action: #selector(previewBtnClick),
            for: .touchUpInside
        )
    }

    func configureButton(title: String) {
        if var config = previewBtn.configuration {
            var container = AttributeContainer()
            container.font = UIFont(name: "Hind-SemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .semibold)
            container.foregroundColor = .white
            config.attributedTitle = AttributedString(title, attributes: container)
            config.baseForegroundColor = .white
            previewBtn.configuration = config
        } else {
            previewBtn.setTitle(title, for: .normal)
            previewBtn.setTitleColor(.white, for: .normal)
            previewBtn.titleLabel?.font = UIFont(name: "Hind-SemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .semibold)
        }
    }

    @objc private func previewBtnClick() {
        previewAction?()
    }
}
