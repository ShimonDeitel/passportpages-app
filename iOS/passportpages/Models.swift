import Foundation

struct Passport: Identifiable, Codable, Equatable {
    let id: UUID
    var issuingCountry: String
    var pagesUsed: Int
    var totalPages: Int
    var expiryDate: Date
    var notes: String

    init(id: UUID = UUID(), issuingCountry: String, pagesUsed: Int, totalPages: Int, expiryDate: Date, notes: String) {
        self.id = id
        self.issuingCountry = issuingCountry
        self.pagesUsed = pagesUsed
        self.totalPages = totalPages
        self.expiryDate = expiryDate
        self.notes = notes
    }
}
