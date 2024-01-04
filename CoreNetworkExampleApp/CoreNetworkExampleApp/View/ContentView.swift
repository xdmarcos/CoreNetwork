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
        VStack {
            VStack(alignment: .leading) {
                VStack {
                    if let country = viewModel.result.first {
                        let result = "Welcome to \(country.countryName) \(country.countryFlag)"
                        Text(result)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    } else {
                        Text("Retrieving info...")
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                }
                .padding(.top)

                VStack(alignment: .leading) {
                    Text("Coordinates (lat, lon):")
                    HStack(spacing: 16) {
                        TextField(text: $inputText) {
                            if let result = viewModel.result.first {
                                let value = "\(result.latitude), \(result.longitude)"
                                Text(value)
                            }
                        }
                        .disabled(true)

                        Button("", systemImage: "location.fill.viewfinder") {
                            Task {
                                try await viewModel.startLocationUpdates()
                            }
                        }
                        .frame(width: 24, height: 24)
                        .disabled(viewModel.liveUpdatesDidStart)
                    }

                    Divider()
                }
                .padding(.top)

                VStack(alignment: .leading) {
                    Text("Altitude (m):")

                    TextField(text: $inputText) {
                        if let result = viewModel.result.first {
                            let value = "\(result.altitude)"
                            Text(value)
                        }
                    }

                    Divider()
                }
                .padding(.top)

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
                .padding(.top)

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
                        .padding(.top, 8)
                    }
                    Spacer()
                }
                .padding(.top, 44)
            }
            .padding(.top)

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
