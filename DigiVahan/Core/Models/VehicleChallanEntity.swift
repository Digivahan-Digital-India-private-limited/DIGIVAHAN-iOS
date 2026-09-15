//
//  VehicleChallanEntity.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/08/26.
//

import Foundation

struct VehicleChallanEntity: Codable {

    var vehicleNumber: String = ""
    var lastHitServerDate: String = ""
    var lastHitServerTime: String = ""

    var lastHitServerMillis: Int64 = 0

    init() { }
}
