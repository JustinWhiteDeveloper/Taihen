// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JapaneseConjugation",
    products: [
        .library(
            name: "JapaneseConjugation",
            targets: ["JapaneseConjugation"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "JapaneseConjugation",
            dependencies: [],
            resources: [
                .copy("RuleMap.csv")
            ]
        ),
        .testTarget(
            name: "JapaneseConjugationTests",
            dependencies: ["JapaneseConjugation"]),
    ]
)
