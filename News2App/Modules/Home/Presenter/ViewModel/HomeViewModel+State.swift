//
//  HomeViewModel+State.swift
//  News2App
//
//  Created by ahmad shiddiq on 17/05/25.
//

extension HomeViewModel {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    struct State {
        var articelSection: SectionViewModel = SectionViewModel()
        var blogSection: SectionViewModel = SectionViewModel()
        var reportSection: SectionViewModel = SectionViewModel()
        var title: CustomTextViewModel = CustomTextViewModel(config: makeTitleConfigurate())
        var desc: CustomTextViewModel = CustomTextViewModel(config: makeDescConfigurate())
        var viewState: ViewState = .loading
    }

    enum Action {
        case LoadArticel
        case LoadBlog
        case LoadReport
    }
}

extension HomeViewModel.State {
    func withUpdatedArticle(_ new: SectionViewModel) -> Self {
        .init(
            articelSection: new,
            blogSection: blogSection,
            reportSection: reportSection,
            viewState: viewState
        )
    }

    func withUpdatedBlog(_ new: SectionViewModel) -> Self {
        .init(
            articelSection: articelSection,
            blogSection: new,
            reportSection: reportSection,
            viewState: viewState
        )
    }

    func withUpdatedReport(_ new: SectionViewModel) -> Self {
        .init(
            articelSection: articelSection,
            blogSection: blogSection,
            reportSection: new,
            viewState: viewState
        )
    }

    func withUpdatedViewState(_ newState: HomeViewModel.ViewState) -> Self {
        .init(
            articelSection: articelSection,
            blogSection: blogSection,
            reportSection: reportSection,
            viewState: newState
        )
    }
}
