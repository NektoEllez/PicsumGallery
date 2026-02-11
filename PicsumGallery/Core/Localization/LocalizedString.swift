import Foundation

enum LocalizedString {
    case settings
    case cancel
    case done
    case discard
    case discardSettings
    case keepEditing
    case discardMessage
    case appearance
    case system
    case light
    case dark
    case chooseColorScheme
    case language
    case selectLanguage
    case photos
    case loadingPhotos
    case noPhotosYet
    case pullToRefresh
    case loadMore
    case photo
    case loadingImage
    case invalidUrl
    case photosUpdated
    case information
    case author
    case dimensions
    case aspectRatio
    case photoSingular
    case photoPlural
    case landscape
    case portrait
    case square
    case settingsSavedAppearance
    case settingsSavedLanguage
    case settingsSavedAppearanceAndLanguage

    func localized(for languageCode: String) -> String {
        let translations: [LocalizedString: [String: String]] = [
            .settings: ["en": "Settings", "ru": "Настройки"],
            .cancel: ["en": "Cancel", "ru": "Отмена"],
            .done: ["en": "Done", "ru": "Готово"],
            .discard: ["en": "Discard", "ru": "Сбросить"],
            .discardSettings: ["en": "Discard settings?", "ru": "Сбросить настройки?"],
            .keepEditing: ["en": "Keep Editing", "ru": "Продолжить"],
            .discardMessage: ["en": "Your changes to appearance and language will not be saved.", "ru": "Изменения темы и языка не будут сохранены."],
            .appearance: ["en": "Appearance", "ru": "Внешний вид"],
            .system: ["en": "System", "ru": "Системная"],
            .light: ["en": "Light", "ru": "Светлая"],
            .dark: ["en": "Dark", "ru": "Тёмная"],
            .chooseColorScheme: ["en": "Choose your preferred color scheme", "ru": "Выберите цветовую схему"],
            .language: ["en": "Language", "ru": "Язык"],
            .selectLanguage: ["en": "Select your preferred language", "ru": "Выберите язык"],
            .photos: ["en": "Photos", "ru": "Фото"],
            .loadingPhotos: ["en": "Loading photos...", "ru": "Загрузка фото..."],
            .noPhotosYet: ["en": "No Photos Yet", "ru": "Пока нет фото"],
            .pullToRefresh: ["en": "Pull down to refresh and load photos", "ru": "Потяните вниз для обновления"],
            .loadMore: ["en": "Load More", "ru": "Ещё"],
            .photo: ["en": "Photo", "ru": "Фото"],
            .loadingImage: ["en": "Loading image...", "ru": "Загрузка изображения..."],
            .invalidUrl: ["en": "Invalid URL", "ru": "Неверный адрес"],
            .photosUpdated: ["en": "Photos updated", "ru": "Фото обновлены"],
            .information: ["en": "Information", "ru": "Информация"],
            .author: ["en": "Author", "ru": "Автор"],
            .dimensions: ["en": "Dimensions", "ru": "Размер"],
            .aspectRatio: ["en": "Aspect Ratio", "ru": "Соотношение сторон"],
            .photoSingular: ["en": "photo", "ru": "фото"],
            .photoPlural: ["en": "photos", "ru": "фото"],
            .landscape: ["en": "Landscape", "ru": "Альбомная"],
            .portrait: ["en": "Portrait", "ru": "Портретная"],
            .square: ["en": "Square", "ru": "Квадрат"],
            .settingsSavedAppearance: ["en": "Appearance saved", "ru": "Тема сохранена"],
            .settingsSavedLanguage: ["en": "Language saved", "ru": "Язык сохранён"],
            .settingsSavedAppearanceAndLanguage: ["en": "Appearance and language saved", "ru": "Тема и язык сохранены"]
        ]
        return translations[self]?[languageCode] ?? translations[self]?["en"] ?? ""
    }
}

extension LocalizedString {
    func callAsFunction(for languageCode: String) -> String {
        localized(for: languageCode)
    }
}
