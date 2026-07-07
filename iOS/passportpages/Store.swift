import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Passport] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier item cap. Deliberately kept above the seed data count
    /// so a fresh install never opens directly into the paywall.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("passportpages_items.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: Passport) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Passport) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Passport) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Passport].self, from: data) {
            items = decoded
        } else {
            items = [
        Passport(issuingCountry: "Sample Issuingcountry 1", pagesUsed: 3, totalPages: 3, expiryDate: Date().addingTimeInterval(-259200), notes: "Sample Notes 1"),
        Passport(issuingCountry: "Sample Issuingcountry 2", pagesUsed: 4, totalPages: 4, expiryDate: Date().addingTimeInterval(-518400), notes: "Sample Notes 2"),
        Passport(issuingCountry: "Sample Issuingcountry 3", pagesUsed: 5, totalPages: 5, expiryDate: Date().addingTimeInterval(-777600), notes: "Sample Notes 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
