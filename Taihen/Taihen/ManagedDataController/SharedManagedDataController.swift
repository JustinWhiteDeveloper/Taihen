import Foundation

protocol ManagedControllerResetSupport {
    func reset(callback: @escaping () -> Void)
}

// Abstract away defining which implementation of the protocol is used
class SharedManagedDataController {
    static var tagManagementInstance: TagManagementDataController = CoreDataTagManagementDataController()
    static var appManagementInstance: AppManagementDataController = CoreDataAppManagementDataController()
    static var dictionaryInstance: DictionaryDataReaderWriterController &
                                    DictionaryReloadController &
                                    DictionarySearchController = RealmManagedDictionaryController()
    
    static func resetAll(callback: @escaping () -> Void) {
        
        tagManagementInstance.reset {
            
            appManagementInstance.reset {
                
                dictionaryInstance.reset {
                    
                    callback()
                }
            }
        }
        
    }
}
