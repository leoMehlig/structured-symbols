import Combine
import CoreData
import CoreML
import NaturalLanguage

class CreateMLRecommender: SmartSymbolRecommender {

    let model = try! IconClassifer(contentsOf: IconClassifer.urlOfModelInThisBundle)


    init() {

    }



    func symbols(for title: String, maxResults: Int) -> [(Double, String)] {

        let results = try! model.prediction(input: .init(text: title))

        return [(1, results.label)]

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
