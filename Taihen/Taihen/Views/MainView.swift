import SwiftUI
import TaihenDictionarySupport
import Foundation

class MainViewModel: ObservableObject {
    
    @Published var viewMode: ViewMode
    @State var modes: [ViewMode] = [ViewMode.reader, ViewMode.dictionaries, ViewMode.settings]
        
    init(viewMode: ViewMode) {
        self.viewMode = viewMode
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRecieveNotification(notification:)),
                                               name: Notification.Name.onSwitchToDictionaryView,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onViewModeSelection(viewMode: ViewMode) {
        if self.viewMode != viewMode {
            self.viewMode = viewMode
        }
    }
    
    @objc func onRecieveNotification(notification: Notification) {
        guard notification.name == Notification.Name.onSwitchToDictionaryView else {
            return
        }
        
        onViewModeSelection(viewMode: .dictionaries)
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
                case .dictionaries:
                    DictionariesView()
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
