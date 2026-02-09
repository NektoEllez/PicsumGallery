import SwiftUI

protocol Localizing: AnyObject {
    var languageCode: String { get }
    func string(_ key: LocalizedString) -> String
}

extension AppSettings: Localizing {
    func string(_ key: LocalizedString) -> String {
        key.localized(for: languageCode)
    }
}

@Observable
@MainActor
final class AppSettings {
    var colorScheme: ColorScheme? {
        didSet {
            let value: String?
            switch colorScheme {
            case .light:
                value = "light"
            case .dark:
                value = "dark"
            case nil:
                value = nil
            @unknown default:
                value = nil
            }
            UserDefaults.standard.set(value, forKey: "app.colorScheme")
        }
    }
    
    var languageCode: String {
        didSet {
            UserDefaults.standard.set(languageCode, forKey: "app.languageCode")
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        }
    }
    
    init() {
        let schemeString = UserDefaults.standard.string(forKey: "app.colorScheme")
        switch schemeString {
        case "light":
            self.colorScheme = .light
        case "dark":
            self.colorScheme = .dark
        default:
            self.colorScheme = nil
        }
        
        self.languageCode = UserDefaults.standard.string(forKey: "app.languageCode") ?? "en"
    }
    
    static let availableLanguages: [(code: String, name: String)] = [
        ("en", "English"),
        ("ru", "Русский")
    ]
}

private enum AppSettingsKey: EnvironmentKey {
    static let defaultValue: AppSettings = AppSettings.shared
}

extension EnvironmentValues {
    var appSettings: AppSettings {
        get { self[AppSettingsKey.self] }
        set { self[AppSettingsKey.self] = newValue }
    }
}

extension AppSettings {
    static let shared = AppSettings()
}
