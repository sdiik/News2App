//
//  CustomTextConfiguration.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

enum TextType {
    case xlarge
    case large
    case medium
    case small
    case xsmall
}

struct CustomTextConfiguration {
    var title: String = ""
    var titleColor: Color
    var aligment: TextAlignment = .leading
    var numberLine: Int? = nil
    var textType: TextType = .medium
    var isBold: Bool = false
}
