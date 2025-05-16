//
//  CustomTextFieldConfiguration.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Foundation

enum ValidationType {
    case email
    case password
    case none
}

struct CustomTextFieldConfiguration {
    let title: String
    let placeholder: String
    let isSecure: Bool
    let validationType: ValidationType
}
