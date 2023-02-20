//
//  Vanila.swift
//  Inventory
//
//  Created by Akash soni on 19/02/23.
//

import SwiftUI
import XCTestDynamicOverlay

class AppModel: ObservableObject {
  @Published var firstTab: FirstTabModel {
    didSet { self.bind() }
  }
  @Published var selectedTab: Tab

  init(
    firstTab: FirstTabModel,
    selectedTab: Tab = .one
  ) {
    self.firstTab = firstTab
    self.selectedTab = selectedTab
    self.bind()
  }

  private func bind() {
    self.firstTab.switchToInventoryTab = { [weak self] in
      self?.selectedTab = .inventory
    }
  }
}

/// Parent child communication can happen only using closure in switui in testable manner
/// unimplemented is getting used here instead of {} so that if someone forget to implement it in test case then it fails.

class FirstTabModel: ObservableObject {
  var switchToInventoryTab: () -> Void = unimplemented("FirstTabModel.switchToInventoryTab")

  func goToInventoryTab() {
    self.switchToInventoryTab()
  }
}
