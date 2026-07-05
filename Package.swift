// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SentinelMac",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "SentinelMac",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/SentinelMac",
            // Sparkle.framework est copié dans SentinelMac.app/Contents/Frameworks
            // par scripts/build_app_bundle.sh (pas de projet Xcode ici, donc pas
            // de phase "Embed Frameworks" automatique) — le binaire doit savoir
            // chercher là au lancement.
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        )
    ]
)
