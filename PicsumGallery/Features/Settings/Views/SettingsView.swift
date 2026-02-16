import SwiftUI

struct SettingsView: View {
    @Environment(\.appSettings) private var settings
    @Environment(\.toastStore) private var toastStore
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
                        HapticManager.shared.lightImpact()
                        if hasUnsavedChanges {
                            showDiscardConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier("settings.cancelButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localized(.done)) {
                        HapticManager.shared.mediumImpact()
                        showSavedToastIfNeeded()
                        dismiss()
                    }
                    .accessibilityIdentifier("settings.doneButton")
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
                    HapticManager.shared.warning()
                    revertAndDismiss()
                }
                Button(localized(.keepEditing), role: .cancel) {
                    HapticManager.shared.lightImpact()
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

    private func showSavedToastIfNeeded() {
        let appearanceChanged = settings.colorScheme != initialColorScheme
        let languageChanged = settings.languageCode != initialLanguageCode
        guard appearanceChanged || languageChanged else { return }

        let key: LocalizedString
        if appearanceChanged, languageChanged {
            key = .settingsSavedAppearanceAndLanguage
        } else if appearanceChanged {
            key = .settingsSavedAppearance
        } else {
            key = .settingsSavedLanguage
        }
        let text = key.localized(for: settings.languageCode)
        let message = ToastMessage(text: text, icon: "checkmark.circle", style: .success)
        toastStore?.show(message, autoDismissAfter: 2.5)
    }

    private var settingsContent: some View {
        List {
            appearanceSection
            languageSection
        }
        .accessibilityIdentifier("settings.screen")
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
            .accessibilityIdentifier("settings.appearancePicker")
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
            .accessibilityIdentifier("settings.languagePicker")
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
