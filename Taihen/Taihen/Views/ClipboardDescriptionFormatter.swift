import Foundation
import TaihenDictionarySupport

protocol ClipboardDescriptionFormatter {
    func formatForTerms(_ terms: [[String]]) -> String
}

class YomichanClipboardFormatter: ClipboardDescriptionFormatter {

    func formatForTerms(_ terms: [[String]]) -> String {
        
        var text = ""
        
        for (index, termArray) in terms.enumerated() {
            
            text += "\(index + 1). "
            
            let termsCount = termArray.count
            
            if termsCount == 1 {
                text += termArray.first ?? ""
                
            } else if termsCount > 1 {
                
                //put bullet on next line
                text += "\n"
                
                for (index, meaning) in termArray.enumerated() {
                    text += "•\t" + meaning
                    
                    let notLastItem = index < termsCount
                    if notLastItem {
                        text += "\n"
                    }
                }
            }
            
            text += "\n"
        }
        
        return text
    }
}
