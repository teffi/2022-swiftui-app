//
//  CountryCodeList.swift
//  Dash
//
//  Created by Steffi Tan on 3/22/22.
//

import SwiftUI

struct CountryCodeList: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var countries: [Country] = []
  @Binding var selectedCountry: Country
  @State private var searchText = ""
  var body: some View {
    List {
      Section(header: searchField) {
        ForEach(countries) { country in
          listRow(country)
        }
      }
      .listStyle(.plain)
    }
  }
  
  init(selectedCountry: Binding<Country>) {
    _countries = State(initialValue: CountryCodeList.loadCountries())
    _selectedCountry = selectedCountry
  }
  
  init(countries: [Country]) {
    _countries = State(initialValue: countries)
    _selectedCountry = Binding.constant(CountryCodeList.defaultCountry)
  }
}
//  MARK: - Views
extension CountryCodeList {
  private var searchField: some View {
    TextField("Country", text: $searchText)
      .fontRegular(size: 16)
      .textContentType(.countryName)
      .fgAssetColor(.black)
      .padding(10)
      .bgAssetColor(.white)
      .cornerRadius(8)
      .frame(maxWidth: .infinity)
      .overlay(alignment: .trailing) {
        clearSearchButton
      }
      .onChange(of: searchText) { newValue in
        guard !newValue.isEmpty else {
          countries = CountryCodeList.loadCountries()
          return
        }
        countries = countries.filter { $0.name.contains(newValue) }
      }
  }
  
  private var clearSearchButton: some View {
    Button(action: {
      searchText = ""
    }) {
      Image(systemName: "multiply.circle.fill")
        .foregroundColor(.gray)
        .padding(.trailing, 8)
    }
  }
  
  private func listRow(_ country: Country) -> some View {
    HStack {
      Text(country.name)
      Spacer()
      Text("\(country.flag) +\(country.phoneCode)")
    }
    .contentShape(Rectangle())
    .onTapGesture {
      selectedCountry = country
      presentationMode.wrappedValue.dismiss()
    }
  }
}

//  MARK: - Data
extension CountryCodeList {
  static var deviceLocale: Country {
    let code = Locale.current.regionCode
    return loadCountries().filter { $0.isoCode == code }.first ?? defaultCountry
  }
  
  static var defaultCountry: Country {
    return Country(isoCode: "PH", phoneCode: "63")
  }
  
  fileprivate static func loadCountries() -> [Country] {
    guard let countriesData = Resources.readJSONFile(with: "countries") else {
      return []
    }
    //   Load countries
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode([Country].self, from: countriesData)
    } catch {
      print(error)
    }
    return []
  }
  
  static func getCountry(isoCode: String) -> Country? {
    let countries = CountryCodeList.loadCountries()
    return countries.first { $0.isoCode == isoCode }
  }
}

//  MARK: - Country
struct Country: Decodable, Identifiable {
  let isoCode: String
  let phoneCode: String
  
  var name: String {
    let current = Locale(identifier: "en_US")
    return current.localizedString(forRegionCode: isoCode) ?? ""
  }
  
  var flag: String {
    return String(String.UnicodeScalarView(
      isoCode.unicodeScalars.compactMap(
        { UnicodeScalar(127397 + $0.value) })))
  }
  
  var phoneCodeWithSymbol: String {
    return "+" + phoneCode
  }
  
  ///  Returns isoCode
  ///  Conforms to identifiable
  var id: String {
    return isoCode
  }
}

//  MARK: - Preview
struct CountryCodeList_Previews: PreviewProvider {
  static var previews: some View {
    CountryCodeList(countries: CountryCodeList.loadCountries())
  }
}
