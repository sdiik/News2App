//
//  SectionView.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import SwiftUI

struct SectionView: View {
    @ObservedObject var viewModel: SectionViewModel

    var body: some View {
        VStack {
            sectionHeader
            sectionBody
        }
    }

    @ViewBuilder
    private var sectionHeader: some View {
        HStack {
            CustomTextView(viewModel: viewModel.title)
            Spacer()
            Button {
                viewModel.performSeeMoreAction()
            } label: {
                CustomTextView(viewModel: viewModel.seeMore)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var sectionBody: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.blogs.indices, id: \.self) { index in
                    CustomImageView(viewModel: viewModel.images[index])
                }
            }
        }
    }
}
