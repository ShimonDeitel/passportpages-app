import XCTest
@testable import passportpages

@MainActor
final class PassportStoreTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(Passport(issuingCountry: "Sample Issuingcountry 10", pagesUsed: 12, totalPages: 12, expiryDate: Date().addingTimeInterval(-2592000), notes: "Sample Notes 10"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddBeyondFreeLimitIsBlocked() {
        while store.canAddMore {
            store.add(Passport(issuingCountry: "Sample Issuingcountry 2", pagesUsed: 4, totalPages: 4, expiryDate: Date().addingTimeInterval(-518400), notes: "Sample Notes 2"))
        }
        let countAtLimit = store.items.count
        store.add(Passport(issuingCountry: "Sample Issuingcountry 3", pagesUsed: 5, totalPages: 5, expiryDate: Date().addingTimeInterval(-777600), notes: "Sample Notes 3"))
        XCTAssertEqual(store.items.count, countAtLimit)
    }

    func testProUnlockBypassesLimit() {
        while store.canAddMore {
            store.add(Passport(issuingCountry: "Sample Issuingcountry 2", pagesUsed: 4, totalPages: 4, expiryDate: Date().addingTimeInterval(-518400), notes: "Sample Notes 2"))
        }
        store.isProUnlocked = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesItem() {
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testUpdateModifiesItem() {
        var item = store.items[0]
        item.issuingCountry = "Sample Issuingcountry 6"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.issuingCountry, item.issuingCountry)
    }

    func testDeleteAtOffsetsRemovesCorrectItem() {
        let target = store.items[0]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertFalse(store.items.contains(target))
    }
}
