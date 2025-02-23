import SwiftUI

struct LookBackView: View {
    @StateObject private var dataHandler = DataHandler.shared
    @State private var showingAddActionModal: Bool = false
    @State private var newActionTitle: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if dataHandler.actions.isEmpty {
                    Text("No actions logged yet.")
                        .padding()
                } else {
                    List {
                        ForEach(dataHandler.actions) { action in
                            NavigationLink(destination: ActionDetailView(action: action)) {
                                VStack(alignment: .leading) {
                                    Text(action.title)
                                        .font(.headline)
                                    Text("\(action.entries.count) entries")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Look Back")
            .toolbar {
                Button("Add Action") {
                    showingAddActionModal = true
                }
            }
            .sheet(isPresented: $showingAddActionModal) {
                VStack {
                    Text("Add New Action")
                        .font(.headline)
                        .padding()

                    TextField("Action Title", text: $newActionTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Add") {
                        dataHandler.addAction(title: newActionTitle)
                        newActionTitle = ""
                        showingAddActionModal = false
                    }
                    .padding()

                    Button("Cancel") {
                        showingAddActionModal = false
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}
