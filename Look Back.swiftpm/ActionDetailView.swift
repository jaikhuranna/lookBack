import SwiftUI
import PhotosUI

struct ActionDetailView: View {
    let action: Action
    @StateObject private var dataHandler = DataHandler.shared
    @State private var selectedDate: Date = Date()
    @State private var editingDescription: Bool = false
    @State private var description: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    // State for showing the add entry modal
    @State private var showingAddEntryModal: Bool = false
    @State private var newEntryDescription: String = ""
    @State private var newEntryDate: Date = Date()
    @State private var newEntryImage: UIImage?

    // Constants
    private let padding: CGFloat = 8
    private let imageHeight: CGFloat = 200
    private let imageCornerRadius: CGFloat = 10

    @State private var localDescription: String = ""
    private let calendar = Calendar.current
    @State private var selectedEntry: Entry?

    private var datesWithEntries: [Date] {
        let dates = action.entries.map { entry in
            return Calendar.current.startOfDay(for: entry.timestamp)
        }
        return Array(Set(dates)).sorted(by: <)
    }

    private func entriesForDate(_ date: Date) -> [Entry] {
        return action.entries.filter { entry in
            return Calendar.current.isDate(entry.timestamp, inSameDayAs: date)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            dateSelector
            imageAndDescriptionSection
            entriesList
        }
        .navigationTitle(action.title)
        .toolbar { toolbarItems }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
                .onDisappear {
                    // Persist the selected image for the current entry, if any
                    if let newImage = selectedImage, let entryId = selectedEntry?.id {
                        dataHandler.updateEntryImage(entryId: entryId, imageData: newImage.jpegData(compressionQuality: 0.8))
                        updateSelectedEntry() // Refresh to show new image
                    }
                    selectedImage = nil // Reset selectedImage after use
                }
        }
        .sheet(isPresented: $showingAddEntryModal) {
            addEntryModal
        }
        .onAppear {
            setupInitialState()
            localDescription = description
            updateSelectedEntry()
        }
        .onChange(of: selectedDate) { _ in
            updateSelectedEntry()
            updateEntries()
        }
    }

    private var dateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(datesWithEntries, id: \.self) { date in
                    DateCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                            updateSelectedEntry() // Update selectedEntry when date changes
                        }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var imageAndDescriptionSection: some View {
        VStack(spacing: 16) {
            if let selectedEntry = selectedEntry,
               let imageData = selectedEntry.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .cornerRadius(imageCornerRadius)
                    .clipped()
                    .onTapGesture {
                        showingImagePicker = true // Show the image picker
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: imageHeight)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(imageCornerRadius)
                    .onTapGesture {
                        showingImagePicker = true // Show the image picker
                    }
            }
            descriptionSection
        }
        .padding()
    }

    private var descriptionSection: some View {
        Group {
            if editingDescription {
                TextEditor(text: $localDescription)
                    .frame(height: 100)
                    .padding(padding)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text(localDescription.isEmpty ? "Add a description..." : localDescription)
                    .foregroundColor(localDescription.isEmpty ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(padding)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onTapGesture {
                        editingDescription = true
                    }
            }
        }
    }

    private var entriesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                let dayEntries = entriesForDate(selectedDate)
                if dayEntries.isEmpty {
                    Text("No entries for this date")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else {
                    ForEach(dayEntries) { entry in
                        EntryCell(entry: entry)
                    }
                }
            }
            .padding()
        }
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if editingDescription {
                Button("Done") {
                    editingDescription = false
                    updateDescription(localDescription)
                    description = localDescription
                }
            } else {
                Button("Add Entry") {
                    showingAddEntryModal = true
                }
            }
            if !editingDescription {
                Button {
                    editingDescription = true
                } label: {
                    Text("Edit")
                }
            }
        }
    }

    private var addEntryModal: some View {
        VStack {
            Text("Add New Entry")
                .font(.headline)
                .padding()

            DatePicker("Entry Date", selection: $newEntryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()

            TextField("Entry Description", text: $newEntryDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Select Image") {
                showingImagePicker = true
            }
            .padding()

            if let newEntryImage = newEntryImage {
                Image(uiImage: newEntryImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(imageCornerRadius)
            }

            Button("Add Entry") {
                var imageData: Data? = nil
                if let newEntryImage = newEntryImage {
                    imageData = newEntryImage.jpegData(compressionQuality: 0.8)
                }
                dataHandler.addEntry(to: action.id, description: newEntryDescription, date: newEntryDate, imageData: imageData)
                newEntryDescription = ""
                newEntryDate = Date()
                newEntryImage = nil
                showingAddEntryModal = false
                updateSelectedEntry()
            }
            .padding()

            Button("Cancel") {
                showingAddEntryModal = false
            }
            .padding()
        }
        .padding()
    }

    private func setupInitialState() {
        description = action.description
        localDescription = description
        updateSelectedEntry()
    }

    private func updateEntries() {
        print("Updating entries for date: \(selectedDate)")
    }

    private func updateSelectedEntry() {
         selectedEntry = entriesForDate(selectedDate).first
    }

    private func updateDescription(_ newValue: String) {
        dataHandler.updateActionDescription(action.id, description: newValue)
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM\nd"
        return formatter
    }()

    var body: some View {
        Text(dateFormatter.string(from: date))
            .multilineTextAlignment(.center)
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .onTapGesture {
                print("Selected date: \(date)")
            }
    }
}

struct EntryCell: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.description)
                .font(.body)
            Text(entry.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .cornerRadius(10)
                    .clipped()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}
