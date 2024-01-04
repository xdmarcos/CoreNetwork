//
//  CoreNetworkExampleAppApp.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 20/12/2023.
//

import SwiftUI

@main
struct CoreNetworkExampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: GeolocationViewModel())
        }
    }
}
