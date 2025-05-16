//
//  CustomImageView.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import SwiftUI

struct CustomImageView: View {
    @ObservedObject var viewModel: CustomImageViewModel
    
    var body: some View {
        AsyncImage(url: URL(string: viewModel.customImageModel.url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: viewModel.customImageModel.width, height: viewModel.customImageModel.height)
                    .clipped()
            case .failure(let error):
                Image(systemName: "icon_news")
                    .resizable()
                    .scaledToFit()
                    .frame(width: viewModel.customImageModel.width, height: viewModel.customImageModel.height)
                    .clipped()
            @unknown default:
                EmptyView()
            }
        }
        .onAppear {
            viewModel.loading()
        }
    }
}
