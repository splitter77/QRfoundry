import Foundation

struct SavedQRCode: Identifiable, Codable, Equatable {
    let id: UUID
    let type: QRCodeType
    let title: String
    let payload: String
    let createdAt: Date

    init(id: UUID = UUID(), type: QRCodeType, title: String, payload: String, createdAt: Date = .now) {
        self.id = id
        self.type = type
        self.title = title
        self.payload = payload
        self.createdAt = createdAt
    }
}

@Observable
final class QRHistoryStore {
    private let key = "qr_history"
    private(set) var items: [SavedQRCode] = []

    init() {
        load()
    }

    func add(type: QRCodeType, title: String, payload: String) {
        guard !payload.isEmpty else { return }
        let item = SavedQRCode(type: type, title: title.isEmpty ? type.title : title, payload: payload)
        items.removeAll { $0.payload == payload && $0.type == type }
        items.insert(item, at: 0)
        if items.count > 50 {
            items = Array(items.prefix(50))
        }
        save()
    }

    func delete(_ item: SavedQRCode) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedQRCode].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
