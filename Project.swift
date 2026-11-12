import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Constants.appName,
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .notGrouped
        ),
        developmentRegion: "fr"
    ),
    settings: .settings(
        base: Constants.baseSettings,
        defaultSettings: .recommended
    ),
    targets: [
        // MARK: - Algourmand (Main App)
        .target(
            name: Constants.appName,
            destinations: Constants.destinations,
            product: .app,
            bundleId: Constants.baseBundleId,
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "CFBundleDisplayName": "$(PRODUCT_NAME)",
                "UISupportedInterfaceOrientations": .array([
                    .string("UIInterfaceOrientationPortrait"),
                    .string("UIInterfaceOrientationLandscapeLeft"),
                    .string("UIInterfaceOrientationLandscapeRight")
                ]),
                "NSAppTransportSecurity": .dictionary([
                    "NSAllowsLocalNetworking": .boolean(true)
                ])
            ]),
            sources: ["\(Constants.appName)/**"],
            resources: ["\(Constants.appName)/Resources/**"],
            scripts: [
                Constants.swiftlintScript,
                Constants.stripSymbolsScript
            ],
            dependencies: [
                .target(name: "\(Constants.appName)Core"),
                .target(name: "\(Constants.appName)CoreUI")
            ],
            settings: .settings(base: Constants.baseSettings)
        ),

        // MARK: - AlgourmandCore (Business Logic, Models, API)
        .target(
            name: "\(Constants.appName)Core",
            destinations: Constants.coreDestinations,
            product: .framework,
            bundleId: "\(Constants.baseBundleId).core",
            deploymentTargets: Constants.coreDeploymentTargets,
            infoPlist: .default,
            sources: ["\(Constants.appName)Core/**"],
            dependencies: [],
            settings: .settings(base: Constants.baseSettings)
        ),

        // MARK: - AlgourmandCoreUI (Design System, Reusable UI Components)
        .target(
            name: "\(Constants.appName)CoreUI",
            destinations: Constants.destinations,
            product: .framework,
            bundleId: "\(Constants.baseBundleId).coreui",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .default,
            sources: ["\(Constants.appName)CoreUI/**"],
            dependencies: [
                .target(name: "\(Constants.appName)Core")
            ],
            settings: .settings(base: Constants.baseSettings)
        ),

        // MARK: - AlgourmandTests (Unit Tests)
        .target(
            name: "\(Constants.appName)Tests",
            destinations: Constants.coreDestinations,
            product: .unitTests,
            bundleId: "\(Constants.baseBundleId).tests",
            deploymentTargets: Constants.coreDeploymentTargets,
            infoPlist: .default,
            sources: ["\(Constants.appName)Tests/**"],
            dependencies: [
                .target(name: "\(Constants.appName)Core")
            ],
            settings: .settings(base: Constants.testSettings)
        )
    ]
)
