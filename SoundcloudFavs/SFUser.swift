import Foundation

class SFUser: ObservableObject {
    static let shared = SFUser()

    @Published var favTitles: [String] = []
    @Published var favWavformURLs: [String] = []
    @Published var wavformImages: [UIImage] = []
    @Published var favTrackIDs: [String] = []
    @Published var favTrackURIs: [String] = []
    @Published var userName: String?

    private init() {}

    func purgeUserData() {
        favTitles = []
        favWavformURLs = []
        wavformImages = []
        favTrackIDs = []
        favTrackURIs = []
        userName = nil
    }
}
