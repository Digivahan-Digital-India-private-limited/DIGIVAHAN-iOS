//
//  User.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import Foundation

class User: Codable {

    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var email: String = ""

    var isPhoneNumberPrimary: Bool = false
    var phoneNumberVerified: Bool = false

    var profilePic: String = ""
    var profileId: String = ""

    var publicPic: String = ""
    var publicId: String = ""

    var isEmailVerified: Bool = false
    var isEmailPrimary: Bool = false

    var password: String = ""
    var occupation: String = ""

    var profileCompletionPercent: Int = 0

    var nickName: String = ""
    var address: String = ""

    var age: String = ""

    var gender: String = ""

    var vehicleId: String = ""
    var userId: String = ""

    init() {}
}
