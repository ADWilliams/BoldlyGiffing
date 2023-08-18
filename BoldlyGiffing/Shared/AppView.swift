//
//  AppView.swift
//  BoldlyGiffing
//
//  Created by Aaron Williams on 2023-07-06.
//  Copyright © 2023 Sweet Software. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import XCTestDynamicOverlay

struct AppReducer: ReducerProtocol {
    @Dependency(\.APIClient) var apiClient
    
    struct State: Equatable {
        public var thumbnails: Thumbnails.State = .init()
    }
    
    
    enum Action: Equatable {
        case thumbnails(Thumbnails.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        
        Scope(state: \.thumbnails, action: /AppReducer.Action.thumbnails) {
            Thumbnails()
        }
        ._printChanges()
    }
}

struct AppView: View {
    let store: Store<AppReducer.State, AppReducer.Action>
    
    var body: some View {
        if !_XCTIsTesting {
            ThumbnailView(store: store.scope(state: \.thumbnails, action: AppReducer.Action.thumbnails))
                .padding(.horizontal, 8)
                .background(
                    Color.black
                )
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(),
                reducer: AppReducer()
            )
        )
    }
}
