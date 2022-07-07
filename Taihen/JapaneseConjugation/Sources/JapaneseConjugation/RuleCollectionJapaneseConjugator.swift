import Foundation

// Basic hardcoded but incomplete implementation for comparision
public class RuleCollectionJapaneseConjugator: JapaneseConjugator {
    
    private let excelSeperator = "    "

    public func correctTerm(_ term: String) -> [String]? {

        for item in items {
            
            if let search = item.attemptReplace(term) {
                 return search
            }
        }
        
        return nil
    }
    
    private var items: [ReplacementRule] {
        
        var items: [ReplacementRule] = []
        
        if let csvFilepath = Bundle.module.path(forResource: "RuleMap", ofType: "csv") {
            do {
                let contents = try String(contentsOfFile: csvFilepath)
                
                let lines = contents.split(separator: "\n")
                
                for line in lines {
                    let parts = line.components(separatedBy: excelSeperator)
                    
                    if let term = parts.first, parts.count == 2 {
                        
                        let secondPart = parts[1]
                        
                        let mappedValues = secondPart.components(separatedBy: ",")
                        
                        let rule = ReplacementRule(term: term, replacements: mappedValues)
                        
                        items.append(rule)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        } else {
            return items
        }
        
        //Longer subs first
        items.sort { sub1, sub2 in
            sub1.term.count > sub2.term.count
        }
        
        return items
    }
    
    public init() { }
    
}
