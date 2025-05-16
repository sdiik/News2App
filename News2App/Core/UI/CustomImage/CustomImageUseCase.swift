//
//  CustomImageUseCase.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import Foundation
import SwiftUI

protocol CustomImageUseCase {
    func loadImage(from url: String) -> AsyncImagePhase
}

class CustomImageUseCaseImpl: CustomImageUseCase {
    func loadImage(from url: String) -> AsyncImagePhase {
        guard let imageURL = URL(string: url) else {
            return .failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
        }
        return .empty
    }
}
