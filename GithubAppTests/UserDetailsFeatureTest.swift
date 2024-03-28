//
//  UserDetailsFeatureTest.swift
//  GithubAppTests
//
//  Created by Yukai on 2024/03/28.
//

import XCTest
import ComposableArchitecture
@testable import GithubApp

@MainActor
final class UserDetailsFeatureTest: XCTestCase {
    func testRefresh() async {
        let store = TestStore(initialState: UserDetailsFeature.State(
            userModel: UserModel.mockUsersArray[0]
        )) {
            UserDetailsFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUserDetail = { _ in
                return UserDetailModel.mockUserDetail
            }
            
            client.githubClient.getUserRepositories = { _, _ in
                return RepositoryModel.mockRepositoryArray
            }
        }
        
        /// Since we are testing refresh action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Assert if initial view state should be in loading state
        store.assert { state in
            state.repositoryListViewState = .loading
        }
        
        /// Simulate user pulling the repository list to refresh
        await store.send(.refreshIsPulled)
        
        /// Skipping to check APIs actions as we are only interested in the final state changes
        await store.skipReceivedActions()
        
        /// Asserting repository array contains the same mock response from API
        store.assert { state in
            state.userDetails = UserDetailModel.mockUserDetail
            state.repositoryListViewState = .loaded
            state.repositories = RepositoryModel.mockRepositoryArray
        }
    }
    
    func testLoadMoreRepository() async {
        /// Simulating already loaded state to test load more flow
        let store = TestStore(
            initialState: UserDetailsFeature.State(
                userModel: UserModel.mockUsersArray[0],
                userDetails: UserDetailModel.mockUserDetail,
                repositories: RepositoryModel.mockRepositoryArray,
                repositoryListViewState: .loaded
            )
        ) {
            UserDetailsFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUserDetail = { _ in
                return UserDetailModel.mockUserDetail
            }
            
            client.githubClient.getUserRepositories = { _, _ in
                return [RepositoryModel(
                    id: 4,
                    isForked: false,
                    name: "Mock Repo",
                    language: "Swift",
                    stars: 3,
                    description: "A mock repo",
                    urlString: "https://google.com")]
            }
        }
        
        /// Since we are testing load more action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Asserting initial state for load more
        store.assert { state in
            state.loadMoreViewState = .idle
            state.currentRepositoryPage = 1
        }
        
        await store.send(.loadMoreIsTapped) { state in
            state.loadMoreViewState = .loading
        }
        /// Skipping API actions
        await store.skipReceivedActions()
        
        store.assert { state in
            state.loadMoreViewState = .idle

            let newRepo = RepositoryModel(
                id: 4,
                isForked: false,
                name: "Mock Repo",
                language: "Swift",
                stars: 3,
                description: "A mock repo",
                urlString: "https://google.com")
            
            var newRepoList = RepositoryModel.mockRepositoryArray
            newRepoList.append(newRepo)
            
            state.repositories = newRepoList
            state.currentRepositoryPage = 2
        }
    }
    
    func testEmptyList() async {
        let store = TestStore(initialState: UserDetailsFeature.State(
            userModel: UserModel.mockUsersArray[0]
        )) {
            UserDetailsFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUserRepositories = { _, _ in
                return []
            }
        }
        
        /// Since we are testing refresh action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Assert if initial view state should be in loading state
        store.assert { state in
            state.repositoryListViewState = .loading
        }
        
        /// Simulate user pulling the list to refresh
        await store.send(.refreshIsPulled)
        
        /// Skipping to check APIs actions as we are only interested in the final state changes
        await store.skipReceivedActions()
        
        store.assert { state in
            state.repositoryListViewState = .error(.listIsEmptyError)
            state.repositories = []
        }
    }
    
    func testRepositoryIsTapped() async {
        /// Simulating already loaded state to test repository tap flow
        let store = TestStore(
            initialState: UserDetailsFeature.State(
                userModel: UserModel.mockUsersArray[0],
                repositories: RepositoryModel.mockRepositoryArray,
                repositoryListViewState: .loaded)
        ) {
            UserDetailsFeature()
        }
        
        /// Simulate tapping the first repository in the list
        await store.send(.repositoryTapped(RepositoryModel.mockRepositoryArray[0].urlString)) { state in
            state.webview = WebFeature.State(
                urlString: RepositoryModel.mockRepositoryArray[0].urlString
            )
        }
    }

}
