import Foundation

enum ViewMode: String, CaseIterable {
    case reader
    case yomi
    case settings
    
    var imageName: String {
        switch self {
        case .reader:
            return "book"
        case .yomi:
            return "magnifyingglass"
        default:
            return "gear"
        }
    }
}
