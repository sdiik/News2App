//
//  DetailView.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    @EnvironmentObject var loadingManager: LoadingManager

    var body: some View {
        BasicView {
            GeometryReader { _ in
                VStack(spacing: 24) {
                    headerSection
                    contentSection
                    webSection
                }
                .padding(.horizontal)
            }
            .onAppear {
                viewModel.newsDetail()
            }
            .onChange(of: viewModel.isLoading) { newValue in
                loadingManager.isLoading = newValue
            }
        }
    }

    private var headerSection: some View {
        HStack {
            CustomImageView(viewModel: viewModel.logo)
            VStack(alignment: .leading, spacing: 8) {
                CustomTextView(viewModel: viewModel.title)
                CustomTextView(viewModel: viewModel.newsSite)
            }.padding(.leading, 8)
            Spacer()
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomTextView(viewModel: viewModel.date)
            CustomTextView(viewModel: viewModel.desc)
        }
    }

    private var webSection: some View {
        Group {
            if let url = viewModel.getNewsUrl() {
                WebView(url: url)
                    .frame(height: 500)
                    .id(url)
            }
        }
    }
}
