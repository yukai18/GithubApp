//
//  UserDetailsView.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/25.
//

import SwiftUI
import ComposableArchitecture

struct UserDetailsView: View {
    @Bindable var store: StoreOf<UserDetailsFeature>
    
    var body: some View {
        VStack(alignment: .leading) {
            userDetailView
            Divider()
                .frame(height: 3)
                .overlay(.black)
                .padding(.top, 4)
            VStack(alignment: .leading) {
                Text("Repositories")
                    .font(.largeTitle)
                    .bold()
                List {
                    switch(store.state.repositoryListViewState) {
                    case .loading:
                        repositoryLoadingView
                    case .loaded:
                        repositoryLoadedView
                        loadMoreButton
                    case .error(let error):
                        errorView(error: error)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    store.send(.refreshIsPulled)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
        .padding(.horizontal, 16)
        .interactiveDismissDisabled()
        .sheet(
            item: $store.scope(state: \.webview, action: \.webViewPresented)
        ) { store in
            NavigationStack {
                WebView(store: store)
            }
        }
    }
    
    var userDetailView: some View {
        HStack(alignment: .center) {
            AvatarAsyncImage(imageUrl: store.state.userModel.avatarImage)
                .frame(width: 100, height: 100)
                .onAppear {
                    store.send(.getUserDetail)
                }
            VStack(alignment: .leading) {
                if let name = store.state.userDetails.name {
                    Text(name)
                        .font(.headline)
                        .bold()
                }
                Text(store.state.userModel.username)
                    .font(.subheadline)
                HStack {
                    Text("\(store.state.userDetails.followers)")
                    Text("FOLLOWERS")
                        .padding(.leading, 2)
                    Text("\(store.state.userDetails.following)")
                        .padding(.leading, 8)
                    Text("FOLLOWING")
                        .padding(.leading, 2)
                }
                .font(.caption)
                .padding(.top, 8)
            }
            .padding(.leading, 8)
        }
    }
    
    var repositoryLoadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                store.send(.getUserRepositories)
            }
    }
    
    func errorView(error: UserDetailsFeature.RepositoryListError) -> some View {
        return HStack {
            Spacer()
            Text(error.message).multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    var repositoryLoadedView: some View {
        ForEach(store.state.repositories.filter { !$0.isForked }) { repo in
            VStack(alignment: .leading) {
                HStack {
                    Text("\(repo.name)")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Text("\(repo.stars)")
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                if let language = repo.language {
                    Text("Language: \(language)")
                        .font(.caption)
                }
                
                if let details = repo.description {
                    Text(details)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                store.send(.repositoryTapped(repo.urlString))
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
                        .foregroundStyle(.blue)
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
    UserDetailsView(
        store: Store.init(
            initialState: UserDetailsFeature.State(
                userModel: UserModel.mockUsersArray[0],
                repositories: RepositoryModel.mockRepositoryArray
            ),
            reducer: {
                UserDetailsFeature()
            }
        )
    )
}
