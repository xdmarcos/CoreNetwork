//
//  GeolocationModel.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 03/01/2024.
//

import Foundation

import Foundation

struct GeolocationModel: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let latitude, longitude: Double
    let type, name: String
    let number, postalCode, street: String?
    let confidence: Double
    let region, regionCode: String
    let county, locality: String?
    let administrativeArea: String
    let neighbourhood: String?
    let country, countryCode, continent, label: String
    let countryModule: CountryModule

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, type, name, number
        case postalCode = "postal_code"
        case street, confidence, region
        case regionCode = "region_code"
        case county, locality
        case administrativeArea = "administrative_area"
        case neighbourhood, country
        case countryCode = "country_code"
        case continent, label
        case countryModule = "country_module"
    }
}

// MARK: - CountryModule
struct CountryModule: Codable {
    let latitude, longitude: Double
    let commonName, officialName, capital, flag: String
    let area: Int
    let landlocked, independent: Bool
    let global: Global
    let dial: Dial
    let currencies: [Currency]
    let languages: Languages

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case commonName = "common_name"
        case officialName = "official_name"
        case capital, flag, area, landlocked, independent, global, dial, currencies, languages
    }
}

// MARK: - Currency
struct Currency: Codable {
    let symbol, code, name: String
    let numeric, minorUnit: Int

    enum CodingKeys: String, CodingKey {
        case symbol, code, name, numeric
        case minorUnit = "minor_unit"
    }
}

// MARK: - Dial
struct Dial: Codable {
    let callingCode: String
    let nationalPrefix: String?
    let internationalPrefix: String

    enum CodingKeys: String, CodingKey {
        case callingCode = "calling_code"
        case nationalPrefix = "national_prefix"
        case internationalPrefix = "international_prefix"
    }
}

// MARK: - Global
struct Global: Codable {
    let alpha2, alpha3, numericCode, region: String
    let subregion, regionCode, subregionCode, worldRegion: String
    let continentName, continentCode: String

    enum CodingKeys: String, CodingKey {
        case alpha2, alpha3
        case numericCode = "numeric_code"
        case region, subregion
        case regionCode = "region_code"
        case subregionCode = "subregion_code"
        case worldRegion = "world_region"
        case continentName = "continent_name"
        case continentCode = "continent_code"
    }
}

// MARK: - Languages
struct Languages: Codable {
    let spa, ita, por: String?
}
