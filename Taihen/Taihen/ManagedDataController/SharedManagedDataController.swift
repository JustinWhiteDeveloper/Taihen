import Foundation

// Abstract away defining which implementation of the protocol is used
class SharedManagedDataController {
    static var tagManagementInstance: TagManagementDataController = RealmTagManagementDataController()
    static var appManagementInstance: AppManagementDataController = RealmAppManagementDataController()
    static var dictionaryInstance: DictionaryDataController = RealmManagedDictionaryController()
}
