//
//  VirtualQRListCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class DocumentListCell: UITableViewCell {

    @IBOutlet weak var documentImage: UIImageView!
    @IBOutlet weak var documentName: UILabel!
    @IBOutlet weak var documentNumber: UILabel!

    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!

    var previewAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        documentImage.layer.cornerRadius = 25
        documentImage.clipsToBounds = true

        previewBtn.addTarget(
            self,
            action: #selector(previewBtnClick),
            for: .touchUpInside
        )
        
        deleteBtn.addTarget(
            self,
            action: #selector(deleteBtnClick),
            for: .touchUpInside
        )
        
        print("Delete Button:", deleteBtn as Any)
    }

    @objc private func previewBtnClick() {
        previewAction?()
    }
    
    @objc private func deleteBtnClick() {
        print("🗑 UIButton Clicked")
        deleteAction?()
    }
}
