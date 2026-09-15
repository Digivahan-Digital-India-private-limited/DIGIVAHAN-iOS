//
//  ChallanModel.swift
//  DigiVahan
//
//  Created by Mr Ash on 30/07/26.
//

import Foundation

struct ChallanModel: Codable {

    var ownerName: String?
    var ownerFatherName: String?
    var rcNumber: String?
    var challanNumber: String?
    var offence: String?
    var amountSettledAt: Int?
    var transactionStatus: String?
    var location: String?
    var createdAt: String?
    var receiptLink: String?
    var motorVehicleAct: String?
    var court_name: String?

    init() { }
}
