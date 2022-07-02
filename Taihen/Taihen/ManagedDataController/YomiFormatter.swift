import Foundation
import TaihenDictionarySupport

class YomiFormatter {

    func formatForTerms(terms: TaihenDictionaryViewModel) -> String {
        
        var text = ""
        
        for (index, term) in terms.terms.enumerated() {
            
            text += "\(index + 1). "
            
            if term.meanings.count == 1 {
                text += term.meanings.first ?? ""
            }
            else if term.meanings.count > 1 {
                
                //put bullet on next line
                text += "\n"
                
                for (index, meaning) in term.meanings.enumerated() {
                    text += "•\t" + meaning
                    
                    if index < term.meanings.count {
                        text += "\n"
                    }
                }
            }
            
            text += "\n"
        }
        
        return text
    }
    
}
