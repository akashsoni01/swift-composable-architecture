//
//  InventoryApp.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct InventoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppFeature.State(), reducer: AppFeature())
            
            )
        }
    }
}
