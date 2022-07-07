import SwiftUI

private enum Sizings {
    static let pillPadding: CGFloat = 8.0
    static let pillCornerRadius: CGFloat = 4.0
    static let pillSpacing: CGFloat = 4.0
}

struct TagPill: View {
    
    @State var text: String
    @State var color: Color = Color.red

    var body: some View {
        
        ZStack {
            Text(text)
                .bold()
                .foregroundColor(.white)
        }
        .padding(Sizings.pillPadding)
        .background(color)
        .cornerRadius(Sizings.pillCornerRadius)
    }
}

struct TagView: View {
    
    @State var tags: [String] = []
    
    var body: some View {
        
        LazyHStack(spacing: Sizings.pillSpacing) {
                        
            ForEach(Array(tags.enumerated()), id: \.offset) { index1, text in

                TagPill(text: text,
                        color: tagColor(tag: text))
            }
        }
    }
    
    func tagColor(tag: String) -> Color {
        let colorScheme = YomichanColorScheme()
        return SharedManagedDataController.tagManagementInstance.tagColor(tag, colorScheme: colorScheme)
    }
}
