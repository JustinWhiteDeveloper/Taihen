import SwiftUI
import TaihenDictionarySupport
import Foundation

struct MainView: View {
    
    @State var dict: [String: [TaihenDictionaryViewModel]] = [:]
    @State var viewMode = ViewMode.reader
    @State var modes: [ViewMode] = []
        
    var body: some View {

        VStack {
            
            HStack(alignment: .center) {

                SideMenu(modes: $modes,
                         viewMode: $viewMode)
                
                switch(viewMode) {
                case .reader:
                    ReaderView()
                case .yomi:
                    YomiView()
                case .dictionaries:
                    DictionariesView()
                case .yomiPreview:
                    YomiPreviewView(parentValue: Binding.constant(""))
                default:
                    SettingsView()
                }
            }

        }
        .background(Colors.customGray1)
        .onAppear {
            modes = [ViewMode.reader, ViewMode.yomi, ViewMode.dictionaries, ViewMode.settings]
        }
    }
}

struct ContentView: View {

    var body: some View {
        MainView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
