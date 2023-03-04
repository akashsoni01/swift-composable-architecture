//
//  InventoryTests.swift
//  InventoryTests
//
//  Created by Akash soni on 19/02/23.
//

import XCTest
import ComposableArchitecture
@testable import Inventory

@MainActor
final class InventoryTests: XCTestCase {
    func testGotoInventory() async {
        let store = TestStore(initialState: AppFeature.State(), reducer: AppFeature())
        // old code to perform normal send action and check state change
        //        await store.send(.firstTab(.goToInventoryButtonTapped)) {
        //            $0.selectedTab = .inventory
        //        }
        
        // await store.send(.firstTab(.goToInventoryButtonTapped))
        // await store.receive(.firstTab(.delegate(.swithtoInventoryTab)))
        // receive can take case path also have other flavor like predicates

        // we can use guard to cheeck
        /*
         await store.receive {
             guard case .firstTab(.delegate(.swithtoInventoryTab)) = $0
             else { return false }
             return true
         } assert: { state in
             state.selectedTab = .inventory
         }
         */

        // we can also use case path instead of guard let to perform same task as follows.
        
        /*
         await store.receive(
             (/AppFeature.Action.firstTab).appending(path: /FirstTabFeature.Action.delegate)
         ) {
             $0.selectedTab = .inventory
         }
         */
        
        // And after making all the action equatable we can further reduce the syntex to
        /*
         await store.receive(.firstTab(.delegate(.swithtoInventoryTab))) {
             $0.selectedTab = .inventory
         }
         */
        
        // ** ***** Conclusion code ***** ** //
        
        await store.send(.firstTab(.goToInventoryButtonTapped))
        await store.receive(.firstTab(.delegate(.swithtoInventoryTab))) {
            $0.selectedTab = .inventory
        }

        
        
    }
    
    func testDelete() async {
        let item = Item.headphones

        let store = TestStore(
          initialState: InventoryFeature.State(items: [item]),
          reducer: InventoryFeature()
        )
        
        await store.send(.deleteButtonTapped(id: item.id)) {
            $0.alert = .delete(item: item)
        }
        
//        await store.send(.alert(.confirmDeletion(id: item.id))) {
//            $0.items = []
//        }
//        await store.send(.alert(.confirmDeletion(id: item.id))) {
//          $0.alert = nil
//          $0.items = []
//        }
//

        await store.send(.alert(.presented(.confirmDeletion(id: item.id)))) {
            $0.alert = nil
            $0.items = []
        }

        
    }
    
    func testDuplicate() async {
        let item = Item.headphones

        let store = TestStore(
          initialState: InventoryFeature.State(items: [item]),
          reducer: InventoryFeature()
        ) {
          $0.uuid = .incrementing
        }

        await store.send(.duplicateButtonTapped(id: item.id)) {
          $0.confirmationDialog = .duplicate(item: item)
        }
        await store.send(.confirmationDialog(.presented(.confirmDuplicate(id: item.id)))) {
          $0.confirmationDialog = nil
          $0.items = [
            Item(
              id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
              name: "Headphones",
              color: .blue,
              status: .inStock(quantity: 20)
            ),
            item
          ]
        }
      }
    
    func testAddItem() async {
        let store = TestStore(
          initialState: InventoryFeature.State(),
          reducer: InventoryFeature()
        ) {
          $0.uuid = .incrementing
        }
        
        await store.send(.addButtonTapped) {
          $0.addItem = ItemFormFeature.State(
            item: Item(
              id: UUID(
                uuidString: "00000000-0000-0000-0000-000000000000"
              )!,
              name: "",
              status: .inStock(quantity: 1)
            )
          )
        }
        
        await store.send(
          .addItem(.set(\.$item.name, "Headphones"))
        ) {
          $0.addItem?.item.name = "Headphones"
        }

        await store.send(.confirmAddItemButtonTapped) {
          $0.addItem = nil
          $0.items = [
            Item(
              id: UUID(
                uuidString: "00000000-0000-0000-0000-000000000000"
              )!,
              name: "Headphones",
              status: .inStock(quantity: 1)
            )
          ]
        }

    }

}
