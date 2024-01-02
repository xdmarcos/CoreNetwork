//
//  ContentView.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 20/12/2023.
//

import SwiftUI

struct ContentView: View {
    @Binding private var inputText: String
    private let placeholder: String

    init(
        inputText: Binding<String>,
        placeholder: String = ""
    ) {
        self._inputText = inputText
        self.placeholder = placeholder
    }

    var body: some View {
        VStack(spacing: 64) {
            VStack(alignment: .leading) {
                Text("Forward geolocation")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontDesign(.rounded)
                    .bold()
                    .padding(.bottom, 32)

                Text("Enter location name:")
                HStack(spacing: 16) {
                    TextField(text: $inputText) {
                        Text(placeholder)
                    }


                }
                .padding(.top)

                Divider()

                Button("Send") {
                    // do nothing
                }
                .padding(.top)
            }

            VStack(alignment: .leading) {
                Text("Reverse geolocation")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontDesign(.rounded)
                    .bold()
                    .padding(.bottom, 32)

                Text("Coordinates:")
                HStack(spacing: 16) {
                    TextField(text: $inputText) {
                        Text("42.16156,-8.6198")
                    }

                    Button("", systemImage: "arrow.clockwise.circle") {
                        // Do nothing
                    }
                }
                .padding(.top)

                Divider()

                Button("Send") {
                    // do nothing
                }
                .padding(.top)
            }

            VStack {
                Text("Result")
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView(
        inputText: .constant(""),
        placeholder: "1600 Pennsylvania Ave NW, Washington DC"
    )
}
