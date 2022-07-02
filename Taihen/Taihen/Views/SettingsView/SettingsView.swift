import SwiftUI

private enum Strings {
    static let readerFontSize = NSLocalizedString("Reader Text Size", comment: "")
    static let dictionaryFontSize = NSLocalizedString("Dictionary Text Size", comment: "")
    
    static let enableHightlightsTitle = NSLocalizedString("Enable Highlights", comment: "")
    static let autoPlayAudioTitle = NSLocalizedString("Auto-play Audio", comment: "")
    static let positionScrollingTitle = NSLocalizedString("Keep track of reader position", comment: "")
    static let previewEnabledTitle = NSLocalizedString("Dictionary preview enabled", comment: "")
    static let listenForClipboardTitle = NSLocalizedString("Listen for Clipboard changes", comment: "")
    static let readerBackgroundColorTitle = NSLocalizedString("Reader background color", comment: "")
    static let parserModeTitle = NSLocalizedString("Parser Mode ", comment: "")
    static let parserChangeActionTitle = NSLocalizedString("Change JP Mode", comment: "")
}

private enum Sizings {
    static let standardWidth: CGFloat = 400.0
    static let maximumFontSize = 60.0
}

struct SettingsView: View {

    @State var fontSliderValue = FeatureManager.instance.readerTextSize
    @State var dictionaryFontSliderValue = FeatureManager.instance.dictionaryTextSize
    @State var highlightsEnabled = FeatureManager.instance.enableTextHighlights
    @State var autoPlayAudioEnabled = FeatureManager.instance.autoplayAudio
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
                    
                    Toggle(Strings.enableHightlightsTitle, isOn:  $highlightsEnabled).onChange(of: highlightsEnabled) { newValue in
                        FeatureManager.instance.enableTextHighlights = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle(Strings.autoPlayAudioTitle, isOn:  $autoPlayAudioEnabled)
                        .onChange(of: autoPlayAudioEnabled) { newValue in
                            
                        FeatureManager.instance.autoplayAudio = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle(Strings.positionScrollingTitle, isOn:  $positionScrollingEnabled)
                        .onChange(of: positionScrollingEnabled) { newValue in
                            
                        FeatureManager.instance.positionScrolling = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle(Strings.previewEnabledTitle, isOn:  $lookupPreviewEnabled)
                        .onChange(of: lookupPreviewEnabled) { newValue in
                            
                        FeatureManager.instance.lookupPreviewEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Toggle(Strings.listenForClipboardTitle, isOn:  $clipboardEnabled)
                        .onChange(of: clipboardEnabled) { newValue in
                            
                            FeatureManager.instance.clipboardReadingEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                
                VStack(alignment: .center) {
 
                    ColorPicker(selection: $readerBackgroundColor) {
                        Label(Strings.readerBackgroundColorTitle, image: "")
                            .foregroundColor(Color.black)
                    }.onChange(of: readerBackgroundColor) { newValue in
                        FeatureManager.instance.readerBackgroundColor = newValue
                    }

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {
 
                    Text(Strings.parserModeTitle  + parserMode.description)
                        .foregroundColor(Color.black)

                    Button(Strings.parserChangeActionTitle) {
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
