//
//  HomeViewModel.swift
//  News2App
//
//  Created by ahmad shiddiq on 03/05/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var state: State

    let newsUseCase: FetchNewsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(newsUseCase: FetchNewsUseCase = FetchNewsUseCaseImpl()) {
        self.newsUseCase = newsUseCase
        state = State()
    }

    static func makeTitleConfigurate() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "Good Morning",
            titleColor: .black,
            aligment: .center,
            textType: .xlarge,
            isBold: true
        )
    }

    static func makeDescConfigurate() -> CustomTextConfiguration {
        return CustomTextConfiguration(
            title: "Tohari",
            titleColor: .black.opacity(0.4),
            aligment: .center,
            textType: .large
        )
    }

    private func fetchNews(for type: NewsType, completion: @escaping ([Blog]) -> Void) {
        newsUseCase.execute(type: type) { result in
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

    private func fetchArticle() {
        state.viewState = .loading
        fetchNews(for: .article) { [weak self] blogs in
            guard let self = self else { return }
            let updated = self.state.articelSection
            updated.updateBlogs(blogs)
            self.state = self.state.withUpdatedArticle(updated)
        }
    }

    private func fetchBlog() {
        state.viewState = .loading
        fetchNews(for: .blog) { [weak self] blogs in
            guard let self = self else { return }
            let updated = self.state.blogSection
            updated.updateBlogs(blogs)
            self.state = self.state.withUpdatedBlog(updated)
        }
    }

    private func fetchReport() {
        state.viewState = .loading
        fetchNews(for: .report) { [weak self] blogs in
            guard let self = self else { return }
            let updated = self.state.reportSection
            updated.updateBlogs(blogs)
            self.state = self.state.withUpdatedReport(updated)
        }
    }

    func send(_ action: Action) {
        switch action {
        case .LoadArticel:
            fetchArticle()
        case .LoadBlog:
            fetchBlog()
        case .LoadReport:
            fetchReport()
        }
    }
}
