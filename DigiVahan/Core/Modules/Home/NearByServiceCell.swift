//
//  NearByServiceCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 22/07/26.
//

import UIKit
import SDWebImage

class NearByServiceCell: UICollectionViewCell {

    @IBOutlet weak var serviceBtn: UIView!
    @IBOutlet weak var serviceImageBg: UIView!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceTitle: UILabel!

//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        serviceImage.contentMode = .scaleAspectFit
//    }
//
//    func bind(_ item: NearByServiceItem) {
//
//        serviceTitle.text = item.title
//
//        serviceImage.sd_setImage(
//            with: URL(string: item.icon ?? ""),
//            placeholderImage: UIImage(named: "placeholder")
//        )
//    }
}
