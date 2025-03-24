import SwiftUI

struct SFAccountDetailsView: View {
    @State private var statusLabel: String = "You are logged out"
    @State private var loginButtonTitle: String = "Log in"

    var body: some View {
        VStack {
            Text(statusLabel)
                .padding()
            Button(action: logInOrOut) {
                Text(loginButtonTitle)
            }
            .padding()
        }
        .onAppear {
            updateStatus()
        }
    }

    private func logInOrOut() {
        if SCSoundCloud.account() == nil {
            // Log in
            SCSoundCloud.requestAccess { account, error in
                if let account = account {
                    SFUser.shared.userName = account.userName
                    updateStatus()
                } else {
                    // Handle error
                }
            }
        } else {
            // Log out
            SCSoundCloud.removeAccess()
            SFUser.shared.purgeUserData()
            updateStatus()
        }
    }

    private func updateStatus() {
        if let userName = SFUser.shared.userName {
            statusLabel = "Logged in: \(userName)"
            loginButtonTitle = "Log out"
        } else {
            statusLabel = "You are logged out"
            loginButtonTitle = "Log in"
        }
    }
}

struct SFAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SFAccountDetailsView()
    }
}
