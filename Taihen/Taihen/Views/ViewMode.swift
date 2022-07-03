import Foundation

enum ViewMode: String, CaseIterable {
    case reader = "Reader"
    case yomi = "Lookup tool"
    case dictionaries = "Dictionaries"
    case settings = "Settings"
    
    var imageName: String {
        switch self {
        case .reader:
            return "book"
        case .yomi:
            return "list.dash"
        case .dictionaries:
            return "folder"
        default:
            return "gear"
        }
    }
}
