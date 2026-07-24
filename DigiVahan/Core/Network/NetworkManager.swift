//
//  NetworkManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import Foundation
import Alamofire
import UIKit

class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    // MARK: - Common API Method

    func callAPI(
        url: String,
        method: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (
            _ response: [String: Any]?,
            _ status: Bool,
            _ message: String
        ) -> Void
    ) {

        // Full URL
        guard let apiURL = URL(string: APIEndpoints.baseURL + url) else {
            completion(nil, false, "Invalid URL")
            return
        }

        print("========== API REQUEST ==========")
        print("URL:", apiURL)

        // Request
        var request = URLRequest(url: apiURL)

        request.httpMethod = method.uppercased()

        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios", forHTTPHeaderField: "device_type")

        // Device ID
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            request.setValue(deviceID, forHTTPHeaderField: "device_id")
        }

        // Auth Token
        let token = PreferenceManager.shared.getAuthToken()
    

        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body Params
        if let params = parameters {

            do {

                request.httpBody = try JSONSerialization.data(
                    withJSONObject: params,
                    options: []
                )

                print("PARAMS:", params)

            } catch {

                completion(nil, false, "Invalid Parameters")
                return
            }
        }

        // Timeout
        request.timeoutInterval = 30

        // API Call
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in

            DispatchQueue.main.async {

                // Network Error
                if let error = error {

//                    print("ERROR:", error.localizedDescription)

                    completion(nil, false, error.localizedDescription)

                    return
                }

                guard let data = data else {

                    completion(nil, false, "No Data Found")
                    return
                }

                do {

                    // Convert Response
                    if let json = try JSONSerialization.jsonObject(
                        with: data,
                        options: []
                    ) as? [String: Any] {

                        print("========== API RESPONSE ==========")
                        print(json)

                        // Status
                        let status =
                        json["status"] as? Bool ??
                        json["success"] as? Bool ?? false

                        // Message
                        let message =
                        json["message"] as? String ??
                        "No Message"

                        completion(json, status, message)

                    } else {

                        completion(nil, false, "Invalid Response")
                    }

                } catch {

                    completion(nil, false, error.localizedDescription)
                }
            }

        }.resume()
    }
    
    
    func updateBasicDetails(
            userId: String,
            firstName: String,
            lastName: String,
            occupation: String,
            profileImage: UIImage?,
            completion: @escaping (Bool, String, User?) -> Void
        ) {

            let url = APIEndpoints.UPDATE_USER_DATA
            // Auth Token
            let token = PreferenceManager.shared.getAuthToken()
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "device_type": "ios",
                "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""
            ]

            

            AF.upload(
                multipartFormData: { multipartData in

                    // Text fields
                    multipartData.append(userId.data(using: .utf8)!, withName: "user_id")
                    multipartData.append(firstName.data(using: .utf8)!, withName: "first_name")
                    multipartData.append(lastName.data(using: .utf8)!, withName: "last_name")
                    multipartData.append(occupation.data(using: .utf8)!, withName: "occupation")

                    // Optional image
                    if let image = profileImage,
                       let imageData = CommonFunctions.compressImage(
                            image,
                            targetSizeKB: 1024
                       ) {

//                        print("📦 Upload Size = \(imageData.count / 1024) KB")

                        multipartData.append(
                            imageData,
                            withName: "profile_pic",
                            fileName: "profile.jpg",
                            mimeType: "image/jpeg"
                        )

                    } else {

//                        print("⚠️ No image selected")

                        multipartData.append(
                            Data(),
                            withName: "profile_pic",
                            fileName: "",
                            mimeType: "text/plain"
                        )
                    }

                },
                to: url,
                method: .put,
                headers: headers
            )
            .validate()
            .responseData { response in

                switch response.result {

                case .success(let data):

                    do {

                        guard let json = try JSONSerialization.jsonObject(
                            with: data
                        ) as? [String: Any] else {

                            completion(false, "Invalid response", nil)
                            return
                        }

                        let status = json["status"] as? Bool ?? false
                        let message = json["message"] as? String ?? ""

                        if status {

                            let user = CommonFunctions.parseUserFromJson(json)
                            PreferenceManager.shared.saveUser(user)

                            completion(true, message, user)

                        } else {

                            completion(false, message, nil)
                        }

                    } catch {
                        completion(false, error.localizedDescription, nil)
                    }
                    
                case .failure(let error):

                    /*print("❌ Error: \(error.localizedDescription)")
                        print("Status Code:", response.response?.statusCode ?? 0)

                        if let data = response.data,
                           let responseString = String(data: data, encoding: .utf8) {

                            print("Response Body:")
                            print(responseString)
                        }
                     */

                        completion(false, error.localizedDescription, nil)
                }
            }
        }
    
    
    func updatePublicDetails(
        userId: String,
        nickName: String,
        address: String,
        age: String,
        gender: String,
        publicImage: UIImage?,
        completion: @escaping (Bool, String, User?) -> Void
    ) {

        let url = APIEndpoints.UPDATE_USER_DATA

        let token = PreferenceManager.shared.getAuthToken()

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "device_type": "ios",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]

        AF.upload(
            multipartFormData: { multipartData in

                // Text fields
                multipartData.append(userId.data(using: .utf8)!, withName: "user_id")
                multipartData.append(nickName.data(using: .utf8)!, withName: "nick_name")
                multipartData.append(address.data(using: .utf8)!, withName: "address")
                multipartData.append(age.data(using: .utf8)!, withName: "age")
                multipartData.append(gender.data(using: .utf8)!, withName: "gender")

                // Image
                if let image = publicImage,
                   let imageData = CommonFunctions.compressImage(
                        image,
                        targetSizeKB: 1024
                   ) {

//                    print("📦 Upload Size = \(imageData.count / 1024) KB")

                    multipartData.append(
                        imageData,
                        withName: "public_pic",
                        fileName: "public.jpg",
                        mimeType: "image/jpeg"
                    )

                } else {

//                    print("⚠️ No image selected")

                    multipartData.append(
                        Data(),
                        withName: "public_pic",
                        fileName: "",
                        mimeType: "text/plain"
                    )
                }

            },
            to: url,
            method: .put,
            headers: headers
        )
        .validate()
        .responseData { response in

            switch response.result {

            case .success(let data):

                do {

                    guard let json = try JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any] else {

                        completion(false, "Invalid response", nil)
                        return
                    }

                    let status = json["status"] as? Bool ?? false
                    let message = json["message"] as? String ?? ""

                    if status {

                        let user = CommonFunctions.parseUserFromJson(json)
                        PreferenceManager.shared.saveUser(user)

                        completion(true, message, user)

                    } else {

                        completion(false, message, nil)
                    }

                } catch {
                    completion(false, error.localizedDescription, nil)
                }

            case .failure(let error):
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    
    // to handel Add Emergency Contact
    func addEmergencyContact(
        userId: String,
        first_name: String,
        last_name: String,
        relation: String,
        phone_number: String,
        publicImage: UIImage?,
        completion: @escaping (
            Bool,
            String,
            [String: Any]?
        ) -> Void
    ) {

        let url = APIEndpoints.ADD_EMERGENCY_CONTACT

        let token = PreferenceManager.shared.getAuthToken()

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "device_type": "ios",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]

        AF.upload(
            multipartFormData: { multipartData in

                // Text fields
                multipartData.append(userId.data(using: .utf8)!, withName: "user_id")
                multipartData.append(first_name.data(using: .utf8)!, withName: "first_name")
                multipartData.append(last_name.data(using: .utf8)!, withName: "last_name")
                multipartData.append(relation.data(using: .utf8)!, withName: "relation")
                multipartData.append(phone_number.data(using: .utf8)!, withName: "phone_number")

                // Image
                if let image = publicImage,
                   let imageData = CommonFunctions.compressImage(
                        image,
                        targetSizeKB: 1024
                   ) {

//                    print("📦 Upload Size = \(imageData.count / 1024) KB")

                    multipartData.append(
                        imageData,
                        withName: "profile_pic",
                        fileName: "public.jpg",
                        mimeType: "image/jpeg"
                    )

                } else {

//                    print("⚠️ No image selected")

                    multipartData.append(
                        Data(),
                        withName: "profile_pic",
                        fileName: "",
                        mimeType: "text/plain"
                    )
                }

            },
            to: url,
            method: .post,
            headers: headers
        )
        .validate()
        .responseData { response in

            switch response.result {
                
            case .success(let data):
                
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any] else {
                        
                        completion(false, "Invalid response", nil)
                        return
                    }
                    
                    let status = json["status"] as? Bool ??
                    json["success"] as? Bool ?? false
                    
                    let message = json["message"] as? String ?? ""
                    
//                    print("========== API RESPONSE ==========")
//                    print(json)
                    
                    completion(status, message, json)
                    
                } catch {
                    
                    completion(false, error.localizedDescription, nil)
                }
                
            case .failure(let error):
                
//                print("❌ Error:", error.localizedDescription)
//                print("Status Code:", response.response?.statusCode ?? 0)
                
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    
//                    print("Response Body:")
//                    print(responseString)
                }
                
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    // to handel Edit Emergency Contact
    func editEmergencyContact(
        userId: String,
        first_name: String,
        last_name: String,
        relation: String,
        phone_number: String,
        contact_id: String,
        public_id: String,
        publicImage: UIImage?,
        completion: @escaping (
            Bool,
            String,
            [String: Any]?
        ) -> Void
    ) {

        let url = APIEndpoints.UPDATE_EMERGENCY_CONTACT

        let token = PreferenceManager.shared.getAuthToken()

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "device_type": "ios",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]

        AF.upload(
            multipartFormData: { multipartData in

                // Text fields
                multipartData.append(userId.data(using: .utf8)!, withName: "user_id")
                multipartData.append(contact_id.data(using: .utf8)!, withName: "contact_id")
                multipartData.append(first_name.data(using: .utf8)!, withName: "first_name")
                multipartData.append(last_name.data(using: .utf8)!, withName: "last_name")
                multipartData.append(relation.data(using: .utf8)!, withName: "relation")
                multipartData.append(phone_number.data(using: .utf8)!, withName: "phone_number")
                multipartData.append(public_id.data(using: .utf8)!, withName: "public_id")

                // Image
                if let image = publicImage,
                   let imageData = CommonFunctions.compressImage(
                        image,
                        targetSizeKB: 1024
                   ) {

//                    print("📦 Upload Size = \(imageData.count / 1024) KB")

                    multipartData.append(
                        imageData,
                        withName: "profile_pic",
                        fileName: "public.jpg",
                        mimeType: "image/jpeg"
                    )

                } else {

//                    print("⚠️ No image selected")

                    multipartData.append(
                        Data(),
                        withName: "profile_pic",
                        fileName: "",
                        mimeType: "text/plain"
                    )
                }

            },
            to: url,
            method: .put,
            headers: headers
        )
        .validate()
        .responseData { response in

            switch response.result {

            case .success(let data):

                do {

                    guard let json = try JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any] else {

                        completion(false, "Invalid response", nil)
                        return
                    }

                    let status = json["status"] as? Bool ??
                                 json["success"] as? Bool ?? false

                    let message = json["message"] as? String ?? ""

                    completion(status, message, json)

                } catch {

                    completion(false, error.localizedDescription, nil)
                }

            case .failure(let error):

//                print("❌ Error:", error.localizedDescription)
//                print("Status Code:", response.response?.statusCode ?? 0)
                
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    
//                    print("Response Body:")
//                    print(responseString)
                }
                
                completion(false, error.localizedDescription, nil)
                
            }
        }
    }
    
    
    
    // upload Single Image
    func uploadSingleImage(
        image: UIImage?,
        folderName: String,
        completion: @escaping (
            Bool,
            String,
            [String: Any]?
        ) -> Void
    ) {

        let url = APIEndpoints.UPLOAD_SINGLE_FILE

        AF.upload(
            multipartFormData: { multipartData in

                // Text fields
                multipartData.append(folderName.data(using: .utf8)!, withName: "folder_name")

                // Image
                if let image = image,
                   let imageData = CommonFunctions.compressImage(
                        image,
                        targetSizeKB: 1024
                   ) {

//                    print("📦 Upload Size = \(imageData.count / 1024) KB")

                    multipartData.append(
                        imageData,
                        withName: "image",
                        fileName: "userVehicle.jpg",
                        mimeType: "image/jpeg"
                    )

                } else {

//                    print("⚠️ No image selected")

                    return
                }

            },
            to: url,
            method: .post
        )
        .validate()
        .responseData { response in

            switch response.result {

            case .success(let data):

                do {

                    guard let json = try JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any] else {

                        completion(false, "Invalid response", nil)
                        return
                    }

                    let status = json["status"] as? Bool ??
                                 json["success"] as? Bool ?? false

                    let message = json["message"] as? String ?? ""

                    completion(status, message, json)

                } catch {

                    completion(false, error.localizedDescription, nil)
                }

            case .failure(let error):

//                print("❌ Error:", error.localizedDescription)
//                print("Status Code:", response.response?.statusCode ?? 0)
//                
//                if let data = response.data,
//                   let responseString = String(data: data, encoding: .utf8) {
//                    
//                    print("Response Body:")
//                    print(responseString)
//                }
                
                completion(false, error.localizedDescription, nil)
                
            }
        }
    }
    
    
    // upload Document Image
    func updateDocument(
        userId: String,
        vehicleId: String,
        docName: String,
        docNumber: String,
        docType: String,
        docFile: UIImage?,
        completion: @escaping (
            Bool,
            String,
            [String: Any]?
        ) -> Void
    ) {

        let TAG = "UploadDocument"

        print("========================================")
        print("🚀 Starting Document Upload")
        print("👤 User ID:", userId)
        print("🚗 Vehicle ID:", vehicleId)
        print("📄 Doc Name:", docName)
        print("📃 Doc Type:", docType)
        print("🔢 Doc Number:", docNumber)

        guard let image = docFile else {
            print("❌ No Image Selected")
            completion(false, "No document selected", nil)
            return
        }

        guard let imageData = CommonFunctions.compressImage(
            image,
            targetSizeKB: 1024
        ) else {

            print("❌ Failed to compress image")
            completion(false, "Image compression failed", nil)
            return
        }

        print("📦 Upload Size: \(imageData.count / 1024) KB")

        let url = APIEndpoints.UPLOAD_DOCUMENT

        AF.upload(
            multipartFormData: { multipartData in

                multipartData.append(
                    Data(userId.utf8),
                    withName: "user_id"
                )

                multipartData.append(
                    Data(vehicleId.utf8),
                    withName: "vehicle_id"
                )

                multipartData.append(
                    Data(docName.utf8),
                    withName: "doc_name"
                )

                multipartData.append(
                    Data(docNumber.utf8),
                    withName: "doc_number"
                )

                multipartData.append(
                    Data(docType.utf8),
                    withName: "doc_type"
                )

                multipartData.append(
                    imageData,
                    withName: "doc_file",
                    fileName: "document.jpg",
                    mimeType: "image/jpeg"
                )

                print("✅ Multipart Form Created")

            },
            to: url,
            method: .post
        )
        .validate()
        .responseData { response in

            print("========================================")
            print("🌐 Response Received")

            print("Status Code:",
                  response.response?.statusCode ?? 0)

            switch response.result {

            case .success(let data):

                if let responseString = String(
                    data: data,
                    encoding: .utf8
                ) {

                    print("📦 Raw Response:")
                    print(responseString)
                }

                do {

                    guard let json =
                            try JSONSerialization.jsonObject(
                                with: data
                            ) as? [String: Any] else {

                        print("❌ Invalid JSON")

                        completion(false,
                                   "Invalid Response",
                                   nil)

                        return
                    }

                    let status =
                        json["status"] as? Bool ??
                        json["success"] as? Bool ??
                        false

                    let message =
                        json["message"] as? String ??
                        "Unknown"

                    print("✅ Success:", status)
                    print("💬 Message:", message)

                    completion(
                        status,
                        message,
                        json
                    )

                } catch {

                    print("🔥 JSON Parse Error")
                    print(error.localizedDescription)

                    completion(
                        false,
                        "Unable to upload Document",
                        nil
                    )
                }

            case .failure(let error):

                print("❌ Upload Failed")
                    print(error.localizedDescription)

                    var errorMessage = "Unable to upload Document"

                    if let data = response.data,
                       let body = String(data: data, encoding: .utf8) {

                        print("Response Body:")
                        print(body)

                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

                            errorMessage = json["message"] as? String ?? errorMessage
                        }
                    }

                    completion(
                        false,
                        errorMessage,
                        nil
                    )
            }

            print("========================================")
        }
    }
    
}
