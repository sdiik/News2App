//
//  DecodeHelper.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

func decode(jwtToken jwt: String) -> [String: Any] {
    let segments = jwt.components(separatedBy: ".")
    guard segments.count > 1 else { return [:] }
    
    var base64String = segments[1]
    let requiredLength = (4 * ceil(Double(base64String.count) / 4.0))
    let paddingLength = requiredLength - Double(base64String.count)
    if paddingLength > 0 {
        base64String += String(repeating: "=", count: Int(paddingLength))
    }
    
    guard let decodedData = Data(base64Encoded: base64String),
          let json = try? JSONSerialization.jsonObject(with: decodedData) as? [String: Any] else {
        return [:]
    }
    return json
}
