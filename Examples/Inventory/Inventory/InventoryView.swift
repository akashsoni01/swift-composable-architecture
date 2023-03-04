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
        var alert: AlertState<Action.Alert>?
        var items: IdentifiedArrayOf<Item> = []

    }
    enum Action: Equatable {
        case alert(AlertAction<Alert>)
        case deleteButtonTapped(id: Item.ID)
        
        enum Alert: Equatable {
            case confirmDeletion(id: Item.ID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
          switch action {
          case let .alert(.presented(.confirmDeletion(id: id))):
            state.items.remove(id: id)
            return .none

          case .alert:
            return .none

          case let .deleteButtonTapped(id: id):
            guard let item = state.items[id: id]
            else { return .none }

            state.alert = .delete(item: item)
            return .none
          }
        }
        .alert(state: \.alert, action: /Action.alert)
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
            /*
             And there’s a second argument called dismiss. This is here because it technically is possible to create an alert button that doesn’t send an action at all. In fact, SwiftUI can even implicitly add buttons into the alert for you if you forget to do something, such as provide a cancel button. It is also even possible for the user to hit the escape key on a connected keyboard to dismiss an alert.
             .alert(
               self.store.scope(
                 state: \.alert, action: InventoryFeature.Action.alert
               ),
               dismiss: Action
             )
             
             
             */
          .alert(
            store: self.store.scope(
                state: \.alert,
                action: InventoryFeature.Action.alert)
               )

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


extension AlertState where Action == InventoryFeature.Action.Alert {
  static func delete(item: Item) -> Self {
    return AlertState {
      TextState(#"Delete "\#(item.name)""#)
    } actions: {
        /*
         Notice that a “Cancel” button appears in the alert even though we did not specify one in our AlertState. This is what we alluded to a moment ago. SwiftUI will make sure that the alert that shows is reasonable, and so if you don’t provide a cancel button it will stick one in for you. And that is further why we needed that dedicated .dismiss action, so that it could be sent when the “Cancel” button is tapped.


         ButtonState(
             role: .destructive,
             action: .confirmDeletion(id: item.id)
           ) {
             TextState("Delete")
           }
         ................
         
         ButtonState(
           role: .destructive,
           action: .send(
             .confirmDeletion(id: item.id), animation: .default
           )
         ) {
           TextState("Delete")
         }
         */

      ButtonState(
        role: .destructive,
        action: .send(
          .confirmDeletion(id: item.id),
          animation: .default
        )
      ) {
        TextState("Delete")
      }
    } message: {
      TextState(
        "Are you sure you want to delete this item?"
      )
    }
  }
}
