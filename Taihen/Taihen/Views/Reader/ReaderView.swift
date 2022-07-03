import Foundation
import SwiftUI
import UserNotifications

private enum Sizings {
    static let dictionaryPreviewMaximumSize: CGFloat = 600.0
}

class ReaderViewModel: ObservableObject {
    
    @State var text = ""
    @State var highlights: [NSRange] = []
    @State var scrollPercentage: Float = 0.0
        
    init() {}
}

struct ReaderView: View {

    @State var text = ""
    @State var highlights: [NSRange] = []
    @State var scrollPercentage: Float = 0.0
    
    private let pub = NotificationCenter.default.publisher(for: Notification.Name.onReadFile)

    var body: some View {
        
        ZStack {
            
            HSplitView() {
                CustomizableTextEditor(text: $text, highlights: $highlights, scrollPercentage: $scrollPercentage)
                    .onReceive(pub) { (output) in
                        
                        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
                            return
                        }
                        
                        let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
                        
                        text = data?.content ?? ""
                    }
                if FeatureManager.instance.lookupPreviewEnabled {

                    YomiSearchView(parentValue: Binding.constant(""))
                        .background(Colors.customGray1)
                        .padding()
                        .frame(maxWidth: Sizings.dictionaryPreviewMaximumSize)
                }
                
            }.onAppear {
                
                guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
                    return
                }
                
                let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
                
                let marks: [ManagedHighlight] = data?.highlights ?? []
                
                highlights = marks.map({ $0.range } )
                text = data?.content ?? ""
            }
            
            HStack(alignment: .top) {
                Spacer()
                
                VStack(alignment: .trailing) {

                    Text(String(format: "%.2f", scrollPercentage * 100) + "%")
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
            }
        }
    }
}

