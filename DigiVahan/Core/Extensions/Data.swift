//
//  Data.swift
//  DigiVahan
//
//  Created by Mr Ash on 16/06/26.
//

import Foundation

extension Data {

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
