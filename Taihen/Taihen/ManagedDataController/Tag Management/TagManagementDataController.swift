import Foundation
import TaihenDictionarySupport
import SwiftUI

protocol TagManagementDataController {
    func reloadTags()
    func addTags(tags: [TaihenCustomDictionaryTag])
    func tagColor(_ key: String, colorScheme: ColorScheme) -> Color
}
