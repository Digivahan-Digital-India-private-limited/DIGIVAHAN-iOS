//
//  EmergencyContactCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//

import UIKit

class EmergencyContactCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userNumber: UILabel!

    @IBOutlet weak var editBtn: UIImageView!
    @IBOutlet weak var deleteBtn: UIImageView!

    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        userImage.layer.cornerRadius = 25
        userImage.clipsToBounds = true

        editBtn.isUserInteractionEnabled = true
        editBtn.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(editBtnClick)
            )
        )

        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(deleteBtnClick)
            )
        )
    }

    @objc private func editBtnClick() {
        editAction?()
    }

    @objc private func deleteBtnClick() {
        deleteAction?()
    }
}
