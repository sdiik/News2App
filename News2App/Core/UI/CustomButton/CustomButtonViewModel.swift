//
//  CustonButtonViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine

class CustomButtonViewModel: ObservableObject {
    @Published var config: CustomButtonConfiguration
    @Published var titleButton: CustomTextViewModel
    
    init(config: CustomButtonConfiguration) {
        self.config = config
        self.titleButton = CustomTextViewModel(config: Self.makeTextButtonConfig(with: config.title))
    }
    
    func performAction() {
        guard !config.isDisabled else { return }
        config.action()
    }
    
    private static func makeTextButtonConfig(with title: String) -> CustomTextConfiguration {
          return CustomTextConfiguration(
            title: title,
            titleColor: .white,
            textType: .xlarge,
            isBold: true
          )
      }
}
