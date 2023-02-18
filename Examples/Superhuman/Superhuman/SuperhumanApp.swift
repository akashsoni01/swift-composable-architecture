//
//  SuperhumanApp.swift
//  Superhuman
//
//  Created by Akash soni on 18/02/23.
//

import SwiftUI

@main
struct SuperhumanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
