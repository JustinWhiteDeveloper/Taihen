import SwiftUI

private enum Strings {
    static let copyTextTitle = NSLocalizedString("Welcome to Taihen",
                                                 comment: "")

    static let copyTextBodyNewUser = NSLocalizedString("""
    Before you get started head over to the Dictionaries tab to add new dictionaries.
    """,
                                                comment: "")
    
    static let copyTextBodyExistingUser = NSLocalizedString("""
    Select content to search.
    """,
                                                comment: "")

    static let switchToDictionariesButtonTitle = NSLocalizedString("Switch to Dictionaries Tab", comment: "")
}

private enum Sizings {
    static let itemSpacing: CGFloat = 20.0
}

struct YomiIntroView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: Sizings.itemSpacing) {
            Text(Strings.copyTextTitle)
                .foregroundColor(Color.black)
                .font(.title)
            
            if !FeatureManager.instance.userHasFinishedIntro {
                Text(Strings.copyTextBodyNewUser)
                    .foregroundColor(Color.black)
                    .font(.title2)
                
                Button(Strings.switchToDictionariesButtonTitle) {
                    
                    NotificationCenter.default.post(name: Notification.Name.onSwitchToDictionaryView,
                                                    object: nil)
                }
            } else {
                Text(Strings.copyTextBodyExistingUser)
                    .foregroundColor(Color.black)
                    .font(.title2)
            }
            
        }
        .frame(maxHeight: .infinity)
    }
}
