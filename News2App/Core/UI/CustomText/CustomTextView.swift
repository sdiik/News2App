//
//  CustomTextView.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct CustomTextView: View {
    @ObservedObject var viewModel: CustomTextViewModel
    
    var body: some View {
        Text(viewModel.config.title)
            .font(viewModel.getFontStyle())
            .foregroundColor(viewModel.config.titleColor)
            .multilineTextAlignment(viewModel.config.aligment)
            .lineLimit(viewModel.config.numberLine)
    }
}
