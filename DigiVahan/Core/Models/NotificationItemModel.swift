//
//  NotificationItemModel.swift
//  DigiVahan
//
//  Created by Mr Ash on 01/07/26.
//

import Foundation

struct NotificationItemModel: Codable {

    var sender_id: String?
    var sender_pic: String?
    var sender_name: String?
    var notification_type: String?
    var notification_title: String?
    var link: String?
    var vehicle_id: String?
    var order_id: String?
    var message: String?
    var issue_type: String?
    var chat_room_id: String?
    var latitude: String?
    var longitude: String?
    var _id: String?
    var time: String?
    var createdAt: String?
    var updatedAt: String?

    var seen_status: Bool?
    var inapp_notification: Bool?

    var incident_proof: [String]?
}
