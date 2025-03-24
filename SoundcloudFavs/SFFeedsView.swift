import SwiftUI

struct SFFeedsView: View {
    @State private var favTitles: [String] = []
    @State private var favWavformURLs: [String] = []
    @State private var wavformImages: [UIImage] = []
    @State private var favTrackIDs: [String] = []
    @State private var favTrackURIs: [String] = []
    @State private var highestRowLoaded: Int = 0
    @State private var hasLastRowBeenReached: Bool = false
    @State private var shouldShowLoginAlert: Bool = true

    var body: some View {
        NavigationView {
            List {
                ForEach(favTitles.indices, id: \.self) { index in
                    HStack {
                        Text(favTitles[index])
                        Spacer()
                        Image(uiImage: wavformImages[index])
                            .resizable()
                            .frame(width: 35, height: 35)
                            .background(Color.white)
                    }
                    .onTapGesture {
                        playTrack(at: index)
                    }
                }
            }
            .navigationBarTitle("Favorites")
            .onAppear {
                if SCSoundCloud.account() == nil && shouldShowLoginAlert {
                    showLoginAlert()
                } else {
                    fetchFavorites()
                }
            }
        }
    }

    private func showLoginAlert() {
        let alert = UIAlertController(title: nil, message: "Log in to see your favorites!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            login()
        })
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    private func login() {
        SCSoundCloud.requestAccess { account, error in
            if let account = account {
                fetchFavorites()
            } else {
                shouldShowLoginAlert = false
                let alert = UIAlertController(title: nil, message: "Oops... Couldn't log you in. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func fetchFavorites() {
        let urlStr = "https://api.soundcloud.com/me/favorites.json?"
        guard let account = SCSoundCloud.account() else { return }

        SCRequest.performMethod(.GET, onResource: URL(string: urlStr)!, usingParameters: nil, withAccount: account, sendingProgressHandler: nil) { response, data, error in
            if let error = error {
                let alert = UIAlertController(title: nil, message: "Oops... Something went wrong. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            } else if let data = data {
                if let responseArray = try? JSONDecoder().decode([Favorite].self, from: data) {
                    setupUserArrays(for: responseArray)
                }
            }
        }
    }

    private func setupUserArrays(for responseArray: [Favorite]) {
        favTitles = responseArray.map { $0.title }
        favWavformURLs = responseArray.map { $0.waveform_url }
        favTrackIDs = responseArray.map { $0.id }
        favTrackURIs = responseArray.map { $0.permalink_url }
        wavformImages = Array(repeating: UIImage(), count: favTitles.count)
    }

    private func playTrack(at index: Int) {
        let scURL = URL(string: "soundcloud:track:\(favTrackIDs[index])")!
        if UIApplication.shared.canOpenURL(scURL) {
            UIApplication.shared.open(scURL)
        } else if let onlineURL = URL(string: favTrackURIs[index]) {
            UIApplication.shared.open(onlineURL)
        } else {
            let alert = UIAlertController(title: nil, message: "Sorry, can't play that track", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

struct Favorite: Codable {
    let title: String
    let waveform_url: String
    let id: String
    let permalink_url: String
}

struct SFFeedsView_Previews: PreviewProvider {
    static var previews: some View {
        SFFeedsView()
    }
}
