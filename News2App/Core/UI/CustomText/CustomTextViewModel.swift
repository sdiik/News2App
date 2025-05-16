//
//  CustomTextViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine
import SwiftUI

class CustomTextViewModel: ObservableObject {
    @Published var config: CustomTextConfiguration
    
    init(config: CustomTextConfiguration) {
        self.config = config
    }
    
    func getFontStyle() -> Font {
        var fontSize: CGFloat = 8
        switch config.textType {
        case .xlarge:
            fontSize = 18
        case .large:
            fontSize = 16
        case .medium:
            fontSize = 14
        case .small:
            fontSize = 12
        case .xsmall:
            fontSize = 10
        }
        return Font.system(size: fontSize, weight: config.isBold ? .bold : .regular, design: .default)
    }
}
