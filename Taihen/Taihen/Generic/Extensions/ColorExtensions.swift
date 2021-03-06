import Foundation
import SwiftUI

enum Colors {
    static let customGray1 = Color(red: 0.87, green: 0.87, blue: 0.87)
    static let customGray2 = Color(red: 0.83, green: 0.83, blue: 0.83)
}

protocol ColorScheme {
    func integerToColor(_ color: Int?) -> Color
}

class YomichanColorScheme: ColorScheme {

    func integerToColor(_ color: Int?) -> Color {
        
        if let item = color {
            
            // Note: Values are normally negative
            switch abs(item) {
            case 0:
                return Colors.lightGreyColor
            case 2:
                return Colors.cyanColor
            case 3:
                return Colors.darkGreyColor
            case 5:
                return Colors.lightOrangeColor
            case 10:
                return Colors.darkBlueColor
            default:
                return Colors.purpleColor
            }
        }
        
        return Colors.purpleColor
    }
}

// Yomichan Color extension
extension Colors {
    static let darkBlueColor = Color(red: 2/255, green: 117/255, blue: 216/255)
    static let purpleColor = Color(red: 160/255.0, green: 105/255.0, blue: 198/255.0)
    static let cyanColor = Color(red: 117/255.0, green: 190/255.0, blue: 219/255.0)
    static let darkGreyColor = Color(red: 86/255.0, green: 86/255.0, blue: 86/255.0)
    static let lightGreyColor = Color(red: 138/255.0, green: 138/255.0, blue: 144/255.0)
    static let lightOrangeColor = Color(red: 230/255.0, green: 176/255.0, blue: 95/255.0)
}
