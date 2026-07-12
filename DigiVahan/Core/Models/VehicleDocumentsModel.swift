//
//  User.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import Foundation

class VehicleDocumentsModel: Codable {

    var doc_name: String = ""
    var doc_type: String = ""
    var doc_number: String = ""
    var doc_url: String = ""
    var public_id: String = ""
    var uploaded_at: String = ""

    init() {}
}
