//
//  EmergencyContactModel.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//

import Foundation

struct EmergencyContactModel: Codable {
    let _id: String
    let first_name: String
    let last_name: String
    let relation: String
    let phone_number: String
    let profile_pic: String
    let public_id: String
}
