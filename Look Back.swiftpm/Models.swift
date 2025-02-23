import Foundation
import SwiftUI

// Extend the Entry struct to include imageData
struct Entry: Identifiable, Codable {
    let id: UUID = UUID()
    let timestamp: Date
    var description: String
    var imageData: Data?  // Image data for each entry
}

// Modify Action struct accordingly
struct Action: Identifiable, Codable {
    let id: UUID = UUID()
    var title: String
    var entries: [Entry]
    var description: String
}
