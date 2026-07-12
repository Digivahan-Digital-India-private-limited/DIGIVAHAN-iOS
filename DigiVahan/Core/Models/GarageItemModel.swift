//
//  GarageItemModel.swift
//  DigiVahan
//
//  Created by Mr Ash on 18/06/26.
//

import Foundation

struct GarageItemModel: Codable {

    var vehicle_id: String?
    var owner_name: String?
    var vehicle_number: String?
    var vehicle_name: String?
    var registration_date: String?
    var ownership_details: String?
    var registered_rto: String?
    var makers_model: String?
    var makers_name: String?
    var vehicle_class: String?
    var fuel_type: String?
    var fuel_norms: String?
    var engine: String?
    var chassis_number: String?
    var insurer_name: String?
    var insurance_type: String?
    var insurance_expiry: String?
    var financer_name: String?
    var insurance_renewed_date: String?
    var vehicle_age: String?
    var fitness_upto: String?
    var pollution_renew_date: String?
    var pollution_expiry: String?
    var color: String?
    var unloaded_weight: String?
    var rc_status: String?
    var insurance_policy_number: String?
    var _id: String?

    var insurance_url: String?
    var pollution_url: String?
    var registration_url: String?
    var fitness_url: String?
    var permit_url: String?

    var permitNumber: String?
    var permitType: String?
    var permitValidFrom: String?
    var permitValidUpto: String?

    var nationalPermitNumber: String?
    var nationalPermitValidUpto: String?
    var nationalPermitIssuedBy: String?

    var category: String?

    var vehicleDocumentsArrayList: [VehicleDocuments] = []
}


struct VehicleDocuments: Codable {

    var doc_name: String?
    var doc_type: String?
    var public_id: String?
    var doc_number: String?
    var doc_url: String?
    var uploaded_at: String?
    var _id: String?
}
