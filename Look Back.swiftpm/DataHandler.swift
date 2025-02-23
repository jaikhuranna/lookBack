import Foundation
import SwiftUI

@MainActor
class DataHandler: ObservableObject {
    static let shared = DataHandler()
    private let fileName = "actions.json"

    @Published var actions: [Action] = []

    init() {
        loadActions()
    }

    func loadActions() {
        let url = getFileURL()
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Action].self, from: data) {
            actions = decoded
        } else {
            // First-time run: Add sample data
            actions = [
                Action(
                    title: "Completed a Big Task",
                    entries: [
                        Entry(timestamp: Date().addingTimeInterval(-86400), description: "Finished coding a core feature.", imageData: nil),
                        Entry(timestamp: Date().addingTimeInterval(-3600), description: "Reviewed and merged pull requests.", imageData: nil)
                    ],
                    description: "Working on the core features"
                ),
                Action(
                    title: "Met an Old Friend",
                    entries: [
                        Entry(timestamp: Date().addingTimeInterval(-172800), description: "Had coffee and caught up on life.", imageData: nil)
                    ],
                    description: "Coffee meetup"
                )
            ]
            saveActions()
        }
    }

    func saveActions() {
        let url = getFileURL()
        do {
            let encoded = try JSONEncoder().encode(actions)
            try encoded.write(to: url)
        } catch {
            print("Failed to save actions: \(error)")
        }
    }

    func addAction(title: String) {
        let newAction = Action(title: title, entries: [], description: "")
        actions.append(newAction)
        saveActions()
    }

    func addEntry(to actionID: UUID, description: String, date: Date, imageData: Data?) {
        if let index = actions.firstIndex(where: { $0.id == actionID }) {
            let newEntry = Entry(timestamp: date, description: description, imageData: imageData)
            actions[index].entries.append(newEntry)
            saveActions()
        }
    }

    func updateEntryImage(entryId: UUID, imageData: Data?) {
        for i in 0..<actions.count {
            if let entryIndex = actions[i].entries.firstIndex(where: { $0.id == entryId }) {
                actions[i].entries[entryIndex].imageData = imageData
                saveActions()
                return
            }
        }
    }

    func updateActionDescription(_ actionId: UUID, description: String) {
        if let index = actions.firstIndex(where: { $0.id == actionId }) {
            actions[index].description = description
            saveActions()
        }
    }

    private func getFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
    }
}
