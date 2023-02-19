//
//  InventoryView.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

struct InventoryFeature: Reducer {
    struct State {}
    enum Action {}
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
}

struct InventoryView: View {
    let store: StoreOf<InventoryFeature>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct InventoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        InventoryView()
//    }
//}
