//
//  OutfitSuggestionService.swift
//  drip
//

import Foundation

@MainActor
@Observable
final class OutfitSuggestionService {
    struct OutfitSuggestion: Identifiable {
        let id = UUID()
        let occasion: Occasion
        let description: String
    }

    func getSuggestions(from occasions: [Occasion], for occasion: Occasion? = nil) -> [OutfitSuggestion] {
        if let occasion {
            return [OutfitSuggestion(occasion: occasion, description: occasion.suggestionDescription)]
        }
        return occasions.prefix(4).map { occ in
            OutfitSuggestion(occasion: occ, description: occ.suggestionDescription)
        }
    }
}
