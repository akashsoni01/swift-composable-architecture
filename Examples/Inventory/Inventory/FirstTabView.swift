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
    }
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .goToInventoryButtonTapped:
            return .none
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
