import ComposableArchitecture
import SwiftUI

public struct SpendView: View {
  @Bindable public var store: StoreOf<SpendReducer>

  public init(store: StoreOf<SpendReducer>) {
    self.store = store
  }

  public var body: some View {
		WithPerceptionTracking {
      NavigationView {
        VStack {
					Form {
            Section {
              TextField(
								"Description", text: $store.description
              )
              .autocapitalization(.sentences)
              .disableAutocorrection(true)

              TextField("Amount",
												text: $store.amount)
              
              .keyboardType(.decimalPad)
            } header: {
              Text("TRANSACTION DETAILS")
            }
            Section {
              Button {
                store.send(.spendRequest)
              } label: {
                Text("Create transaction")
              }
            }
          }

          Spacer()
        }
        .background(Color(UIColor.systemGray6))
        .navigationTitle(Text("Spend"))
        .alert(
					$store.scope(state: \.alert, action: \.alert)
        )
      }
    }
  }
}
