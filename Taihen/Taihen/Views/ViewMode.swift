import Foundation

enum ViewMode: String, CaseIterable {
    case reader = "Reader"
    case yomi = "Lookup tool"
    case dictionaries = "Dictionaries"
    case settings = "Settings"
    case yomiPreview = "Preview"
    
    var imageName: String {
        switch self {
        case .reader:
            return "book"
        case .yomiPreview, .yomi:
            return "list.dash"
        case .dictionaries:
            return "folder"
        default:
            return "gear"
        }
    }
}
