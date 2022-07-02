import SwiftUI

private enum Sizings {
    static let standardSliderWidth: CGFloat = 400.0
}

struct SettingsSliderView: View {
    
    @State var text: String
    
    @State var sliderValue: Double
    @State var maximumValue: Double
    
    var onChange: (_ value: Double) -> Void
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text(text)
                .font(Font.system(size: sliderValue))
                .foregroundColor(Color.black)

            Text(String(sliderValue))
                .foregroundColor(Color.black)

            Slider(value: $sliderValue, in: 1...maximumValue, step: 1.0) { changed in
                onChange(sliderValue)
            }
        }
        .padding()
        .frame(width: Sizings.standardSliderWidth)
        
        Spacer()
    }
}
