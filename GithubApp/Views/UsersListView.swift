//
//  UsersListView.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import SwiftUI
import ComposableArchitecture

struct UsersListView: View {
    @Bindable var store: StoreOf<UsersListFeature>
    
    var body: some View {
        NavigationStack {
            List {
                switch(store.state.usersListViewState) {
                case .loading:
                    loadingView
                case .loaded:
                    loadedView
                    loadMoreButton
                case .error(let userListError):
                    errorView(error: userListError)
                }
            }
            .navigationTitle("Github Users List")
            .refreshable {
                store.send(.refreshIsPulled)
            }
        }
        .sheet(
            item: $store.scope(state: \.userDetailFeature, action: \.userDetailPresented)
        ) { userDetailStore in
            NavigationStack {
                UserDetailsView(store: userDetailStore)
            }
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                store.send(.refreshIsPulled)
            }
    }
    
    func errorView(error: UsersListFeature.UsersListError) -> some View {
        return HStack {
            Spacer()
            Text(error.message).multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    var loadedView: some View {
        ForEach(store.users) { user in
            HStack {
                AvatarAsyncImage(imageUrl: user.avatarImage)
                    .frame(width: 50, height: 50)
                Text(user.username)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                store.send(.userIsTapped(user))
            }
        }
    }
    
    var loadMoreButton: some View {
        HStack {
            Spacer()
            switch(store.state.loadMoreViewState) {
            case .idle:
                Button {
                    store.send(.loadMoreIsTapped)
                } label: {
                    Text("Load More")
                }
            case .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .hidden:
                Text("End of list.")
            }
            Spacer()
        }
    }
}

#Preview {
    UsersListView(
        store: Store.init(
            initialState: UsersListFeature.State(
                users: UserModel.mockUsersArray
            ),
            reducer: {
                UsersListFeature()
            }
        )
    )
}
