import ProjectDescription

public enum Constants {
    public static let appName = "Algourmand"
    public static let baseBundleId = "com.algourmand.app"

    public static let testSettings: [String: SettingValue] = [
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG"
    ]

    public static let devTeam = Environment.devTeam.getString(default: "5KP8875QV4")

    public static let baseSettings = SettingsDictionary()
        .currentProjectVersion("1")
        .marketingVersion("1.0.0")
        .automaticCodeSigning(devTeam: devTeam)

    public static let deploymentTarget = DeploymentTargets.iOS("17.0")
    public static let destinations: Destinations = [.iPhone, .iPad]

    public static let swiftlintScript = TargetScript.post(
        path: "scripts/lint.sh",
        name: "Swiftlint",
        basedOnDependencyAnalysis: false
    )

    public static let stripSymbolsScript = TargetScript.post(
        path: "scripts/strip_symbols.sh",
        name: "Strip Symbols (Release)",
        inputPaths: [
            "${DWARF_DSYM_FOLDER_PATH}/${EXECUTABLE_NAME}.app.dSYM/Contents/Resources/DWARF/${EXECUTABLE_NAME}"
        ],
        basedOnDependencyAnalysis: false
    )
}
