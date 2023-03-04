//
//  ItemForm.swift
//  Inventory
//
//  Created by Akash soni on 04/03/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftUINavigation

struct ItemFormFeature: Reducer {
  struct State: Equatable {
    @BindingState var item: Item
  }
    
  enum Action: BindableAction, Equatable {
      case binding(BindingAction<State>)

  }

    var body: some ReducerOf<Self> {
      BindingReducer()
      EmptyReducer()
    }

}


struct ItemFormView: View {
    let store: StoreOf<ItemFormFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Form {
                TextField("Name", text: viewStore.binding(\.$item.name))
                HStack {
                  Picker(
                    "Color",
                    selection: viewStore.binding(\.$item.color)
                  ) {
                    Text("None")
                      .tag(Item.Color?.none)
                    ForEach(Item.Color.defaults) { color in
                      ZStack {
                        RoundedRectangle(cornerRadius: 4)
                          .fill(color.swiftUIColor)
                        Label(color.name, systemImage: "paintpalette")
                          .padding(4)
                      }
                      .fixedSize(horizontal: false, vertical: true)
                      .tag(Optional(color))
                    }
                  }

                  if let color = viewStore.item.color {
                    Rectangle()
                      .frame(width: 30, height: 30)
                      .foregroundColor(color.swiftUIColor)
                      .border(Color.black, width: 1)
                  }
                }
                
                Switch(viewStore.binding(\.$item.status)) {
                  CaseLet(/Item.Status.inStock) { $quantity in
                    Section(header: Text("In stock")) {
                      Stepper("Quantity: \(quantity)", value: $quantity)
                      Button("Mark as sold out") {
                        viewStore.send(
                          .set(
                            \.$item.status,
                            .outOfStock(isOnBackOrder: false)
                          ),
                          animation: .default
                        )
                      }
                    }
                  }
                  CaseLet(/Item.Status.outOfStock) { $isOnBackOrder in
                    Section(header: Text("Out of stock")) {
                      Toggle("Is on back order?", isOn: $isOnBackOrder)
                      Button("Is back in stock!") {
                        viewStore.send(
                          .set(\.$item.status, .inStock(quantity: 1)),
                          animation: .default
                        )
                      }
                    }
                  }
                }
            }
        }
    }
}

//struct ItemFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemFormView()
//    }
//}
