//
//  Concerts.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 22.01.2024.
//

//
//  WorldChartsView.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 27.12.2023.
//

import SwiftUI

struct Event: Decodable {
    let date: String
    let name: String
    let url: String
    let venue: String

    enum CodingKeys: String, CodingKey {
        case date
        case name
        case url
        case venue
    }
}

typealias Events = [Event]


struct ConcertsListView: View {
    @Binding var country: String // Change to Binding
    @State private var concerts = [Event]()// Initialize as an empty array

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Set the entire background to black
            List(concerts, id: \.url) { concert in
                VStack(alignment: .leading, spacing: 5) {
                    Text(concert.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(concert.venue)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(concert.date)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Link("Get Tickets", destination: URL(string: concert.url)!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading) // Stretch to fill width
                .background(Color.black) // Set the background color of the VStack to black
                .listRowInsets(EdgeInsets()) // Remove the default list row insets
            }
            .listStyle(PlainListStyle()) // Use a plain list style
            .background(Color.black) // Set the List's background to black

        }
        .onAppear {
            let urlString = "http://127.0.0.1:8008/concerts/\(country)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data returned from the request")
                    return
                }

                // Print the raw data as a String for debugging
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }

                do {
                    let concerts = try JSONDecoder().decode([Event].self, from: data)
                    DispatchQueue.main.async {
                        self.concerts = concerts
                        print("Decoded \(concerts.count) songs successfully")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        }
        .onChange(of: country) { _ in
            let urlString = "http://127.0.0.1:8008/concerts/\(country)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data returned from the request")
                    return
                }

                // Print the raw data as a String for debugging
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }

                do {
                    let concerts = try JSONDecoder().decode([Event].self, from: data)
                    DispatchQueue.main.async {
                        self.concerts = concerts
                        print("Decoded \(concerts.count) concerts successfully")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()        }
    }
}

struct ConcertView: View {
    let countries = ["Istanbul", "Ankara", "London", "Chicago", "Houston", "Atlanta", "Dublin", "Edinburgh"]

    @State private var selectedCountry = "Istanbul"

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Picker("Select a City", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                                .foregroundColor(.white) // Set the text color to white
                                .tag(country)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .background(Color.black)
                    .compositingGroup() // This can help with rendering the background properly
                    .padding()


                    Text("Selected City: \(selectedCountry)")
                        .foregroundColor(.white)
                        .padding()
                    Spacer() // This will push the WorldChartsView to the left
                    ZStack{
                        Color.black.edgesIgnoringSafeArea(.all) // Set the entire background to black
                        ConcertsListView(country: $selectedCountry)
                    }
                    .background(Color.black)

                }
                .background(Color.black)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Set frame to maximum
        .background(Color.black) // Apply the background color
        .edgesIgnoringSafeArea(.all)
    }
}


struct ConcertView_Previews: PreviewProvider {
    static var previews: some View {
        ConcertView()
    }
}
