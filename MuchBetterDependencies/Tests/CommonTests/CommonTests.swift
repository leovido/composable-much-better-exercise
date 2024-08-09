import XCTest
@testable import Common

final class CommonTests: XCTestCase {
  func testNumberFormatterForBalance() {
    let balance = BalanceModel(balance: "123", currency: .gbp)
    let current = MuchBetterNumberFormatter.formatCurrency(balance)
    let expected = "£123.00"

    XCTAssertEqual(current, expected)
  }

  func testNumberFormatterForTransaction() {
    let transaction = Transaction(id: UUID().uuidString,
                                  date: Date(),
                                  description: "Test description",
                                  amount: "111.119",
                                  currency: .gbp)
    let current = MuchBetterNumberFormatter.formatCurrency(transaction)
    let expected = "£111.12"

    XCTAssertEqual(current, expected)
  }
}
