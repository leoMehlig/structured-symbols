import NaturalLanguage
import CreateML
import CoreML

struct Entry: Codable {
    let label: String
    let text: String
//    let languages: [String]?
}

let url = URL(fileURLWithPath: "/Users/leo/Developer/Today/structured-symbols/Prepare/predefined_icons_learn.json")

let data = try! Data(contentsOf: url)



let url2 = URL(fileURLWithPath: "/Users/leo/Developer/Today/structured-symbols/Prepare/user_icons_learn.json")

let data2 = try! Data(contentsOf: url2)

let entries = try! JSONDecoder().decode([Entry].self, from: data) + JSONDecoder().decode([Entry].self, from: data2)

print("Entries loaded", entries.count)

var trainingData: [NLLanguage: [String: Set<String>]] = [:]

let queue = DispatchQueue(label: "test")

var processed: Int = 0
// for index in entries.indices {
DispatchQueue.concurrentPerform(iterations: entries.count) { index in
    let recognizer = NLLanguageRecognizer()
    let entry = entries[index]

//    let hints: [(NLLanguage, Double)] = entry.languages?.enumerated()
//        .map {
//            (NLLanguage(rawValue: String($0.element.split(separator: "-")[0])), 1 / Double($0.offset + 2))
//        } ?? []
//
//    recognizer.languageHints = Dictionary(hints, uniquingKeysWith: { $1 })

    recognizer.processString(entry.text)


    guard let language = recognizer.dominantLanguage else {
        return
    }

   queue.sync {
        trainingData[language, default: [:]][entry.label, default: []].insert(entry.text)
        processed += 1
        if processed % 100 == 0 {
            print("\(processed)/\(entries.count)")
        }
    }
}

print("Finished colleting vectors")


for (language, data) in trainingData {
    print("\(data.count) icons for \(language.rawValue)")
    var icons: [String: [Double]] = [:]
    guard let embedding = NLEmbedding.sentenceEmbedding(for: language) else {
        continue
    }

    for (icon, titles) in data {
        for (idx, title) in titles.enumerated() {
            guard let vector = embedding.vector(for: title) else {
                continue
            }
            icons["\(icon)_\(idx)"] = vector
        }
    }

    print("\(icons.count) data points for \(language.rawValue)")


    let url =  URL(fileURLWithPath: "/Users/leo/Developer/Today/structured-symbols/IconModel\(language.rawValue.uppercased()).mlmodel")

    let model = try! MLWordEmbedding(dictionary: icons)
    try! model.write(to: url)
}

