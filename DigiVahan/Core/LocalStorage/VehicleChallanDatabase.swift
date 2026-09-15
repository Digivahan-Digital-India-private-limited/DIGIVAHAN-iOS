//
//  VehicleChallanDatabase.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/08/26.
//

import Foundation

class VehicleChallanDatabase {

    static let shared = VehicleChallanDatabase()

    private init() {}

    private let key = "vehicle_challan_db"

    private var data: [String: VehicleChallanEntity] {

        get {

            guard
                let saved = UserDefaults.standard.data(forKey: key),
                let decoded = try? JSONDecoder().decode(
                    [String: VehicleChallanEntity].self,
                    from: saved
                )
            else {

                return [:]
            }

            return decoded
        }

        set {

            if let encoded = try? JSONEncoder().encode(newValue) {

                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }

    func save(_ entity: VehicleChallanEntity) {

        var database = data

        database[entity.vehicleNumber] = entity

        data = database
    }

    func get(vehicleNumber: String) -> VehicleChallanEntity? {

        return data[vehicleNumber]
    }

    func delete(vehicleNumber: String) {

        var database = data

        database.removeValue(forKey: vehicleNumber)

        data = database
    }

    func clearAll() {

        UserDefaults.standard.removeObject(forKey: key)
    }
}
