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

    func getSuggestions(for occasion: Occasion? = nil) -> [OutfitSuggestion] {
        if let occasion {
            return [generateSuggestion(for: occasion)]
        }
        return Occasion.allCases.prefix(4).map { generateSuggestion(for: $0) }
    }

    private func generateSuggestion(for occasion: Occasion) -> OutfitSuggestion {
        let description: String
        switch occasion {
        case .casual:
            description = "Relaxed and comfortable for everyday"
        case .work:
            description = "Professional and polished"
        case .formal:
            description = "Elegant for special occasions"
        case .date:
            description = "Stylish and charming"
        case .athletic:
            description = "Ready for your workout"
        case .lounge:
            description = "Cozy and comfortable at home"
        case .outdoor:
            description = "Perfect for adventures"
        case .travel:
            description = "Practical and stylish on the go"
        case .special:
            description = "Stand out from the crowd"
        }
        return OutfitSuggestion(occasion: occasion, description: description)
    }
}
