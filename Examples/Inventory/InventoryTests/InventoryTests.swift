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
}
