//
//  TrendingCarsModel.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Trending New Cars section.
//

import Foundation

struct TrendingCarsModel {
    
    struct Specifications {
        var engine_capacity: String?
        var transmission: String?
        var fuel_tank_capacity: String?
        var seat_height: String?
        var kerb_weight: String?
        
        init(
            engine_capacity: String? = nil,
            transmission: String? = nil,
            fuel_tank_capacity: String? = nil,
            seat_height: String? = nil,
            kerb_weight: String? = nil
        ) {
            self.engine_capacity = engine_capacity
            self.transmission = transmission
            self.fuel_tank_capacity = fuel_tank_capacity
            self.seat_height = seat_height
            self.kerb_weight = kerb_weight
        }
    }
    
    struct DetailedSpecifications {
        var max_power: String?
        var max_torque: String?
        var riding_mode: String?
        var gear_shifting_pattern: String?
        
        init(
            max_power: String? = nil,
            max_torque: String? = nil,
            riding_mode: String? = nil,
            gear_shifting_pattern: String? = nil
        ) {
            self.max_power = max_power
            self.max_torque = max_torque
            self.riding_mode = riding_mode
            self.gear_shifting_pattern = gear_shifting_pattern
        }
    }
    
    struct Dimensions {
        var bootspace: String?
        var ground_clearance: String?
        var length: String?
        var width: String?
        var height: String?
        
        init(
            bootspace: String? = nil,
            ground_clearance: String? = nil,
            length: String? = nil,
            width: String? = nil,
            height: String? = nil
        ) {
            self.bootspace = bootspace
            self.ground_clearance = ground_clearance
            self.length = length
            self.width = width
            self.height = height
        }
    }
    
    struct Features {
        var air_conditioner: Bool?
        var central_locking: String?
        var power_windows: String?
        var headrest: String?
        var parking_assist: String?
        var cruise_control: Bool?
        var music_system_count: Int?
        var apple_carplay: String?
        var android_auto: String?
        var abs: Bool?
        var sunroof: Bool?
        var third_row_ac: Bool?
        var airbags: [String]?
        
        func getAirbagsAsString() -> String {
            if let bags = airbags, !bags.isEmpty {
                return bags.joined(separator: ", ")
            }
            return "N/A"
        }
    }
    
    var id: String?
    var car_id: String?
    var brandName: String?
    var modelName: String?
    var type: String?
    var price: Double?
    var priceDisplay: String?
    var mileage: String?
    var topSpeed: String?
    var imageUrl: String?
    var createdAt: String?
    var updatedAt: String?
    
    var specifications: Specifications?
    var detailedSpecifications: DetailedSpecifications?
    var dimensions: Dimensions?
    var features: Features?
    
    init(
        id: String? = nil,
        car_id: String? = nil,
        brandName: String? = nil,
        modelName: String? = nil,
        type: String? = nil,
        price: Double? = nil,
        priceDisplay: String? = nil,
        mileage: String? = nil,
        topSpeed: String? = nil,
        imageUrl: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        specifications: Specifications? = nil,
        detailedSpecifications: DetailedSpecifications? = nil,
        dimensions: Dimensions? = nil,
        features: Features? = nil
    ) {
        self.id = id
        self.car_id = car_id
        self.brandName = brandName
        self.modelName = modelName
        self.type = type
        self.price = price
        self.priceDisplay = priceDisplay
        self.mileage = mileage
        self.topSpeed = topSpeed
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.specifications = specifications
        self.detailedSpecifications = detailedSpecifications
        self.dimensions = dimensions
        self.features = features
    }
}
