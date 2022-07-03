import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation

struct YomiResultCollectionView: View {
    
    @State var search: String
    @State var selectedTerms: [[TaihenDictionaryViewModel]] = []

    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading) {
                ForEach(Array(selectedTerms.enumerated()), id: \.offset) { index, termItem in
                                    
                    ForEach(Array(termItem.enumerated()), id: \.offset) { index2, item in
                    
                        YomiResultItemView(search: search,
                                     term: item.groupTerm,
                                     kana: item.kana,
                                     terms: item.terms,
                                     tags: item.tags,
                                     audioUrl: item.audioUrl)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
