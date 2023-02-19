//
//  ContentView.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import ComposableArchitecture

enum Tab {
    case one, inventory, three
}

struct ContentView: View {
    @State var selectedTab: Tab = .one
    
    var body: some View {
        TabView(selection: self.$selectedTab) {
            Button {
                self.selectedTab = .inventory
            } label: {
                Text("Go to inventory")
            }
            .tabItem { Text("One") }
            .tag(Tab.one)

            Text("Tab 2")
                .tabItem {
                    Text("Two")
                }
                .tag(Tab.inventory)
            
            Text("Tab 3")
                .tabItem {
                    Text("Three")
                }
                .tag(Tab.three)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
