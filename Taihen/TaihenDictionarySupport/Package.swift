// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TaihenDictionarySupport",
    products: [
        .library(
            name: "TaihenDictionarySupport",
            targets: ["TaihenDictionarySupport"])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "TaihenDictionarySupport",
            dependencies: []),
        .testTarget(
            name: "TaihenDictionarySupportTests",
            dependencies: ["TaihenDictionarySupport"],
            resources: [
                .copy("Dictionaries")
            ])
    ]
)
