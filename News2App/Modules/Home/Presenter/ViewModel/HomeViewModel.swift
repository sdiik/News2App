//
//  HomeViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var title: CustomTextViewModel
    @Published var desc: CustomTextViewModel
    @Published var articelSection: SectionViewModel
    @Published var blogSection: SectionViewModel
    @Published var reportSection: SectionViewModel
    @Published var isLoading: Bool = false

    let newsUseCase: FetchNewsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(newsUseCase: FetchNewsUseCase = FetchNewsUseCaseImpl()) {
        self.newsUseCase = newsUseCase
        title = CustomTextViewModel(config: Self.makeTitleConfigurate())
        desc = CustomTextViewModel(config: Self.makeDescConfigurate())
        articelSection = SectionViewModel()
        blogSection = SectionViewModel()
        reportSection = SectionViewModel()
    }

    private static func makeTitleConfigurate() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "Good Morning",
            titleColor: .black,
            aligment: .center,
            textType: .xlarge,
            isBold: true
        )
    }

    private static func makeDescConfigurate() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "Tohari",
            titleColor: .black.opacity(0.4),
            aligment: .center,
            textType: .large
        )
    }

    private func fetchNews(for type: NewsType, completion: @escaping ([Blog]) -> Void) {
        newsUseCase.execute(type: type) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    completion(response.results ?? [])
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func fetchAllNews() {
        isLoading = true

        let group = DispatchGroup()

        group.enter()
        fetchNews(for: .article) { [weak self] blogs in
            print("-----blogs 1--------\(blogs)")
            self?.articelSection.updateBlogs(blogs)
            group.leave()
        }

        group.enter()
        fetchNews(for: .blog) { [weak self] blogs in
            print("-----blogs 2--------\(blogs)")
            self?.blogSection.updateBlogs(blogs)
            group.leave()
        }

        group.enter()
        fetchNews(for: .report) { [weak self] blogs in
            print("-----blogs 3--------\(blogs)")
            self?.reportSection.updateBlogs(blogs)
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }
}
