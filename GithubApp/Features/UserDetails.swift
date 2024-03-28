//
//  UserDetails.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct UserDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let userModel: UserModel
        var userDetails: UserDetailModel = UserDetailModel.mockUserDetail
        var repositories: [RepositoryModel] = []
        var currentRepositoryPage = 1

        // View state for user's repository list
        var repositoryListViewState: RepositoryListViewState = .loading
        // View state for load more button
        var loadMoreViewState: LoadMoreViewState = .idle
        // Navigation modal for web view screen
        @Presents var webview: WebFeature.State?
    }
    
    enum Action {
        // View's actions
        case webViewPresented(PresentationAction<WebFeature.Action>)
        
        // User's action
        case refreshIsPulled
        case loadMoreIsTapped
        case repositoryTapped(String)
        case cancelButtonTapped
        
        // API's action
        case getUserDetail
        case getUserDetailResponse(UserDetailModel)
        case getUserRepositories
        case getUserRepositoriesResponse([RepositoryModel])
        case getUserRepositoriesError
    }
    
    enum RepositoryListViewState: Equatable {
        case loading, loaded, error(RepositoryListError)
    }
    
    enum LoadMoreViewState: Equatable {
        case idle, loading, hidden
    }
    
    enum RepositoryListError {
        case getRepositoryListError,
             listIsEmptyError
        
        var message: String {
            switch self {
            case .getRepositoryListError:
                return "Something went wrong when fetching the list. Please try again later"
            case .listIsEmptyError:
                return "No repositories found."
            }
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.githubClient) var githubClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .refreshIsPulled:
                state.repositoryListViewState = .loading
                state.currentRepositoryPage = 1
                return .run { send in
                    await send(.getUserRepositories)
                }
            case .loadMoreIsTapped:
                state.loadMoreViewState = .loading
                state.currentRepositoryPage += 1
                return .run { send in
                    await send(.getUserRepositories)
                }
            case .repositoryTapped(let urlString):
                state.webview = WebFeature.State(urlString: urlString)
                return .none
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .getUserDetail:
                let username = state.userModel.username
                return .run { send in
                    try await send(.getUserDetailResponse(self.githubClient.getUserDetail(username)))
                } catch: { error, send in
                    print(String(describing: error))
                }
            case .getUserDetailResponse(let userDetails):
                state.userDetails = userDetails
                return .none
            case .getUserRepositories:
                let username = state.userModel.username
                let page = state.currentRepositoryPage
                return .run { send in
                    try await send(.getUserRepositoriesResponse(self.githubClient.getUserRepositories(username, page)))
                } catch: { error, send in
                    print(String(describing: error))
                    await send(.getUserRepositoriesError)
                }
                
            case .getUserRepositoriesResponse(let repos):
                if repos.isEmpty {
                    /// When the list is empty from refresh, we show an error message.
                    if case .loading = state.repositoryListViewState {
                        state.repositoryListViewState = .error(.listIsEmptyError)
                    }
                    /// When the list is empty from tapping load more, we hide load more button
                    if case .loading = state.loadMoreViewState {
                        state.loadMoreViewState = .hidden
                    }
                } else {
                    if case .loading = state.repositoryListViewState {
                        state.repositories = repos
                        state.repositoryListViewState = .loaded
                    }
                    if case .loading = state.loadMoreViewState {
                        state.repositories.append(contentsOf: repos)
                        state.loadMoreViewState = .idle
                    }
                }
                return .none
            case .getUserRepositoriesError:
                /// When the response has error from refresh, we show an error message.
                if case .loading = state.repositoryListViewState {
                    state.repositoryListViewState = .error(.getRepositoryListError)
                }
                /// When the response has error from tapping load more, we show load more button again
                if case .loading = state.loadMoreViewState {
                    state.loadMoreViewState = .idle
                }
                return .none
            case .webViewPresented:
                return .none
            }
        }
        .ifLet(\.$webview, action: \.webViewPresented) {
            WebFeature()
        }
    }
}
