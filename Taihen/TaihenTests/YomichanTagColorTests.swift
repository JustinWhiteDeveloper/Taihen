import XCTest
import SwiftUI

@testable import Taihen


class YomichanTagColorTests: XCTestCase {

    func testGivenAYomichanColorSchemeThatUnknownTagsAreColoredProperly() throws {
        
        // given
        let colorInteger1: Int? = nil
        let colorInteger2: Int? = 1 // Note: 1 is currently unknown

        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.purpleColor
        
        //when
        let actualColor1 = colorScheme.integerToColor(colorInteger1)
        let actualColor2 = colorScheme.integerToColor(colorInteger2)

        //then
        XCTAssertEqual(expectedColor, actualColor1)
        XCTAssertEqual(expectedColor, actualColor2)
    }
    
    func testGivenAYomichanColorSchemeThatNegativeNumberedTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = -5
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.lightOrangeColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testGivenAYomichanColorSchemeThatZeroNumberedTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = 0
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.lightGreyColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testGivenAYomichanColorSchemeThatCyanTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = 2
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.cyanColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testGivenAYomichanColorSchemeThatDarkGreyTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = 3
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.darkGreyColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testGivenAYomichanColorSchemeThatLightOrangeTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = 5
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.lightOrangeColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testGivenAYomichanColorSchemeThatDarkBlueTagsAreColoredProperly() throws {
        
        // given
        let colorInteger: Int? = 10
        let colorScheme = YomichanColorScheme()
        let expectedColor = Colors.darkBlueColor
        
        //when
        let actualColor = colorScheme.integerToColor(colorInteger)
        
        //then
        XCTAssertEqual(expectedColor, actualColor)
    }
}
