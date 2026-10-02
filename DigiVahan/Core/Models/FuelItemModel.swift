//
//  FuelItemModel.swift
//  DigiVahan
//
//  Created by Mr Ash on 02/10/26.
//

import Foundation

struct FuelResponseModel: Codable {
    var success: Bool?
    var data: FuelDataModel?
}

struct FuelDataModel: Codable {
    var updatedAt: String?
    var states: [FuelItemModel]?
}

struct FuelItemModel: Codable {
    var state: String?
    var petrol: String?
    var diesel: String?
    var cng: String?

    enum CodingKeys: String, CodingKey {
        case state, petrol, diesel, cng
    }

    init(state: String? = nil, petrol: String? = nil, diesel: String? = nil, cng: String? = nil) {
        self.state = state
        self.petrol = petrol
        self.diesel = diesel
        self.cng = cng
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try? container.decodeIfPresent(String.self, forKey: .state)
        petrol = Self.decodeStringOrNumber(from: container, key: .petrol)
        diesel = Self.decodeStringOrNumber(from: container, key: .diesel)
        cng = Self.decodeStringOrNumber(from: container, key: .cng)
    }

    private static func decodeStringOrNumber(from container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> String? {
        if let str = try? container.decodeIfPresent(String.self, forKey: key) {
            return str
        }
        if let dbl = try? container.decodeIfPresent(Double.self, forKey: key) {
            if dbl == floor(dbl) {
                return String(format: "%.0f", dbl)
            } else {
                return String(format: "%.2f", dbl)
            }
        }
        if let intVal = try? container.decodeIfPresent(Int.self, forKey: key) {
            return "\(intVal)"
        }
        return nil
    }
}
