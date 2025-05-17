//
//  SectionViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import Combine

class SectionViewModel: ObservableObject {
    @Published var title: CustomTextViewModel
    @Published var seeMore: CustomTextViewModel
    @Published var images: [CustomImageViewModel]
    @Published var blogs: [Blog] = []

    var onSeeMoreAction: (() -> Void)?

    init(blogs: [Blog] = [], onSeeMoreAction: (() -> Void)? = nil) {
        self.blogs = blogs
        title = CustomTextViewModel(config: Self.makeTitleConfigure())
        seeMore = CustomTextViewModel(config: Self.makeSeeMoreConfigure())
        images = blogs.map { blog in CustomImageViewModel(customImageModel: Self.makeImageConfigure(from: blog)) }
        self.onSeeMoreAction = onSeeMoreAction
    }

    func updateBlogs(_ blogs: [Blog]) {
        self.blogs = blogs
        images = blogs.map { blog in
            CustomImageViewModel(customImageModel: Self.makeImageConfigure(from: blog))
        }
    }

    private static func makeTitleConfigure() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "Section",
            titleColor: .black,
            aligment: .leading,
            textType: .large,
            isBold: true
        )
    }

    private static func makeSeeMoreConfigure() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "See More",
            titleColor: .orange,
            aligment: .trailing,
            textType: .large,
            isBold: true
        )
    }

    private static func makeImageConfigure(from blog: Blog) -> CustomImageModel {
        return CustomImageModel(
            url: blog.imageUrl ?? "",
            width: 100,
            height: 100
        )
    }

    func performSeeMoreAction() {
        onSeeMoreAction?()
    }
}
