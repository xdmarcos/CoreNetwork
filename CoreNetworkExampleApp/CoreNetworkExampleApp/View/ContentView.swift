//
//  ContentView.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 20/12/2023.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ContentView: View {
    @ObservedObject private var viewModel: GeolocationViewModel
    @Binding private var inputText: String
    @State private var showAlert: Bool = false
    private let placeholder: String

    init(
        viewModel: GeolocationViewModel,
        inputText: Binding<String> = .constant(""),
        placeholder: String = ""
    ) {
        self.viewModel = viewModel
        self._inputText = inputText
        self.placeholder = placeholder
    }

    var body: some View {
        VStack(spacing: 64) {
            VStack(alignment: .leading) {
                Text("Reverse geolocation")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                    .padding(.bottom, 32)

                VStack(alignment: .leading) {
                    Text("Coordinates:")
                    HStack(spacing: 16) {
                        TextField(text: $inputText) {
                            if let result = viewModel.result.first {
                                let value = "\(result.latitude), \(result.longitude)"
                                Text(value)
                            }
                        }
                        .disabled(true)

                        Button("", systemImage: "location.magnifyingglass") {
                            Task {
                                try await viewModel.startLocationUpdates()
                            }
                        }
                        .disabled(viewModel.liveUpdatesDidStart)
                    }
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Altitude:")

                    TextField(text: $inputText) {
                        if let result = viewModel.result.first {
                            let value = "\(result.altitude)m"
                            Text(value)
                        }
                    }
                }.padding(.top)

                HStack {
                    Spacer()
                    VStack {
                        if viewModel.liveUpdatesDidStart {
                            LoadingIndicator(
                                animation: .pulseOutlineRepeater,
                                color: .blue,
                                speed: .slow
                            )
                        }

                        Button("Stop location updates") {
                            viewModel.stopLocationUpdates()
                        }
                        .disabled(!viewModel.liveUpdatesDidStart)
                    }
                    Spacer()
                }
                .padding(.top, 24)
            }
            .padding(.top)

            VStack(alignment: .leading) {
                Text("Forward geolocation")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                    .padding(.bottom, 32)

                VStack(alignment: .leading) {
                    Text("Location address:")
                    HStack(spacing: 16) {
                        TextField(text: $inputText) {
                            if let result = viewModel.result.first {
                                Text(result.address)
                            }
                        }
                        .disabled(true)
                    }

                    Divider()
                }
            }

            HStack {
                Text("Welcome to")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()

                if let country = viewModel.result.first {
                    let result = "\(country.countryName) \(country.countryFlag) "
                    Text(result)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                } else {
                    Text("...")
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                }
            }

            Spacer()
        }
        .padding()
        .task {
            await viewModel.requestLocationAuthorization()
            showAlert = viewModel.showLocationAuthorizationPrompt
        }
        .alert(viewModel.locationAuthorizationPromptMessage, isPresented: $showAlert) {
            Button("Settings", role: .cancel) {
                viewModel.openLocationSettings()
            }
            Button("Cancel", role: .destructive) {
                showAlert = false
            }
        }
    }
}

#Preview {
    ContentView(
        viewModel: GeolocationViewModel(
            result: [
                LocationInfo(
                    countryName: "Spain",
                    countryFlag: "🇪🇸",
                    address: "Xogo da ola, 36400, Porriño (Galicia)",
                    latitude: "42.161434",
                    longitude: "-8.619662",
                    altitude: "200"
                )
            ]
        ),
        inputText: .constant(""),
        placeholder: "1600 Pennsylvania Ave NW, Washington DC"
    )
}
