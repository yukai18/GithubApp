//
//  UsersListFeatureTest.swift
//  GithubAppTests
//
//  Created by Yukai on 2024/03/28.
//

import ComposableArchitecture
import XCTest
@testable import GithubApp

@MainActor
final class UsersListFeatureTest: XCTestCase {
    func testRefresh() async {
        let store = TestStore(initialState: UsersListFeature.State()) {
            UsersListFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUsersList = { _ in
                return UserModel.mockUsersArray
            }
        }
        
        /// Since we are testing refresh action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Assert if initial view state should be in loading state
        store.assert { state in
            state.usersListViewState = .loading
        }
        
        /// Simulate user pulling the list to refresh
        await store.send(.refreshIsPulled)
        
        /// Skipping to check APIs actions as we are only interested in the final state changes
        await store.skipReceivedActions()
        
        /// Asserting users array contains the same mock response from API
        store.assert { state in
            state.usersListViewState = .loaded
            state.users = UserModel.mockUsersArray
        }
    }
    
    func testLoadMore() async {
        /// Simulating already loaded state to test load more flow
        let store = TestStore(
            initialState: UsersListFeature.State(
                usersListViewState: .loaded,
                users: UserModel.mockUsersArray)
        ) {
            UsersListFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUsersList = { lastUserId in
                /// Increment the last user id to return the next available one when load more is tapped
                let nextUserId = lastUserId + 1
                return [UserModel(id: nextUserId, username: "Jane Doe", avatarImage: "")]
            }
        }
        
        /// Since we are testing load more action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Asserting initial state for load more
        store.assert { state in
            state.loadMoreViewState = .idle
        }
        
        await store.send(.loadMoreIsTapped) { state in
            state.loadMoreViewState = .loading
        }
        /// Skipping API actions
        await store.skipReceivedActions()
        
        store.assert { state in
            state.loadMoreViewState = .idle
            
            let nextUserId = UserModel.mockUsersArray.last!.id + 1
            let newUser = UserModel(id: nextUserId, username: "Jane Doe", avatarImage: "")
            
            var newUsersList = UserModel.mockUsersArray
            newUsersList.append(newUser)
            
            state.users = newUsersList
        }
    }
    
    func testEmptyList() async {
        let store = TestStore(initialState: UsersListFeature.State()) {
            UsersListFeature()
        } withDependencies: { client in
            /// Generating mock response from API
            client.githubClient.getUsersList = { _ in
                return []
            }
        }
        
        /// Since we are testing refresh action as a whole, we don't need to be verbos on each action effects
        store.exhaustivity = .off
        
        /// Assert if initial view state should be in loading state
        store.assert { state in
            state.usersListViewState = .loading
        }
        
        /// Simulate user pulling the list to refresh
        await store.send(.refreshIsPulled)
        
        /// Skipping to check APIs actions as we are only interested in the final state changes
        await store.skipReceivedActions()
        
        store.assert { state in
            state.usersListViewState = .error(.listIsEmptyError)
            state.users = []
        }
    }
    
    func testUserIsTapped() async {
        /// Simulating already loaded state to test user tap flow
        let store = TestStore(
            initialState: UsersListFeature.State(
                usersListViewState: .loaded,
                users: UserModel.mockUsersArray)
        ) {
            UsersListFeature()
        }
        
        /// Simulate tapping the first user in the list
        await store.send(.userIsTapped(UserModel.mockUsersArray[0])) { state in
            state.userDetailFeature = UserDetailsFeature.State(
                userModel: UserModel.mockUsersArray[0]
            )
        }
    }
}
