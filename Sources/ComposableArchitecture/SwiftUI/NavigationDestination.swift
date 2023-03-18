import SwiftUI
import SwiftUINavigation

extension View {
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public func navigationDestination<State, Action, Destination: View>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    @ViewBuilder destination: @escaping (Store<State, Action>) -> Destination
  ) -> some View {
    self.navigationDestination(
      store: store, state: { $0 }, action: { $0 }, destination: destination
    )
  }

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public func navigationDestination<
    State, Action, DestinationState, DestinationAction, Destination: View
  >(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    state toDestinationState: @escaping (State) -> DestinationState?,
    action fromDestinationAction: @escaping (DestinationAction) -> Action,
    @ViewBuilder destination: @escaping (Store<DestinationState, DestinationAction>) ->
      Destination
  ) -> some View {
    self.modifier(
      PresentationNavigationDestinationModifier(
        store: store,
        state: toDestinationState,
        action: fromDestinationAction,
        content: destination
      )
    )
  }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
private struct PresentationNavigationDestinationModifier<
  State,
  Action,
  DestinationState,
  DestinationAction,
  DestinationContent: View
>: ViewModifier {
  let store: Store<PresentationState<State>, PresentationAction<Action>>
  @StateObject var viewStore: ViewStore<Bool, PresentationAction<Action>>
  let toDestinationState: (State) -> DestinationState?
  let fromDestinationAction: (DestinationAction) -> Action
  let destinationContent: (Store<DestinationState, DestinationAction>) -> DestinationContent

  init(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    state toDestinationState: @escaping (State) -> DestinationState?,
    action fromDestinationAction: @escaping (DestinationAction) -> Action,
    content destinationContent:
      @escaping (Store<DestinationState, DestinationAction>) -> DestinationContent
  ) {
    self.store = store
    self._viewStore = StateObject(
      wrappedValue: ViewStore(
        store
          .filterSend { state, _ in state.wrappedValue != nil }
          .scope(state: { $0.wrappedValue.flatMap(toDestinationState) != nil }),
        observe: { $0 }
      )
    )
    self.toDestinationState = toDestinationState
    self.fromDestinationAction = fromDestinationAction
    self.destinationContent = destinationContent
  }

  func body(content: Content) -> some View {
    content.navigationDestination(
      // TODO: do binding with ID check
      unwrapping: self.viewStore.binding(send: .dismiss).presence
    ) { _ in
      IfLetStore(
        self.store.scope(
          state: returningLastNonNilValue { $0.wrappedValue.flatMap(self.toDestinationState) },
          action: { .presented(self.fromDestinationAction($0)) }
        ),
        then: self.destinationContent
      )
    }
  }
}

fileprivate extension Binding where Value == Bool {
  var presence: Binding<Void?> {
    .init(
      get: { self.wrappedValue ? () : nil },
      set: { self.transaction($1).wrappedValue = $0 != nil }
    )
  }
}
