//
//  DetailViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 30/04/25.
//

import Combine
import SwiftUICore

class DetailViewModel: ObservableObject {
    @EnvironmentObject var coordinator: AppCoordinator

    @Published var title: CustomTextViewModel
    @Published var newsSite: CustomTextViewModel
    @Published var desc: CustomTextViewModel
    @Published var date: CustomTextViewModel
    @Published var logo: CustomImageViewModel
    @Published var isLoading: Bool = false

    private var id: Int
    private var detailType: DetailType
    private let detailUseCase: DetailUseCase

    @Published var detail: Blog? {
        didSet {
            updateData()
        }
    }

    init(
        id: Int,
        detailType: DetailType,
        detailUseCase: DetailUseCase = DetailUseCaseImpl()
    ) {
        self.id = id
        self.detailType = detailType
        self.detailUseCase = detailUseCase
        title = CustomTextViewModel(config: Self.makeTitleConfig())
        newsSite = CustomTextViewModel(config: Self.makeNewsSiteConfig())
        desc = CustomTextViewModel(config: Self.makeDescConfig())
        date = CustomTextViewModel(config: Self.makeDateConfig())
        logo = CustomImageViewModel(customImageModel: Self.makeLogoConfig())
    }

    private static func makeTitleConfig() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            titleColor: .black,
            aligment: .leading,
            textType: .large,
            isBold: true
        )
    }

    private static func makeNewsSiteConfig() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            titleColor: .black,
            aligment: .leading,
            textType: .medium,
            isBold: false
        )
    }

    private static func makeDescConfig() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            titleColor: .black.opacity(0.4),
            aligment: .leading,
            textType: .medium
        )
    }

    private static func makeDateConfig() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            titleColor: .black.opacity(0.4),
            aligment: .leading,
            textType: .medium
        )
    }

    private static func makeLogoConfig() -> CustomImageModel {
        return CustomImageModel(
            width: 80,
            height: 80
        )
    }

    private func updateData() {
        guard let detail = detail else { return }
        title.config.title = detail.title
        newsSite.config.title = detail.newsSite ?? "-"
        desc.config.title = getSummarySentence(from: detail.summary)
        date.config.title = formatDate(detail.publishedAt ?? "-")
        logo.customImageModel.url = detail.imageUrl ?? ""
    }

    func newsDetail() {
        isLoading = true
        detailUseCase.execute(
            with: id,
            detailType: detailType
        ) { result in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                guard let self = self else { return }
                switch result {
                case let .success(detail):
                    self.detail = detail
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func getNewsUrl() -> URL? {
        guard let url = detail?.url else { return nil }
        return URL(string: url)
    }
}
