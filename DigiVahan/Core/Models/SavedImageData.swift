//
//  SavedImageData.swift
//  DigiVahan
//
//  Created by Mr Ash on 16/06/26.
//

import UIKit

struct SavedImageData: Codable {

    var image_url: String?
    var public_id: String?
    var folder: String?

    // Local image (not from API)
    var imageFile: UIImage?

    enum CodingKeys: String, CodingKey {
        case image_url
        case public_id
        case folder
    }
}
