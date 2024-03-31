//
//  ImportFromDatabase.swift
//  supotify55
//
//  Created by Furkan Emre Güler on 8.12.2023.
//

import SwiftUI
import SwiftUICharts

class ArtistFetcher: ObservableObject {
    @Published var artists = [Artist]()
    
    func fetchArtists(for userID: String) {
        guard let url = URL(string: "http://127.0.0.1:8008/\(userID)/artist_song_count") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Artist].self, from: data) {
                    DispatchQueue.main.async {
                        self.artists = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

// Model to represent the average rating
struct MonthlyAverageRating: Codable, Identifiable {
    var id: String { "\(year)-\(month)" }
    var year: Int
    var month: Int
    var average_rating: Double
}

// Model to represent the entire response
struct UserRatings: Codable {
    var user_id: String
    var monthly_average_ratings: [MonthlyAverageRating]
}



struct LineGraph: View {
    var dataPoints: [MonthlyAverageRating]
    private var maxRating: Double {
        guard let max = dataPoints.max(by: { $0.average_rating < $1.average_rating })?.average_rating else { return 1 }
        return max != 0 ? max : 1
    }
    private var minRating: Double {
        guard let min = dataPoints.min(by: { $0.average_rating < $1.average_rating })?.average_rating else { return 0 }
        return min
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // Eksenleri çizmek için Path kullanıyoruz
                Path { path in
                    // X ekseni (Aylar)
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))

                    // Y ekseni (Ortalama Derecelendirme)
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))

                // Grafiği çizmek için önceki kodu kullanıyoruz
                Path { path in
                    for index in dataPoints.indices {
                        let xPosition = geometry.size.width * CGFloat(index) / CGFloat(dataPoints.count - 1)
                        let yPosition = (1 - CGFloat((dataPoints[index].average_rating - minRating) / (maxRating - minRating))) * geometry.size.height

                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 2)
            }
        }
    }
}

struct GraphView: View {
    var data: [MonthlyAverageRating]
    var body: some View {
        VStack {
            GeometryReader { geometry in
                LineGraph(dataPoints: data)
                    .background(Color.black)
                    .padding()
            }
        }
    }
}

class RatingsViewModel: ObservableObject {
    @Published var userRatings: UserRatings?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchMonthlyAverageRatings(forUser userID: String) {
        guard let url = URL(string: "http://127.0.0.1:8008/\(myUser.username)/monthly_average_rating") else {
            self.errorMessage = "Invalid URL"
            return

        }

        self.isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(UserRatings.self, from: data)
                    self.userRatings = decodedData
                } catch {
                    self.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct StatisticalDataView: View {
    @ObservedObject var fetcher = ArtistFetcher()
    @ObservedObject var viewModel = RatingsViewModel()


    var body: some View {
        ScrollView {
            
            // Rated Artist Counts
            VStack(alignment: .leading) {
                Text("Rated Artist Count")
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Text("Artist Name")
                        .foregroundColor(.white)
                        .frame(width: 100, alignment: .leading)

                    Spacer()
                }
                .padding(.horizontal, 10)

                ForEach(fetcher.artists) { artist in
                    HStack {
                        Text(artist.artist_name)
                            .foregroundColor(.white)
                            .frame(width: 100, alignment: .leading)

                        Rectangle()
                            .fill(Color.green)
                            .frame(width: CGFloat(artist.song_count) * 20, height: 20)

                        Spacer()

                        Text("\(artist.song_count)")
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .background(Color.black)
            .padding(.horizontal)
            .onAppear {
                fetcher.fetchArtists(for: myUser.username)
            }
      
            VStack {
                Text("Monthly Average Rating")
                    .font(.headline)
                    .foregroundColor(.white)
                if viewModel.isLoading {
                    Text("Yükleniyor...")
                        .foregroundColor(.white)
                } else if let userRatings = viewModel.userRatings, !userRatings.monthly_average_ratings.isEmpty {
                    // Grafik
                    LineView(data: userRatings.monthly_average_ratings.map { $0.average_rating },
                             title: "",
                             legend: "",
                             style: ChartStyle(backgroundColor: Color.black, accentColor: .green, secondGradientColor: .green, textColor: .white, legendTextColor: .white, dropShadowColor: .white),
                             valueSpecifier: "%.2f")
                        .padding()
                } else {
                    Text("Veri bulunamadı.")
                        .foregroundColor(.white)
                }
            }
            .padding([.bottom], 20)
            .background(Color.black)
            .onAppear {
                viewModel.fetchMonthlyAverageRatings(forUser: myUser.username)
            }
            Spacer()
        }.background(Color.black)
    }
}

struct StatisticalDataView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticalDataView()
    }
}
