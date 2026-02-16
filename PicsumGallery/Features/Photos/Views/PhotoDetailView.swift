import SwiftUI

struct PhotoDetailView: View {
    let photo: PicsumPhoto
    @Environment(\.appSettings) private var appSettings
    @State private var isPreparingPrint = false
    @State private var printErrorMessage = ""
    @State private var isShowingPrintError = false

    private var localize: (LocalizedString) -> String {
        { $0.localized(for: appSettings.languageCode) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photoImage
                    .glassStyleBackground(cornerRadius: 16)
                photoMetadata
                    .glassStyleBackground(cornerRadius: 16)
            }
            .padding()
        }
        .navigationTitle(localize(.photo))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarActions }
        .onAppear {
            HapticManager.shared.lightImpact()
        }
        .alert(localize(.printFailedTitle), isPresented: $isShowingPrintError) {
            Button(localize(.done), role: .cancel) {
                HapticManager.shared.lightImpact()
            }
        } message: {
            Text(printErrorMessage)
        }
    }
    
    private var photoImage: some View {
        CachedAsyncImage(url: URL(string: photo.downloadUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            loadingView
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text(localize(.loadingImage))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 300)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }

    @ToolbarContentBuilder
    private var toolbarActions: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if let shareURL {
                    ShareLink(item: shareURL) {
                        Label(localize(.share), systemImage: "square.and.arrow.up")
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            HapticManager.shared.lightImpact()
                        }
                    )
                } else {
                    Label(localize(.share), systemImage: "square.and.arrow.up")
                }

                Button {
                    HapticManager.shared.mediumImpact()
                    Task {
                        await printPhoto()
                    }
                } label: {
                    if isPreparingPrint {
                        Label(localize(.preparingPrint), systemImage: "printer")
                    } else {
                        Label(localize(.print), systemImage: "printer")
                    }
                }
                .disabled(isPreparingPrint || shareURL == nil)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
            }
            .accessibilityLabel(localize(.moreActions))
        }
    }

    private var shareURL: URL? {
        URL(string: photo.downloadUrl) ?? photo.url
    }

    @MainActor
    private func printPhoto() async {
        guard !isPreparingPrint else { return }
        guard let shareURL else {
            presentPrintError(localize(.printUnavailable))
            return
        }

        isPreparingPrint = true
        defer { isPreparingPrint = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: shareURL)
            guard let image = UIImage(data: data) else {
                presentPrintError(localize(.printUnavailable))
                return
            }

            let controller = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .photo
            printInfo.jobName = photo.author
            controller.printInfo = printInfo
            controller.printingItem = image
            controller.showsNumberOfCopies = true

            if UIDevice.current.userInterfaceIdiom == .pad {
                guard let rootViewController = activeRootViewController() else {
                    presentPrintError(localize(.printUnavailable))
                    return
                }
                controller.present(
                    from: rootViewController.view.bounds,
                    in: rootViewController.view,
                    animated: true,
                    completionHandler: nil
                )
            } else {
                controller.present(animated: true, completionHandler: nil)
            }
            HapticManager.shared.success()
        } catch {
            presentPrintError(localize(.printUnavailable))
        }
    }

    @MainActor
    private func presentPrintError(_ message: String) {
        printErrorMessage = message
        isShowingPrintError = true
        HapticManager.shared.error()
    }

    @MainActor
    private func activeRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let keyWindow = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        return keyWindow?.rootViewController
    }
    
    private var photoMetadata: some View {
        PhotoMetadataSection(
            photo: photo,
            sectionTitle: localize(.information),
            authorTitle: localize(.author),
            dimensionsTitle: localize(.dimensions),
            aspectRatioTitle: localize(.aspectRatio)
        )
    }
}

#Preview {
    guard let url = URL(string: "https://picsum.photos/id/1/1920/1080") else {
        return Text(LocalizedString.invalidUrl.localized(for: "en"))
    }
    let mockPhoto = PicsumPhoto(
        id: PicsumPhotoID(value: "1"),
        author: "John Doe",
        width: 1920,
        height: 1080,
        url: url,
        downloadUrl: "https://picsum.photos/id/1/1920/1080"
    )
    return NavigationStack {
        PhotoDetailView(photo: mockPhoto)
            .environment(\.appSettings, AppSettings.shared)
    }
}
