//
//  ContentView.swift
//  StructuredSymbols
//
//  Created by Leo Mehlig on 11.03.22.
//

import SwiftUI

struct ContentView: View {
    
    var symbol: Image {
        Image("custom.twitter")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("Aa")
                    .frame(width: 30)
                symbol
                    .font(.body.weight(.ultraLight))
                    .frame(width: 30)
                symbol
                    .font(.body.weight(.regular))
                    .frame(width: 30)
                symbol
                    .font(.body.weight(.black))
                    .frame(width: 30)
            }
            .imageScale(.small)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Aa")
                    .frame(width: 30)

                symbol
                    .font(.body.weight(.ultraLight))
                    .frame(width: 30)

                symbol
                    .font(.body.weight(.regular))
                    .frame(width: 30)

                symbol
                    .font(.body.weight(.black))
                    .frame(width: 30)

            }
            .imageScale(.medium)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Aa")
                    .frame(width: 30)
                symbol
                    .font(.body.weight(.ultraLight))
                    .frame(width: 30)

                symbol
                    .font(.body.weight(.regular))
                    .frame(width: 30)

                symbol
                    .font(.body.weight(.black))
                    .frame(width: 30)

            }
            .imageScale(.large)
        }
        .font(.body)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
    }
}
