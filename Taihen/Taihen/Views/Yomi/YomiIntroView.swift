import SwiftUI

private enum Strings {
    static let copyTextTitle = NSLocalizedString("Welcome to Taihen.",
                                                 comment: "")
    
    static let copyTextBody = NSLocalizedString("Before you get started head over to the Dictionaries tab to add new dictionaries.",
                                                comment: "")

    static let switchToDictionariesButtonTitle = NSLocalizedString("Switch to dictionaries tab", comment: "")
}

struct YomiIntroView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text(Strings.copyTextTitle)
                .foregroundColor(Color.black)
                .font(.title)
            
            Text(Strings.copyTextBody)
                .foregroundColor(Color.black)
                .font(.title)
            
            Button(Strings.switchToDictionariesButtonTitle) {
                
                NotificationCenter.default.post(name: Notification.Name.onSwitchToDictionaryView,
                                                object: nil)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
