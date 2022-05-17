//
//  ContentView.swift
//  SmartSymbols
//
//  Created by Leonard Mehlig on 21.05.21.
//

import SwiftUI

extension SmartSymbolRecommender {
    func result(for title: String) -> String {
        let symbols = self.symbols(for: title, maxResults: 10)
        return symbols.map {
            String(format: "%.5f\t%@", $0, $1)
        }.joined(separator: "\n")
    }
}

struct ContentView: View {

    @State var embedding: SmartSymbolRecommender = EmbeddingRecommender()
    @State var createML: SmartSymbolRecommender = CreateMLRecommender()

    @State var knn: SmartSymbolRecommender = KNNRecommender()
    @State var combiend: SmartSymbolRecommender = CombinedRecommender()

    @State var title: String = ""

    @State var results: [String] = []

    var body: some View {
        VStack {
            HStack {
                TextField("Task Title", text: $title)

                Button("Search Symbol") {
                    results = [
                        "Embedding\n" + embedding.result(for: self.title),
                        "CreateML\n" + createML.result(for: self.title),
                        "KNN\n" + knn.result(for: self.title),
                        "Combined\n" + combiend.result(for: self.title),
                    ]
                }
            }

            HStack(spacing: 30) {
                ForEach(self.results, id: \.self) { result in
                    VStack {
                        Text(result)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
