//
//  IntExtension.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

typealias HTTPStatusCode = Int

extension HTTPStatusCode {
    var isOk: Bool {
        return self >= 200 && self < 300
    }
}
