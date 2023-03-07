//
//  YourDetail.swift
//  Inventory
//
//  Created by Akash soni on 07/03/23.
//

import Dependencies
import DependenciesAdditionsBasics
import SwiftUI
import UserNotificationsDependency
import UserNotifications
import ComposableArchitecture

struct YourDetailFeature: Reducer {
    struct State: Equatable {
        var status: UNAuthorizationStatus = .notDetermined
    }
    enum Action: Equatable {
        case viewWillAppear
        case goToInventoryButtonTapped
        case delegate(Delegate)
    }
    /// The parent domain shouldn’t be responsible for listening to all of those different events to figure out when to mutate the selectedTab state.
    /// Instead, it would be far preferable if the child domain could clearly communicate when it wants the parent to switch to the inventory tab.
    /// There is lightweight pattern to accomplish this, and it’s something we did in our open source word game, isowords, and we have used the pattern in client projects too.
    /// The idea is for the child feature to carve out a little space in its Action enum for describing commands for the parent feature to interpret. We will do this by introducing a nested “delegate” action enum:
    /// To sum up :-
    //** delegate action are thoes that a parent reducer may care about. ** //

    enum Delegate: Equatable {
     case swithtoInventoryTab
    }
    
    @Dependency(\.userNotificationCenter) var userNotificationCenter
    @Dependency(\.uuid) var uuid

    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewWillAppear:
            return .none

        case .delegate:
            return .none
            
        case .goToInventoryButtonTapped:
            // don't send action in sync fashion better of use helper method to perform these task.
            return .send(.delegate(.swithtoInventoryTab))
        }
        
    }
}

struct YourDetailView: View {
    let store: StoreOf<YourDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.goToInventoryButtonTapped)
            } label: {
                Text("Go to inventory tab")
            }

        }
    }
}

struct YourDetail_Previews: PreviewProvider {
    static var previews: some View {
        YourDetailView(store: Store(initialState: YourDetailFeature.State(), reducer: YourDetailFeature()))
    }
}
