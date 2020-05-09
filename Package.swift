// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignersWorkshopLibrary",
	platforms: [
		.macOS(.v10_15)
	],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DesignersWorkshopLibrary",
            targets: ["DesignersWorkshopLibrary"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		
		
		.package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DesignersWorkshopLibrary",
            dependencies: ["CryptoSwift"]),
        .testTarget(
            name: "DesignersWorkshopLibraryTests",
            dependencies: ["DesignersWorkshopLibrary"]),
    ]
)

#if os(Linux)
package.dependencies.append(.package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.5"))
package.targets[0].dependencies.append("SwiftyJSON")
#else
package.dependencies.append(.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"))
package.targets[0].dependencies.append("SwiftyJSON")
#endif

#if !canImport(Vapor) && !canImport(Fluent) && os(iOS)
package.dependencies.append(.package(url: "https://github.com/codewinsdotcom/PostgresClientKit", .upToNextMinor(from: "1.1.1")))
package.targets[0].dependencies.append("PostgresClientKit")
#endif
