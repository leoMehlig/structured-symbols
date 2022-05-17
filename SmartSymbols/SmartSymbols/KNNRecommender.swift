import Combine
import CoreData
import CoreML
import NaturalLanguage

extension Collection {
    func size(to length: Int, fill: Element) -> [Element] {
        if self.count >= length {
            return Array(self.prefix(length))
        } else {
            return Array(self) + Array(repeating: fill, count: length - self.count)
        }
    }
}

class KNNRecommender: SmartSymbolRecommender {

    let model = try! UpdatableKNN(contentsOf: UpdatableKNN.urlOfModelInThisBundle)


    init() {

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

    private let recognizer: NLLanguageRecognizer = .init()


    func symbols(for title: String, maxResults: Int) -> [(Double, String)] {

        defer { recognizer.reset() }

        self.recognizer.processString(title)
        guard let language = recognizer.dominantLanguage,
              let sentenceEmbedding = sentenceEmbedding(for: language),
              let vetor = sentenceEmbedding.vector(for: title) else {
            return []
        }

        let array = try! MLMultiArray(vetor.size(to: 640, fill: 0))

        let results = try! model.prediction(input: .init(features: array))


        return results.labelProbs.sorted(by: { $0.value > $1.value }).map { ($1, $0)}.filter({ $0.0 > 0})

//        defer { recognizer.reset() }
//
//        self.recognizer.processString(title)
//        guard let language = recognizer.dominantLanguage,
//              let sentenceEmbedding = sentenceEmbedding(for: language) else {
//            return []
//        }
//
//        var results: [(String, NLDistance)] = []
//        if let vector = sentenceEmbedding.vector(for: title),
//           let modelEmbedding = modelEmbeddings(for: language) {
//            results += modelEmbedding.neighbors(for: vector, maximumCount: maxResults)
//                .filter { $0.1 <= 1 }
//        }
//
//        var icons: [String: Double] = [:]
//        for (result, distance) in results {
//            if let name = result.split(separator: "_").first,
//               icons[String(name)] == nil {
//                icons[String(name)] = distance
//            }
//        }
//
//        return icons.sorted(by: { $0.value < $1.value }).map { ($1, $0) }
    }
}
