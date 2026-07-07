import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Passport?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.issuingCountry)")
                                .font(Theme.headingFont)
                                .foregroundStyle(Theme.ink)
                            Text("\(item.pagesUsed)")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryInk)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .themedBackground()
            .navigationTitle("Passport Pages")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryEditorView(mode: .edit(item))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

enum EditorMode: Identifiable, Equatable {
    case add
    case edit(Passport)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: EditorMode

    @State private var draftIssuingcountry: String = ""
    @State private var draftPagesused: Int = 0
    @State private var draftTotalpages: Int = 0
    @State private var draftExpirydate: Date = Date()
    @State private var draftNotes: String = ""

    init(mode: EditorMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Passport Details") {
                TextField("Issuingcountry", text: $draftIssuingcountry)
                    .accessibilityIdentifier("field_issuingCountry")
                Stepper("Pagesused: \(draftPagesused)", value: $draftPagesused, in: 0...9999)
                    .accessibilityIdentifier("field_pagesUsed")
                Stepper("Totalpages: \(draftTotalpages)", value: $draftTotalpages, in: 0...9999)
                    .accessibilityIdentifier("field_totalPages")
                DatePicker("Expirydate", selection: $draftExpirydate, displayedComponents: .date)
                    .accessibilityIdentifier("field_expiryDate")
                TextField("Notes", text: $draftNotes)
                    .accessibilityIdentifier("field_notes")
                }

                if case .edit(let item) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .themedBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftIssuingcountry = item.issuingCountry
        draftPagesused = item.pagesUsed
        draftTotalpages = item.totalPages
        draftExpirydate = item.expiryDate
        draftNotes = item.notes
        } else {
        draftIssuingcountry = ""
        draftPagesused = 0
        draftTotalpages = 0
        draftExpirydate = Date()
        draftNotes = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(Passport(issuingCountry: draftIssuingcountry, pagesUsed: draftPagesused, totalPages: draftTotalpages, expiryDate: draftExpirydate, notes: draftNotes))
        case .edit(let item):
            var updated = item
            updated.issuingCountry = draftIssuingcountry
            updated.pagesUsed = draftPagesused
            updated.totalPages = draftTotalpages
            updated.expiryDate = draftExpirydate
            updated.notes = draftNotes
            store.update(updated)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
