//
//  VirtualQRListCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class ChallanListCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var accusedText: UILabel!
    @IBOutlet weak var fatherName: UILabel!
    @IBOutlet weak var challanNo: UILabel!
    @IBOutlet weak var challanDate: UILabel!
    @IBOutlet weak var challanStatus: UILabel!
    @IBOutlet weak var challanAmount: UILabel!
    @IBOutlet weak var challanPlace: UILabel!
    @IBOutlet weak var challanOffence: UILabel!
    
    @IBOutlet weak var payBtnLayout: UIView!
    @IBOutlet weak var payBtn: UIButton!

    var payAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card
        cardView.layer.cornerRadius = 15
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.clipsToBounds = true


        payBtn.addTarget(
            self,
            action: #selector(payBtnClick),
            for: .touchUpInside
        )
    }

    @objc private func payBtnClick() {
        payAction?()
    }
}
