//
//  TrendingVSCarsModel.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Popular Comparison section.
//

import Foundation

struct TrendingVSCarsModel {
    var comparisonId: String?
    var createdAt: String?
    var car1Data: TrendingCarsModel?
    var car2Data: TrendingCarsModel?
    
    init(
        comparisonId: String? = nil,
        createdAt: String? = nil,
        car1Data: TrendingCarsModel? = nil,
        car2Data: TrendingCarsModel? = nil
    ) {
        self.comparisonId = comparisonId
        self.createdAt = createdAt
        self.car1Data = car1Data
        self.car2Data = car2Data
    }
}
