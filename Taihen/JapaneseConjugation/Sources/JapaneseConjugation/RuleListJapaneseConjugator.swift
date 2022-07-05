import Foundation

// Basic hardcoded but incomplete implementation for comparision
public class RuleListJapaneseConjugator: JapaneseConjugator {
    
    let m1 = ReplacementRule(term: "まれている", replacements: ["む"])

    let s1 = ReplacementRule(term: "した", replacements: ["する", "す"])
    let s2 = ReplacementRule(term: "し", replacements: ["す"])
    let s3 = ReplacementRule(term: "せない", replacements: ["す"])
    
    let u1 = ReplacementRule(term: "わない", replacements: ["う"])
    let u2 = ReplacementRule(term: "われる", replacements: ["う"])
    let u3 = ReplacementRule(term: "っていた", replacements: ["う"])
    let u4 = ReplacementRule(term: "ってしまう", replacements: ["う"])
    let u5 = ReplacementRule(term: "っていた", replacements: ["う"])
    
    let r1 = ReplacementRule(term: "ている", replacements: ["る"])
    let r2 = ReplacementRule(term: "りました", replacements: ["る"])
    let r3 = ReplacementRule(term: "っていた", replacements: ["る"])
    let r4 = ReplacementRule(term: "ていた", replacements: ["る"])
    let r5 = ReplacementRule(term: "ており", replacements: ["る"])
    let r6 = ReplacementRule(term: "って", replacements: ["る"])

    let ru1 = ReplacementRule(term: "していた", replacements: ["する"])
    let ru2 = ReplacementRule(term: "れない", replacements: ["れる"])
    let ru3 = ReplacementRule(term: "えた", replacements: ["える"])
    let ru4 = ReplacementRule(term: "がらぬ", replacements: ["がる"])
    let ru5 = ReplacementRule(term: "めた", replacements: ["める"])
    let ru6 = ReplacementRule(term: "れた", replacements: ["れる"])
    let ru7 = ReplacementRule(term: "えなかった", replacements: ["える"])
    let ru8 = ReplacementRule(term: "げており", replacements: ["げる"])
    let ru9 = ReplacementRule(term: "まっていて", replacements: ["まる"])
    let ru10 = ReplacementRule(term: "なくなっていた", replacements: ["なくなる"])

    let k1 = ReplacementRule(term: "いてくる", replacements: ["く"])
    let k2 = ReplacementRule(term: "いている", replacements: ["く"])
    
    let i1 = ReplacementRule(term: "くとがっている", replacements: ["い"])
    
    let tsu1 = ReplacementRule(term: "っている", replacements: ["つ","る"])
    let tsu2 = ReplacementRule(term: "ち", replacements: ["つ"])
    
    let a1 = ReplacementRule(term: "ではなかった", replacements: ["では無い"])
    let a2 = ReplacementRule(term: "ばれてくる", replacements: ["ぶ"])
    
    let ta1 = ReplacementRule(term: "た", replacements: ["る"])

    public func correctTerm(_ term: String) -> [String]? {

        for item in items {
            
            if let search = item.attemptReplace(term) {
                 return search
            }
        }
        
        return nil
    }
    
    private var items: [ReplacementRule] {
        
        let rItems = [r1, r2, r3, r4, r5, r6]
        let uItems = [u1, u2, u3, u4, u5]
        let sItems = [s1, s2, s3]
        let ruItems = [ru1, ru2, ru3, ru4, ru5, ru6, ru7, ru8, ru9, ru10]
        let mItems = [m1]
        let kItems = [k1, k2]
        let iItems = [i1]
        let tsuItems = [tsu1, tsu2]
        let taItems = [ta1]

        var items = [a1, a2]
        
        items.append(contentsOf: kItems)
        items.append(contentsOf: uItems)
        items.append(contentsOf: rItems)
        items.append(contentsOf: sItems)
        items.append(contentsOf: mItems)
        items.append(contentsOf: ruItems)
        items.append(contentsOf: iItems)
        items.append(contentsOf: tsuItems)
        items.append(contentsOf: taItems)

        //Longer subs first
        items.sort { sub1, sub2 in
            sub1.term.count > sub2.term.count
        }
        
        return items
    }
    
    public init() { }
    
}
