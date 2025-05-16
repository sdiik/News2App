//
//  CustomButtonVIew.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct CustomButtonView: View {
    @ObservedObject var viewModel: CustomButtonViewModel
    
    var body: some View {
        Button {
            viewModel.performAction()
        } label: {
            HStack {
                if viewModel.config.isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                CustomTextView(viewModel: viewModel.titleButton)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.config.isDisabled ? Color.gray : viewModel.config.backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.config.isDisabled)
    }
}
