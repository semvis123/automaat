import Foundation
import SwiftUI
import KeychainAccess
import Combine

private final class KeychainStorage<Value: Codable>: ObservableObject {
    var value: Value {
        set {
            objectWillChange.send()
            save(newValue)
        }
        get { fetch() }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let key: String
    private let defaultValue: Value
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private let keychain = Keychain(service: "com.semvis123.automaat")
        .synchronizable(true)
        .accessibility(.always)

    init(defaultValue: Value, for key: String) {
        self.defaultValue = defaultValue
        self.key = key
    }

    private func save(_ newValue: Value) {
        guard let data = try? encoder.encode(newValue) else {
            return
        }

        try? keychain.set(data, key: key)
    }

    private func fetch() -> Value {
        guard
            let data = try? keychain.getData(key),
            let freshValue = try? decoder.decode(Value.self, from: data)
        else {
            return defaultValue
        }

        return freshValue
    }
}


@propertyWrapper struct SecureStorage<Value: Codable>: DynamicProperty {
    @ObservedObject private var storage: KeychainStorage<Value>

    var wrappedValue: Value {
        get { storage.value }

        nonmutating set {
            storage.value = newValue
        }
    }

    init(wrappedValue: Value, _ key: String) {
        self.storage = KeychainStorage(defaultValue: wrappedValue, for: key)
    }

    var projectedValue: Binding<Value> {
        .init(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
