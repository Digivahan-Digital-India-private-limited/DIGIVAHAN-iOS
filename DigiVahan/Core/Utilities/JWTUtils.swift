//
//  JWTUtils.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import Foundation

class JWTUtils {

    static func getUserIdFromToken(_ token: String?) -> String {

        let tag = "JWT_PARSE_TEST"

        do {

//            print("\(tag): Token received. Length = \(token?.count ?? 0)")

            guard let token = token, !token.isEmpty else {
//                print("\(tag): ❌ Token is nil or empty")
                return ""
            }

            let parts = token.components(separatedBy: ".")

//            print("\(tag): JWT parts count = \(parts.count)")

            guard parts.count > 1 else {
                print("\(tag): ❌ Invalid JWT format. Payload missing")
                return ""
            }

            var payload = parts[1]

//            print("\(tag): JWT payload (Base64) = \(payload)")

            // JWT Base64 URL Safe Fix
            payload = payload.replacingOccurrences(of: "-", with: "+")
            payload = payload.replacingOccurrences(of: "_", with: "/")

            while payload.count % 4 != 0 {
                payload += "="
            }

            guard let decodedData = Data(base64Encoded: payload),
                  let jsonString = String(data: decodedData, encoding: .utf8) else {

//                print("\(tag): ❌ Failed to decode payload")
                return ""
            }

//            print("\(tag): Decoded JWT payload JSON = \(jsonString)")

            guard let jsonData = jsonString.data(using: .utf8),
                  let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {

//                print("\(tag): ❌ Failed to parse JSON")
                return ""
            }

            guard let userId = jsonObject["userId"] as? String else {

//                print("\(tag): ❌ userId key not found in JWT payload")
                return ""
            }

//            print("\(tag): ✅ Extracted userId from token = \(userId)")

            return userId

        } catch {

//            print("\(tag): ❌ Exception while parsing JWT")
//            print(error.localizedDescription)

            return ""
        }
    }
}
