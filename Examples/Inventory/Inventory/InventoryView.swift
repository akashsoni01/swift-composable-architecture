//
//  InventoryView.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

struct InventoryFeature: Reducer {
    struct State : Equatable {
        var items: IdentifiedArrayOf<Item> = []
        
    }
    enum Action: Equatable {
        case deleteButtonTapped(id: Item.ID)
    }
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .deleteButtonTapped(id: let id):
            // Show alert
            return .none
        }
    }
}

struct InventoryView: View {
    let store: StoreOf<InventoryFeature>
    
    var body: some View {
        WithViewStore(
          self.store, observe: \.items
        ) { viewStore in
          List {
            ForEach(viewStore.state) { item in
              HStack {
                VStack(alignment: .leading) {
                  Text(item.name)

                  switch item.status {
                  case let .inStock(quantity):
                    Text("In stock: \(quantity)")
                  case let .outOfStock(isOnBackOrder):
                      Text(
                        "Out of stock \(isOnBackOrder ? ": on back order" : "")"
                      )
                  }
                }

                Spacer()

                if let color = item.color {
                  Rectangle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color.swiftUIColor)
                    .border(Color.black, width: 1)
                }

                Button {
                    viewStore.send(.deleteButtonTapped(id: item.id))
                } label: {
                  Image(systemName: "trash.fill")
                }
                .padding(.leading)
              }
              .buttonStyle(.plain)
              .foregroundColor(
                item.status.isInStock ? nil : Color.gray
              )
            }
          }
        }
    }
}

struct Inventory_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InventoryView(
                store: Store(
                    initialState: InventoryFeature.State(
                        items: [
                            .headphones,
                            .mouse,
                            .keyboard,
                            .monitor,
                        ]
                    ),
                    reducer: InventoryFeature()
                )
            )
        }
    }
}
