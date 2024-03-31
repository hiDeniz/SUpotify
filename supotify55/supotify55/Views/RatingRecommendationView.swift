import SwiftUI

// Represents each song recommendation
struct SongRecommendation: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let artists: [String]
    let coverImageURL: String
    let durationMS: Int
    let trackId: String

    private enum CodingKeys: String, CodingKey {
        case title = "song_name"
        case artists = "artist_name"
        case coverImageURL = "picture"
        case durationMS = "songLength"
        case trackId = "song_id"
    }
}

// The view for displaying the list of newly rated song recommendations
struct RecommendationListView: View {
    @State private var recommendationList: [SongRecommendation] = []
    let userId: String

    var body: some View {
        NavigationView {
            VStack {
                Text("Newly Rated Recommendations")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                List(recommendationList, id: \.id) { recommendation in
                    RatingRecommendationRow(recommendation: recommendation)
                        .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.black)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .statusBar(hidden: true)
        .onAppear {
            fetchRecommendations()
        }
    }

    func fetchRecommendations() {
        let endpoint = "http://127.0.0.1:8008/yeren/newly_rating_recomendations"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let recommendationList = try JSONDecoder().decode([SongRecommendation].self, from: data)
                    DispatchQueue.main.async {
                        self.recommendationList = recommendationList
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Network request error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// The view for displaying a single recommendation row
struct RatingRecommendationRow: View {
    var recommendation: SongRecommendation

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recommendation.coverImageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .padding(.trailing, 8)

            VStack(alignment: .leading) {
                Text("Title:")
                    .bold()
                    .foregroundColor(.white)
                Text(recommendation.title)
                    .foregroundColor(.white)

                Text("Artists:")
                    .bold()
                    .foregroundColor(.white)
                Text(recommendation.artists.joined(separator: ", "))
                    .foregroundColor(.white)
                    .font(.subheadline)

                Text("Duration:")
                    .bold()
                    .foregroundColor(.white)
                Text("\(recommendation.durationMS) ms")
                    .foregroundColor(.white)
            }
        }
    }
}

// Preview Providers
struct RecommendationListView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationListView(userId: "hi")
    }
}
