//
//  APIEndpoints.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

struct APIEndpoints {

    // Base URL
    static let baseURL = "https://api.digivahan.in"
    static let apiFolder = "/api/"
    
    static let GET_APP_INFO = "/api/v1/app-info"

    // Auth APIs
    static let login = "/api/auth/sign-in"
    static let OTPLogin = "/api/auth/otp-based-login"
    static let checkRegister = "/api/auth/check/init"
    static let register = "/api/auth/register/init"
    static let NEW_PASSWORD = "/api/auth/check/new-password"
    static let CHANGE_PASSWORD = "/api/auth/change-password"
    static let GET_USER_DETAILS = "/api/get_user_details"
    static let UPDATE_USER_DATA = baseURL + "/api/update_user"
    static let ADD_EMERGENCY_CONTACT = baseURL + "/api/v1/add/emergency-contact"
    static let UPDATE_EMERGENCY_CONTACT = baseURL + "/api/v1/update/emergency-contact"
    static let DELETE_EMERGENCY_CONTACT = "/api/v1/delete/emergency-contact"
    
    // Qr code
    static let GET_QR_CODE_BY_ID = "/api/qr/"
    static let CHECK_QR_CODE = "/api/check-qr"
    static let CREATE_QR_CODE = "/api/generate-qr"
    static let ASSIGN_QR_CODE = "/api/qr-assignment"
    static let GET_QR_TEMPLATE = "/api/create/qr-template-user/"
    
    // Notification
    static let SEND_NOTIFICATION = "/api/notifications/send"
    static let UPLOAD_SINGLE_FILE = baseURL + "/api/v1/notification/image"
    static let DELETE_SINGLE_FILE = "/api/v1/notification/delete-image"
    static let GET_NOTIFICATION = "/api/notifications/"
    
    static let CREATE_CHAT_ROOM = "/api/create/room"
    
    // call and message API
    static let CONTACT_VIA_CALL = "/api/user/contact-via-call"
    static let SEND_SMS = "/api/send/sms-notification"
    
    
    // Vehicle
    static let ADD_VEHICLE = "/api/v1/user/add-garage"
    static let CHECK_VEHICLE = "/api/v1/add-vehicle"
    static let GET_VEHICLE_LIST = "/api/v1/garage/"
    static let DELETE_VEHICLE = "/api/v1/garage/remove-vehicle"
    static let REFRESH_VEHICLE = "/api/v1/refresh/vehicle-data"
    
}
