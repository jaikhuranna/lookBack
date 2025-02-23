import SwiftUI

struct LookBackView: View {
    @StateObject private var dataHandler = DataHandler.shared
    @State private var showingAddActionModal: Bool = false
    @State private var newActionTitle: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if dataHandler.actions.isEmpty {
                        Text("No actions logged yet.")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        List {
                            ForEach(dataHandler.actions) { action in
                                NavigationLink(destination: ActionDetailView(action: action)) {
                                    VStack(alignment: .leading) {
                                        Text(action.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("\(action.entries.count) entries")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .background(Color.clear)
                    }
                }
                .navigationTitle("Look Back")
                .toolbar {
                    Button("Add Action") {
                        showingAddActionModal = true
                    }
                    .foregroundColor(.white)
                }
                .sheet(isPresented: $showingAddActionModal) {
                    VStack {
                        Text("Add New Action")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)

                        TextField("Action Title", text: $newActionTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button("Add") {
                            dataHandler.addAction(title: newActionTitle)
                            newActionTitle = ""
                            showingAddActionModal = false
                        }
                        .padding()
                        .foregroundColor(.white)

                        Button("Cancel") {
                            showingAddActionModal = false
                        }
                        .padding()
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black)
                }
            }
        }
    }
}
