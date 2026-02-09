import SwiftUI

struct SettingsView: View {
    @Environment(\.appSettings) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var initialColorScheme: ColorScheme?
    @State private var initialLanguageCode: String = "en"
    @State private var showDiscardConfirmation = false

    private var hasUnsavedChanges: Bool {
        settings.colorScheme != initialColorScheme || settings.languageCode != initialLanguageCode
    }

    private var localized: (LocalizedString) -> String {
        { $0.localized(for: settings.languageCode) }
    }

    var body: some View {
        settingsContent
            .navigationTitle(localized(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localized(.cancel)) {
                        if hasUnsavedChanges {
                            showDiscardConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localized(.done)) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initialColorScheme = settings.colorScheme
                initialLanguageCode = settings.languageCode
            }
            .confirmationDialog(
                localized(.discardSettings),
                isPresented: $showDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button(localized(.discard), role: .destructive) {
                    revertAndDismiss()
                }
                Button(localized(.keepEditing), role: .cancel) {
                    showDiscardConfirmation = false
                }
            } message: {
                Text(localized(.discardMessage))
            }
    }

    private func revertAndDismiss() {
        settings.colorScheme = initialColorScheme
        settings.languageCode = initialLanguageCode
        dismiss()
    }

    private var settingsContent: some View {
        List {
            appearanceSection
            languageSection
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker(localized(.appearance), selection: Binding(
                get: {
                    if settings.colorScheme == nil {
                        return "system"
                    } else if settings.colorScheme == .light {
                        return "light"
                    } else {
                        return "dark"
                    }
                },
                set: {
                    switch $0 {
                    case "light":
                        settings.colorScheme = .light
                    case "dark":
                        settings.colorScheme = .dark
                    default:
                        settings.colorScheme = nil
                    }
                }
            )) {
                Text(localized(.system)).tag("system")
                Text(localized(.light)).tag("light")
                Text(localized(.dark)).tag("dark")
            }
            .pickerStyle(.segmented)
        } header: {
            Text(localized(.appearance))
        } footer: {
            Text(localized(.chooseColorScheme))
        }
    }

    private var languageSection: some View {
        Section {
            Picker(localized(.language), selection: Binding(
                get: { settings.languageCode },
                set: { settings.languageCode = $0 }
            )) {
                ForEach(AppSettings.availableLanguages, id: \.code) { language in
                    Text(language.name).tag(language.code)
                }
            }
        } header: {
            Text(localized(.language))
        } footer: {
            Text(localized(.selectLanguage))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(\.appSettings, AppSettings.shared)
    }
}
