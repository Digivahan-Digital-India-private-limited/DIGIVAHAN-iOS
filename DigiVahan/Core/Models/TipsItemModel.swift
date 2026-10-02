//
//  TipsItemModel.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Tips section.
//

import Foundation

struct TipsItemModel {
    struct Point {
        var icon: String?
        var message: String?
        var icon_public_id: String?
        
        init(icon: String? = nil, message: String? = nil, icon_public_id: String? = nil) {
            self.icon = icon
            self.message = message
            self.icon_public_id = icon_public_id
        }
    }
    
    var id: String?
    var banner: String?
    var banner_public_id: String?
    var title: String?
    var summary: String?
    var points: [Point] = []
    
    init(
        id: String? = nil,
        banner: String? = nil,
        banner_public_id: String? = nil,
        title: String? = nil,
        summary: String? = nil,
        points: [Point] = []
    ) {
        self.id = id
        self.banner = banner
        self.banner_public_id = banner_public_id
        self.title = title
        self.summary = summary
        self.points = points
    }
}
