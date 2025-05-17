//
//  HomeView.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var loadingManager: LoadingManager

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        ScrollView {
            BasicView {
                VStack(spacing: 16) {
                    headerSection
                    bodySection
                }
                .onChange(of: viewModel.state.viewState == .loading) { newValue in
                    loadingManager.isLoading = newValue
                }
            }
        }
        .onAppear {
            viewModel.send(.LoadArticel)
            viewModel.send(.LoadBlog)
            viewModel.send(.LoadReport)
        }
        .refreshable {
            viewModel.send(.LoadArticel)
            viewModel.send(.LoadBlog)
            viewModel.send(.LoadReport)
        }
        .navigationBarHidden(true)
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            CustomTextView(viewModel: viewModel.state.title)
            CustomTextView(viewModel: viewModel.state.desc)
        }
    }

    @ViewBuilder
    private var bodySection: some View {
        VStack(spacing: 8) {
            if !viewModel.state.articelSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.state.articelSection)
            }
            if !viewModel.state.blogSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.state.blogSection)
            }

            if !viewModel.state.reportSection.blogs.isEmpty {
                SectionView(viewModel: viewModel.state.reportSection)
            }
        }
    }
}
