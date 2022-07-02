import SwiftUI

private enum Strings {
    static let readerFontSize = NSLocalizedString("Reader Text Size", comment: "")
    static let dictionaryFontSize = NSLocalizedString("Dictionary Text Size", comment: "")
}

private enum Sizings {
    static let standardWidth: CGFloat = 400.0
    
    static let maximumFontSize = 60.0
}

struct SettingsView: View {

    @State var fontSliderValue = FeatureManager.instance.readerTextSize
    @State var dictionaryFontSliderValue = FeatureManager.instance.dictionaryTextSize
    @State var highlightsEnabled = FeatureManager.instance.enableTextHighlights
    @State var audioEnabled = FeatureManager.instance.autoplayAudio
    @State var positionScrollingEnabled = FeatureManager.instance.positionScrolling
    @State var lookupPreviewEnabled = FeatureManager.instance.lookupPreviewEnabled
    @State var readerBackgroundColor = FeatureManager.instance.readerBackgroundColor
    @State var clipboardEnabled = FeatureManager.instance.clipboardReadingEnabled
    @State var parserMode = FeatureManager.instance.parserMode.rawValue
    
    var body: some View {
        
        HStack {
            Spacer()
            
            List {
                SettingsSliderView(text: Strings.readerFontSize,
                                   sliderValue: fontSliderValue,
                                   maximumValue: Sizings.maximumFontSize) { value in
                    
                    FeatureManager.instance.readerTextSize = value
                }
                
                SettingsSliderView(text: Strings.dictionaryFontSize,
                                   sliderValue: dictionaryFontSliderValue,
                                   maximumValue: Sizings.maximumFontSize) { value in
                    
                    FeatureManager.instance.dictionaryTextSize = value
                }
                
                VStack(alignment: .center) {
                    
                    Toggle("Enable Highlights", isOn:  $highlightsEnabled).onChange(of: highlightsEnabled) { newValue in
                        FeatureManager.instance.enableTextHighlights = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle("Auto-play Audio", isOn:  $audioEnabled)
                        .onChange(of: audioEnabled) { newValue in
                            
                        FeatureManager.instance.autoplayAudio = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle("Position Scrolling", isOn:  $positionScrollingEnabled)
                        .onChange(of: positionScrollingEnabled) { newValue in
                            
                        FeatureManager.instance.positionScrolling = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle("Look up preview", isOn:  $lookupPreviewEnabled)
                        .onChange(of: lookupPreviewEnabled) { newValue in
                            
                        FeatureManager.instance.lookupPreviewEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle("Listen for Clipboard changes", isOn:  $clipboardEnabled)
                        .onChange(of: clipboardEnabled) { newValue in
                            
                            FeatureManager.instance.clipboardReadingEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                
                VStack(alignment: .center) {
 
                    ColorPicker(selection: $readerBackgroundColor) {
                        Label("Reader background color", image: "")
                            .foregroundColor(Color.black)
                    }.onChange(of: readerBackgroundColor) { newValue in
                        FeatureManager.instance.readerBackgroundColor = newValue
                    }

                }
                .padding()
                .frame(width: 400.0)
                
                VStack(alignment: .center) {
 
                    Text("Parser Mode "  + parserMode.description)
                        .foregroundColor(Color.black)

                    Button("Change JP Mode") {
                        parserMode = FeatureManager.instance.changeToNextParserMode().rawValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
            }
            
            Spacer()
            
        }
    }
}
