import Client
import Common
import ComposableArchitecture
import Foundation

extension TransactionClient  {
  public static let liveValue: TransactionClient = Self(
    fetchTransactions: {
      guard let request = Client.shared.makeRequest(
        endpoint: .transactions,
        httpMethod: .GET
      )
      else {
        return []
      }

      let (data, response) = try await URLSession.shared.data(for: request)
        
			guard let response = response as? HTTPURLResponse
			else {
				return []
			}

			guard (200 ..< 399) ~= response.statusCode
			else {
				return []
			}

			let transactions = try JSONDecoder().decode([Transaction].self, from: data)
			let result = transactions.map {
				let amountFormatted = MuchBetterNumberFormatter.formatCurrency($0)

				return Transaction(id: $0.id,
													 date: $0.date,
													 description: $0.description,
													 amount: amountFormatted,
													 currency: $0.currency)
			}
			
			return result
    }
  )
}
