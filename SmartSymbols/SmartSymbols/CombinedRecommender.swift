import Combine
import CoreData
import CoreML
import NaturalLanguage

class CombinedRecommender: SmartSymbolRecommender {

    let queue = DispatchQueue(label: "icon_recommender",
                                      qos: .userInitiated)

    let embedding = try! NLEmbedding(contentsOf: IconModel.urlOfModelInThisBundle)

    private var sentenceEmbeddings: [NLLanguage: NLEmbedding] = [:]

    private func sentenceEmbedding(for language: NLLanguage) -> NLEmbedding? {
        if let embedding = sentenceEmbeddings[language] {
            return embedding
        } else {
            self.sentenceEmbeddings[language] = NLEmbedding.sentenceEmbedding(for: language)
            return self.sentenceEmbeddings[language]
        }
    }

    private static let supportLanguages: [NLLanguage] = [
        .english, .german, .french, .spanish, .italian, .portuguese
    ]

    private let recognizer: NLLanguageRecognizer = .init()


    init() {

    }



    func symbols(for title: String, maxResults: Int) -> [(Double, String)] {
        defer { recognizer.reset() }

        self.recognizer.processString(title)
        guard let language = recognizer.dominantLanguage,
              let sentenceEmbedding = sentenceEmbedding(for: language) else {
            return []
        }

        var results: [(String, NLDistance)] = []
        if let vector = sentenceEmbedding.vector(for: title)?.size(to: 640, fill: 0) {
            results += embedding.neighbors(for: vector, maximumCount: maxResults)
//                .filter { $0.1 <= 1 }
        }

        var icons: [String: Double] = [:]
        for (result, distance) in results {
            if let name = result.split(separator: "_").first,
               icons[String(name)] == nil {
                icons[String(name)] = distance
            }
        }

        return icons.sorted(by: { $0.value < $1.value }).map { ($1, $0) }
    }
}
