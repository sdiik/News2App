//
//  CustomImageViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import SwiftUI

class CustomImageViewModel: ObservableObject {
    @Published var customImageModel: CustomImageModel
    private let imageLoadingUseCase: CustomImageUseCase

    init(
        customImageModel: CustomImageModel,
        imageLoadingUseCase: CustomImageUseCase = CustomImageUseCaseImpl()
    ) {
        self.customImageModel = customImageModel
        self.imageLoadingUseCase = imageLoadingUseCase
    }

    func loading() {
        customImageModel.imagePhase = imageLoadingUseCase.loadImage(from: customImageModel.url)
    }

    func updateConfiguration(_ url: String) {
        customImageModel.url = url
    }
}
