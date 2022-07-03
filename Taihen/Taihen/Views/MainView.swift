import SwiftUI
import TaihenDictionarySupport
import Foundation

class MainViewModel: ObservableObject {
    
    @Published var viewMode: ViewMode
    @State var modes: [ViewMode] = [ViewMode.reader, ViewMode.yomi, ViewMode.dictionaries, ViewMode.settings]
        
    init(viewMode: ViewMode) {
        self.viewMode = viewMode
    }
    
    func onViewModeSelection(viewMode: ViewMode) {
        self.viewMode = viewMode
    }
}

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    @State private var readerViewModel = ReaderViewModel()
    @State private var dictionaryViewModel = DictionariesViewModel()
    
    var body: some View {

        VStack {
            
            HStack(alignment: .center) {

                SideMenu(modes: $viewModel.modes,
                         viewMode: $viewModel.viewMode) { viewMode in
                    viewModel.onViewModeSelection(viewMode: viewMode)
                }
                
                switch(viewModel.viewMode) {
                case .reader:
                    ReaderView(viewModel: readerViewModel)
                case .yomi:
                    LookupView()
                case .dictionaries:
                    DictionariesView(viewModel: dictionaryViewModel)
                default:
                    SettingsView()
                }
            }

        }
        .background(Colors.customGray1)
    }
}
