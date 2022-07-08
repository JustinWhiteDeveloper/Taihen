import SwiftUI
import TaihenDictionarySupport
import Foundation

class MainViewModel: ObservableObject {
    
    @Published var viewMode: ViewMode
    @State var modes: [ViewMode] = [ViewMode.reader, ViewMode.yomi, ViewMode.settings]
        
    init(viewMode: ViewMode) {
        self.viewMode = viewMode
    }
    
    func onViewModeSelection(viewMode: ViewMode) {
        if self.viewMode != viewMode {
            self.viewMode = viewMode
        }
    }
}

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    
    var body: some View {

        VStack {
            
            HStack(alignment: .center, spacing: 0) {

                SideMenu(modes: $viewModel.modes,
                         viewMode: $viewModel.viewMode) { viewMode in
                    viewModel.onViewModeSelection(viewMode: viewMode)
                }
                
                switch viewModel.viewMode {
                case .reader:
                    ReaderView()
                case .yomi:
                    LookupContainerView()
                default:
                    SettingsView()
                }
            }

        }
        .background(Colors.customGray1)
    }
}
