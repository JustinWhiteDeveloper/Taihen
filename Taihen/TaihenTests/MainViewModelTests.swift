import XCTest

@testable import Taihen

class MainViewModelTests: XCTestCase {

    func testGivenAMainViewModelCanNavigateToTheReaderView() throws {
        
        // given
        let viewModel = MainViewModel(viewMode: .yomi)
        let view = MainView(viewModel: viewModel)
        
        // when
        viewModel.onViewModeSelection(viewMode: .reader)
        
        // then
        XCTAssertEqual(view.viewModel.viewMode, .reader)
    }
    
    func testGivenAMainViewModelCanNavigateToTheDictionaryView() throws {
        let viewModel = MainViewModel(viewMode: .settings)
        let view = MainView(viewModel: viewModel)
        
        viewModel.onViewModeSelection(viewMode: .dictionaries)
        
        XCTAssertEqual(view.viewModel.viewMode, .dictionaries)
    }
    
    func testGivenAMainViewModelCanNavigateToTheSettingsView() throws {
        let viewModel = MainViewModel(viewMode: .reader)
        let view = MainView(viewModel: viewModel)
        
        viewModel.onViewModeSelection(viewMode: .settings)
        
        XCTAssertEqual(view.viewModel.viewMode, .settings)
    }
    
    func testGivenAMainViewModelCanNavigateToTheLookupView() throws {
        let viewModel = MainViewModel(viewMode: .dictionaries)
        let view = MainView(viewModel: viewModel)
        
        viewModel.onViewModeSelection(viewMode: .yomi)
        
        XCTAssertEqual(view.viewModel.viewMode, .yomi)
    }
}
