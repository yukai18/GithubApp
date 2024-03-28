//
//  UsersList.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct UsersListFeature {
    @ObservableState
    struct State: Equatable {
        // View state for user's list
        var usersListViewState: UsersListViewState = .loading
        // View state for load more button
        var loadMoreViewState: LoadMoreViewState = .idle
        // List of users
        var users: [UserModel] = []
        // Navigation modal for user details screen
        @Presents var userDetailFeature: UserDetailsFeature.State?
    }
    
    enum Action {
        // View's actions
        case userDetailPresented(PresentationAction<UserDetailsFeature.Action>)
        
        // User's actions
        case refreshIsPulled
        case loadMoreIsTapped
        case userIsTapped(UserModel)
        
        // API's actions
        case getUsersList(Int)
        case getUsersListResponse([UserModel])
        case getUsersListResponseError
    }
    
    enum UsersListViewState: Equatable {
        case loading, loaded, error(UsersListError)
    }
    
    enum LoadMoreViewState: Equatable {
        case idle, loading, hidden
    }
    
    enum UsersListError {
        case noLastUserIdShownError,
             getUsersListError,
             listIsEmptyError
        
        var message: String {
            switch self {
            case .noLastUserIdShownError:
                return "Last User Id not Found"
            case .getUsersListError:
                return "Something went wrong when fetching the list. Please try again later"
            case .listIsEmptyError:
                return "No users found."
            }
        }
    }
    
    @Dependency(\.githubClient) var githubClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .userDetailPresented:
                return .none
            case .refreshIsPulled:
                state.usersListViewState = .loading
                return .run { send in
                    await send(.getUsersList(0))
                }
            case .loadMoreIsTapped:
                guard
                    let lastUserIdShown = state.users.last?.id
                else {
                    /// Ideally it should not arrive here, as load more button will be hidden if user list is empty
                    state.usersListViewState = .error(.noLastUserIdShownError)
                    return .none
                }
                state.loadMoreViewState = .loading
                return .run { send in
                    await send(.getUsersList(lastUserIdShown))
                }
            case .userIsTapped(let user):
                state.userDetailFeature = UserDetailsFeature.State(userModel: user)
                return .none
            case .getUsersList(let lastUserIdShown):
                return .run { send in
                    try await send(.getUsersListResponse(self.githubClient.getUsersList(lastUserIdShown)))
                } catch: { error, send in
                    print(String(describing: error))
                    await send(.getUsersListResponseError)
                }
            case .getUsersListResponse(let users):
                if users.isEmpty {
                    /// When the list is empty from refresh, we show an error message.
                    if case .loading = state.usersListViewState {
                        state.usersListViewState = .error(.listIsEmptyError)
                    }
                    /// When the list is empty from tapping load more, we hide load more button
                    if case .loading = state.loadMoreViewState {
                        state.loadMoreViewState = .hidden
                    }
                } else {
                    if case .loading = state.usersListViewState {
                        state.users = users
                        state.usersListViewState = .loaded
                    }
                    if case .loading = state.loadMoreViewState {
                        state.users.append(contentsOf: users)
                        state.loadMoreViewState = .idle
                    }
                }
                return .none
            case .getUsersListResponseError:
                /// When the response has error from refresh, we show an error message.
                if case .loading = state.usersListViewState {
                    state.usersListViewState = .error(.getUsersListError)
                }
                /// When the response has error from tapping load more, we show load more button again
                if case .loading = state.loadMoreViewState {
                    state.loadMoreViewState = .idle
                }
                return .none
            }
        }
        .ifLet(\.$userDetailFeature, action: \.userDetailPresented) {
            UserDetailsFeature()
        }
    }
}
