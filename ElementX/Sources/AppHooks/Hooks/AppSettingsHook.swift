//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

nonisolated protocol AppSettingsHookProtocol: Sendable {
    @MainActor func configure(_ appSettings: AppSettings) -> AppSettings
}

struct DefaultAppSettingsHook: AppSettingsHookProtocol {
    func configure(_ appSettings: AppSettings) -> AppSettings {
        appSettings.override(
            accountProviders: ["chat.zem.systems"],
            allowOtherAccountProviders: false,
            hideBrandChrome: false,
            pushGatewayBaseURL: URL(string: "https://chat.zem.systems")!,
            oAuthRedirectURL: URL(string: "https://chat.zem.systems/oauth/ios/\(InfoPlistReader.main.bundleIdentifier)")!,
            oAuthClientURIPath: "apps/ios",
            websiteURL: URL(string: "https://fresco.zem.systems")!,
            logoURL: URL(string: "https://fresco.zem.systems/brand/icon.svg")!,
            copyrightURL: appSettings.copyrightURL,
            acceptableUseURL: appSettings.acceptableUseURL,
            privacyURL: appSettings.privacyURL,
            encryptionURL: appSettings.encryptionURL,
            deviceVerificationURL: appSettings.deviceVerificationURL,
            chatBackupDetailsURL: appSettings.chatBackupDetailsURL,
            identityPinningViolationDetailsURL: appSettings.identityPinningViolationDetailsURL,
            historySharingDetailsURL: appSettings.historySharingDetailsURL,
            elementWebHosts: ["fresco.zem.systems", "chat.zem.systems"],
            accountProvisioningHost: "chat.zem.systems",
            bugReportApplicationID: "fresco-ios",
            analyticsTermsURL: appSettings.analyticsTermsURL,
            mapTilerConfiguration: AppSettings.bundledMapTilerConfiguration
        )
        return appSettings
    }
}
