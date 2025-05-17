//
//  HomeView.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var loadingManager: LoadingManager

    var it: String = ""

    var item2     : String  = ""

    var body: some View {
        ScrollView {
            BasicView {
                VStack(spacing: 16) {
                    headerSection
                    bodySection
                }
                .onChange(of: viewModel.isLoading) { newValue in
                    loadingManager.isLoading = newValue
                }
            }
        }
        .onAppear {
            viewModel.fetchAllNews()
        }
        .refreshable {
            viewModel.fetchAllNews()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            CustomTextView(viewModel: viewModel.title)
            CustomTextView(viewModel: viewModel.desc)
        }
    }

    private var bodySection: some View {
        VStack(spacing: 8) {
            if !viewModel.articelSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.articelSection)
            }
            if !viewModel.blogSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.blogSection)
            }

            if !viewModel.reportSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.reportSection)
            }
        }
    }
}
