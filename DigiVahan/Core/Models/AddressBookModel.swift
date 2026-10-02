//
//  AddressBookModel.swift
//  DigiVahan
//
//  Created for DigiVahan Order QR Delivery Address.
//

import Foundation

struct AddressBookModel: Codable {
    var _id: String?
    var name: String?
    var contact_no: String?
    var house_no_building: String?
    var street_name: String?
    var landmark: String?
    var road_or_area: String?
    var city: String?
    var state: String?
    var pincode: String?
    var default_status: Bool?

    var formattedAddress: String {
        let parts = [
            house_no_building,
            road_or_area ?? street_name,
            landmark,
            city,
            state,
            pincode
        ].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        return parts.joined(separator: ", ")
    }
}
