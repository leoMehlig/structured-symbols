import Combine
import CoreData
import CoreML
import NaturalLanguage

class EmbeddingRecommender: SmartSymbolRecommender {

    let queue = DispatchQueue(label: "icon_recommender",
                                      qos: .userInitiated)

    private func modelEmbeddings(for language: NLLanguage) -> NLEmbedding? {
        switch language {
        case .english:
            return try? NLEmbedding(contentsOf: IconModelEN.urlOfModelInThisBundle)
        case .german:
            return try? NLEmbedding(contentsOf: IconModelDE.urlOfModelInThisBundle)
        case .french:
            return try? NLEmbedding(contentsOf: IconModelFR.urlOfModelInThisBundle)
        case .spanish:
            return try? NLEmbedding(contentsOf: IconModelES.urlOfModelInThisBundle)
        case .italian:
            return try? NLEmbedding(contentsOf: IconModelIT.urlOfModelInThisBundle)
        case .portuguese:
            return try? NLEmbedding(contentsOf: IconModelPT.urlOfModelInThisBundle)
        default:
            return nil
        }
    }

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
        if let vector = sentenceEmbedding.vector(for: title),
           let modelEmbedding = modelEmbeddings(for: language) {
            results += modelEmbedding.neighbors(for: vector, maximumCount: maxResults)
                .filter { $0.1 <= 1 }
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
