//
//  FirstTabView.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

struct FirstTabFeature: Reducer {
    struct State: Equatable {}
    enum Action: Equatable {
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
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .delegate:
            return .none
            
        case .goToInventoryButtonTapped:
            // don't send action in sync fashion better of use helper method to perform these task.
            return .send(.delegate(.swithtoInventoryTab))
        }
    }
}

struct FirstTabView: View {
    let store: StoreOf<FirstTabFeature>
    
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

//struct FirstTab_Previews: PreviewProvider {
//    static var previews: some View {
//        FirstTabView(store: Store(initialState: FirstTabFeature.State(), reducer: FirstTabFeature.State())
//        )
//    }
//}
