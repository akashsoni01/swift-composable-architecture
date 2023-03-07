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
        var addItem: ItemFormFeature.State?
        var alert: AlertState<Action.Alert>?
        var confirmationDialog: ConfirmationDialogState<Action.Dialog>?
        var items: IdentifiedArrayOf<Item> = []

    }
    enum Action: Equatable {
        case addButtonTapped
        case addItem(SheetAction<ItemFormFeature.Action>)
        case alert(AlertAction<Alert>)
        case confirmationDialog(ConfirmationDialogAction<Dialog>)
        case deleteButtonTapped(id: Item.ID)
//        case dismissAddItem
        case duplicateButtonTapped(id: Item.ID)
        case cancelAddItemButtonTapped
        case confirmAddItemButtonTapped

        
        enum Alert: Equatable {
            case confirmDeletion(id: Item.ID)
        }
        
        enum Dialog: Equatable {
            case confirmDuplicate(id: Item.ID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
          switch action {
          case .addButtonTapped:
              state.addItem = ItemFormFeature.State(
                item: Item(name: "", status: .inStock(quantity: 1))
              )
              return .none
              
          case .addItem(.dismiss):
              state.addItem = nil
              return .none
              
//          case .dismissAddItem:
//              state.addItem = nil
//              return .none
              
          case .addItem:
            return .none
              
          case .confirmAddItemButtonTapped:
            defer { state.addItem = nil }
            guard let item = state.addItem?.item
            else { return .none }
            state.items.append(item)
            return .none
              
          case .cancelAddItemButtonTapped:
              state.addItem = nil
              return .none

          case let .alert(.presented(.confirmDeletion(id: id))):
            state.items.remove(id: id)
            return .none

          case .alert:
            return .none

          case let .confirmationDialog(.presented(.confirmDuplicate(id: id))):
              guard let item = state.items[id: id],
                    let index = state.items.index(id: id)
              else { return .none }

              state.items.insert(item.duplicate(), at: index)
            return .none

          case .confirmationDialog(.dismiss):
              return .none

          case .confirmationDialog:
            return .none

          case let .deleteButtonTapped(id: id):
            guard let item = state.items[id: id]
            else { return .none }

            state.alert = .delete(item: item)
            return .none
              
          case let .duplicateButtonTapped(id: id):
            guard let item = state.items[id: id]
            else { return .none }
              // show a confirmation confirmationDialog
              state.confirmationDialog = .duplicate(item: item)
            return .none
          }
        }
        .alert(state: \.alert, action: /Action.alert)
        .confirmationDialog(state: \.confirmationDialog, action: /Action.confirmationDialog)
        /*
         .ifLet(
             \.addItem,
              action: (/Action.addItem).appending(path: /SheetAction.presented)
         ) {
           ItemFormFeature()
         }

         simplify the if let and create new operator for sheet
         */
        .sheet(state: \.addItem, action: /Action.addItem) {
            ItemFormFeature()
        }
    }
}

struct InventoryView: View {
    let store: StoreOf<InventoryFeature>
    
    struct ViewState: Equatable {
      let addItemID: Item.ID?
      let items: IdentifiedArrayOf<Item>

      init(state: InventoryFeature.State) {
        self.addItemID = state.addItem?.item.id
        self.items = state.items
      }
    }

    var body: some View {
        WithViewStore(
          self.store, observe: ViewState.init
        ) {
            /*
             viewStore in

             This code and sheet present code may cause our preview to not show so in order to deal that use
             
             (
               viewStore: ViewStore<ViewState, InventoryFeature.Action>
             )
             
             the above code will tell compoiler explicitly about the viewstore
             */
            (viewStore: ViewStore<ViewState, InventoryFeature.Action>)  in
          List {
            ForEach(viewStore.items) { item in
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
                    viewStore.send(.duplicateButtonTapped(id: item.id))
                } label: {
                  Image(systemName: "doc.on.doc.fill")
                }
                .padding(.leading)

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
             Error in preview while calling an action after 2 sec.
             https://github.com/akashsoni01/POC/blob/master/Episode%20%23224_%20Composable%20Navigation_%20Sheets.png
             DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 viewStore.send(.addButtonTapped)
             }
             */
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              Button("Add") {
                viewStore.send(.addButtonTapped)
              }
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
          .confirmationDialog(
            store: self.store.scope(
                state: \.confirmationDialog,
                action: InventoryFeature.Action.confirmationDialog)
               )
            
            /*
             We can hide .dismissAddItem for sheet as well as we did for alert and confirmation dialog.
             */
            
            /*
             We can reduce the code by creating view extension.
             .sheet(
               item: viewStore.binding(
                 get: {
                   $0.addItemID.map { Identified($0, id: \.self) }
                 },
                 send: .addItem(.dismiss)
               )
             ) { addItemID in
                 IfLetStore(
                   self.store.scope(
                     state: \.addItem,
                     action: {.addItem(.presented($0))}
                   )
                 )
             */
              
          .sheet(
                 store: self.store.scope(state: \.addItem, action: InventoryFeature.Action.addItem)
               ) { store in
                   /*
                    Adding NavigationStack and toolbar will help to customise the view if defined in parent view.
                    */
                   NavigationStack {
                     ItemFormView(store: store)
                       .toolbar {
                           HStack {
                               Button("Cancel") {
                                 viewStore.send(.cancelAddItemButtonTapped)
                               }
                               
                               Spacer()
                                   
                               Button("Add") {
                                 viewStore.send(.confirmAddItemButtonTapped)
                               }
                           }
                       }
                       .navigationTitle("New item")
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

extension ConfirmationDialogState where Action == InventoryFeature.Action.Dialog {
  static func duplicate(item: Item) -> Self {
    Self {
      TextState(#"Duplicate "\#(item.name)""#)
    } actions: {
      ButtonState(
        action: .send(
          .confirmDuplicate(id: item.id),
          animation: .default
        )
      ) {
        TextState("Duplicate")
      }
    } message: {
      TextState(
        "Are you sure you want to duplicate this item?"
      )
    }
  }
}
