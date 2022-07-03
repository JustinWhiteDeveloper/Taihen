import XCTest
import TaihenDictionarySupport

@testable import Taihen

class TagManagementDataControllerTests: XCTestCase {
    
    func testGivenATagManagementDataControllerThenCanGetColorWithoutExistingTags() throws {
        
        // given
        let controller = PersistenceController(inMemory: true)
        let tagManager = CoreDataTagManagementDataController(controller: controller)
        let tagName = "n"

        //when
        let color = tagManager.tagColor(tagName, colorScheme: YomichanColorScheme())
        
        //then
        XCTAssertEqual(color, Colors.purpleColor)
    }
    
    func testGivenATagManagementDataControllerThenCanGetColorWithoutExistingTagsWithPersistence() throws {
        
        // given
        let controller = PersistenceController(inMemory: true)
        let tagManager = CoreDataTagManagementDataController(controller: controller)
        let tagName = "q"

        //when
        tagManager.reloadTags()
        let color = tagManager.tagColor(tagName, colorScheme: YomichanColorScheme())

        //then
        XCTAssertEqual(color, Colors.purpleColor)
    }
    
    func testGivenATagManagementDataControllerThenCanUpdateTags() throws {
        
        // given
        let controller = PersistenceController(inMemory: true)
        let tagManager = CoreDataTagManagementDataController(controller: controller)
        let tagName = "s"
        let tag = TaihenCustomDictionaryTag(shortName: tagName, extraInfo: "", color: 3, tagDescription: "", piority: 0)
        
        //when
        tagManager.addTags(tags: [tag])
        tagManager.reloadTags()
        let color = tagManager.tagColor(tagName, colorScheme: YomichanColorScheme())

        //then
        XCTAssertEqual(color, Colors.darkGreyColor)
    }
    
    func testGivenATagManagementDataControllerThenCanReupdateTags() throws {
        
        // given
        let controller = PersistenceController(inMemory: true)
        let tagManager = CoreDataTagManagementDataController(controller: controller)
        let tagName = "d"
        let tag = TaihenCustomDictionaryTag(shortName: tagName, extraInfo: "", color: 3, tagDescription: "", piority: 0)
        
        //when
        tagManager.addTags(tags: [tag])
        tagManager.addTags(tags: [tag])
        tagManager.reloadTags()
        let color = tagManager.tagColor(tagName, colorScheme: YomichanColorScheme())

        //then
        XCTAssertEqual(color, Colors.darkGreyColor)
    }
    
    func testGivenATagManagementDataControllerThenTagsPersistEvenOnEmptyAdditionalCalls() throws {
        
        // given
        let controller = PersistenceController(inMemory: true)
        let tagManager = CoreDataTagManagementDataController(controller: controller)
        let tagName = "g"
        let tag = TaihenCustomDictionaryTag(shortName: tagName, extraInfo: "", color: 3, tagDescription: "", piority: 0)
        
        //when
        tagManager.addTags(tags: [tag])
        tagManager.addTags(tags: [])
        tagManager.reloadTags()
        let color = tagManager.tagColor(tagName, colorScheme: YomichanColorScheme())

        //then
        XCTAssertEqual(color, Colors.darkGreyColor)
    }
}
