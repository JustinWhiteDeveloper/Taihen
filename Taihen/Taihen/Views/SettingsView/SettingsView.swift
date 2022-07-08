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

class SettingsViewModel: ObservableObject {
    @Published var fontSliderValue = FeatureManager.instance.readerTextSize
    @Published var dictionaryFontSliderValue = FeatureManager.instance.dictionaryTextSize
    @Published var highlightsEnabled = FeatureManager.instance.enableTextHighlights
    @Published var autoPlayAudioEnabled = FeatureManager.instance.autoplayAudio
    @Published var positionScrollingEnabled = FeatureManager.instance.positionScrolling
    @Published var lookupPreviewEnabled = FeatureManager.instance.lookupPreviewEnabled
    @Published var readerBackgroundColor = FeatureManager.instance.readerBackgroundColor
    @Published var clipboardEnabled = FeatureManager.instance.clipboardReadingEnabled
    @Published var parserMode = FeatureManager.instance.textSelectionParserMode.rawValue
}

struct SettingsView: View {

    @ObservedObject var viewModel = SettingsViewModel()
    
    var appVersionString: String {
        ("Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""))
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                DictionariesView()
                
                VStack {
                    SettingsSliderView(text: Strings.readerFontSize,
                                       sliderValue: viewModel.fontSliderValue,
                                       maximumValue: Sizings.maximumFontSize) { value in
                        
                        FeatureManager.instance.readerTextSize = value
                    }
                    
                    SettingsSliderView(text: Strings.dictionaryFontSize,
                                       sliderValue: viewModel.dictionaryFontSliderValue,
                                       maximumValue: Sizings.maximumFontSize) { value in
                        
                        FeatureManager.instance.dictionaryTextSize = value
                    }
                }
                
                VStack(alignment: .center) {
                    
                    Toggle(Strings.enableHightlightsTitle, isOn: $viewModel.highlightsEnabled)
                        .onChange(of: viewModel.highlightsEnabled) { newValue in
                        FeatureManager.instance.enableTextHighlights = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    Toggle(Strings.autoPlayAudioTitle, isOn: $viewModel.autoPlayAudioEnabled)
                        .onChange(of: viewModel.autoPlayAudioEnabled) { newValue in
                            
                        FeatureManager.instance.autoplayAudio = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    Toggle(Strings.positionScrollingTitle, isOn: $viewModel.positionScrollingEnabled)
                        .onChange(of: viewModel.positionScrollingEnabled) { newValue in
                            
                        FeatureManager.instance.positionScrolling = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    Toggle(Strings.previewEnabledTitle, isOn: $viewModel.lookupPreviewEnabled)
                        .onChange(of: viewModel.lookupPreviewEnabled) { newValue in
                            
                        FeatureManager.instance.lookupPreviewEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    Toggle(Strings.listenForClipboardTitle, isOn: $viewModel.clipboardEnabled)
                        .onChange(of: viewModel.clipboardEnabled) { newValue in
                            
                            FeatureManager.instance.clipboardReadingEnabled = newValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    ColorPicker(selection: $viewModel.readerBackgroundColor) {
                        Label(Strings.readerBackgroundColorTitle, image: "")
                            .foregroundColor(Color.black)
                    }.onChange(of: viewModel.readerBackgroundColor) { newValue in
                        FeatureManager.instance.readerBackgroundColor = newValue
                    }

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                VStack(alignment: .center) {

                    Text(Strings.parserModeTitle + viewModel.parserMode.description)
                        .foregroundColor(Color.black)

                    Button(Strings.parserChangeActionTitle) {
                        viewModel.parserMode = FeatureManager.instance.changeToNextParserMode().rawValue
                    }
                    .foregroundColor(Color.black)

                }
                .padding()
                .frame(width: Sizings.standardWidth)
                
                Text(appVersionString)
                    .foregroundColor(Color.black)
                
            }
        }
    }
}
