import Foundation

enum ViewMode: String, CaseIterable {
    case reader
    case dictionaries
    case yomi
    case settings
    
    var imageName: String {
        switch self {
        case .reader:
            return "book"
        case .dictionaries:
            return "textformat.size"
        case .yomi:
            return "magnifyingglass"
        default:
            return "gear"
        }
    }
}
