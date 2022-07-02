import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation

private enum Strings {
    static let loadingText = NSLocalizedString("Loading", comment: "")
    static let noResultsText = NSLocalizedString("No results", comment: "")
}

struct YomiPreviewView: View {
    @State var hasBooted = false
    @State var lastResultCount = 0

    @State var isLoading = true
    @State var finishedLoadingDelay = true

    @State var lookupTime: Double = 0

    @State var selectedTerms: [[TaihenDictionaryViewModel]] = []
    @State var loadingText = Strings.loadingText
    @State var player: AVPlayer?
    @State var lastSearch = "*"

    @Binding var parentValue: String
    
    let pub = NotificationCenter.default
        .publisher(for: Notification.Name.onSelectionChange)
    
    var body: some View {
        
        VStack {
            
            if hasBooted {
                if isLoading {
                    
                    if finishedLoadingDelay {
                        CustomizableLoadingView(text: $loadingText)
                    } else {
                        Color.clear
                    }
                    
                } else {
                    
                    if lastResultCount > 0 {
                        YomiResultsView(search: lastSearch,
                                        selectedTerms: selectedTerms).onAppear {
  
                            if let url = selectedTerms.first?.first?.audioUrl,
                                FeatureManager.instance.autoplayAudio {
                                
                                do {
                                    let audioData = try Data(contentsOf: url)
                                    
                                    // Too long audio
                                    if audioData.count >= 52288 {
                                        return
                                    }
                                    
                                    
                                    let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("audio").appendingPathExtension("mp3")
                                    let wasFileWritten = (try? audioData.write(to: tmpFileURL, options: [.atomic])) != nil

                                    if !wasFileWritten{
                                        print("File was NOT Written")
                                    } else {
                                        
                                        player = AVPlayer(url: tmpFileURL)
                                        player?.volume = 1.0
                                        player?.play()
                                    }
                                }
                                catch {
                                    print(String(describing: error))
                                }
                            }
                        }

                    } else {
                        
                        ZStack {
                            Color.clear
                            Text(Strings.noResultsText)
                                .foregroundColor(Color.black)
                                .padding()
                        }
                        

                    }
                    
                    Text(lookupTime.description)
                        .foregroundColor(.black)
                }
            } else {
                Color.clear
            }
        }
        .onAppear {
            SharedManagedDataController.instance.reloadTags()
            SharedManagedDataController.dictionaryInstance.reloadDictionaries()
            
        }
        .onPasteboardChange {
            if FeatureManager.instance.clipboardReadingEnabled,
               let latestItem = NSPasteboard.general.clipboardContent()?.trimingTrailingSpaces(), CopyboardEnabler.enabled, latestItem.count < 100 {
                
                //Prevent accidently copying english text
                if latestItem.containsValidJapaneseCharacters == false || latestItem.contains("expression") {
                    return
                }
            
                onSearch(value: latestItem)
            }
        }
        .onReceive(pub) { (output) in
            
            if let outputText = output.object as? String {
                onSearch(value: outputText)
            }
        }
        .onChange(of: parentValue) { newValue in
            onSearch(value: parentValue)
        }
    }
    
    
    func onSearch(value: String) {
        
        if lastSearch == value {
            return
        }
        
        lastSearch = value
        
        hasBooted = true
        isLoading = true
        
        // Reset and add timer
        self.finishedLoadingDelay = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.finishedLoadingDelay = true
        }
        
        lookupTime = 0
        
        DispatchQueue.main.async {
            SharedManagedDataController.dictionaryInstance.searchValue(value: value) { finished, timeTaken, selectedTerms, resultCount in
                self.lookupTime = timeTaken
                self.isLoading = false
                self.selectedTerms = selectedTerms
                self.lastResultCount = resultCount
                self.finishedLoadingDelay = false

            }
        }
    }
}
