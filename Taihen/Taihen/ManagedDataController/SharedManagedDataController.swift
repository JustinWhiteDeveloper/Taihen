import Foundation

// Abstract away defining which implementation of the protocol is used
class SharedManagedDataController {
    static var tagManagementInstance: TagManagementDataController = CoreDataTagManagementDataController()
    static var appManagementInstance: AppManagementDataController = CoreDataAppManagementDataController()
    static var dictionaryInstance = RealmManagedDictionaryController()
}
