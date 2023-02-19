//
//  ContentView.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

struct AppFeature: Reducer {
    struct State {
        var firstTab = FirstTabFeature.State()
        var inventory = InventoryFeature.State()
        var thirdTab = ThirdTabFeature.State()
        var selectedTab: Tab = .one
    }
    enum Action {
        case firstTab(FirstTabFeature.Action)
        case inventory(InventoryFeature.Action)
        case thirdTab(ThirdTabFeature.Action)
        case selectedTabChanged(Tab)
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, aciton in
            switch aciton {
            case .firstTab, .inventory, .thirdTab:
                return .none
            case .selectedTabChanged(_):
                return .none
                
            }
        }
        Scope(state: \.firstTab, action: /Action.firstTab) {
            FirstTabFeature()
        }
        Scope(state: \.inventory, action: /Action.inventory) {
            InventoryFeature()
        }
        Scope(state: \.thirdTab, action: /Action.thirdTab) {
            ThirdTabFeature()
        }
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .selectedTabChanged(tab):
            state.selectedTab = tab
            return .none
        case .firstTab(.goToInventoryButtonTapped):
            state.selectedTab = .inventory
            return .none
        }
        
    }
}

enum Tab {
    case one, inventory, three
}

struct ContentView: View {
    //    @State var selectedTab: Tab = .one
    //    let store: Store<AppFeature.State, AppFeature.Action>
    let store : StoreOf<AppFeature> // can't read state, observe from it. to do that we use viewStore.
    
    var body: some View {
        // WithViewStore(self.store, observe: { $0 }) will reload view on every state change
        // to reload only when selection use \.selectedTab  case path
        
        WithViewStore(self.store, observe:  \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.selectedTabChanged)) {
                FirstTabView(store: self.store.scope(
                    state: \.firstTab,
                    action: AppFeature.Action.firstTab
                )
                )
                .tabItem { Text("One") }
                .tag(Tab.one)

                InventoryView(store: self.store.scope(state: \.inventory, action: AppFeature.Action.inventory))
                    .tabItem { Text("Two") }
                    .tag(Tab.inventory)
                
                ThirdTabView(store: self.store.scope(state: \.thirdTab, action: AppFeature.Action.thirdTab))
                    .tabItem { Text("Three") }
                    .tag(Tab.three)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: AppFeature.State(), reducer: AppFeature())
        
        )
    }
}
