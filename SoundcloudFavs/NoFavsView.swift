import SwiftUI

struct NoFavsView: View {
    var body: some View {
        VStack {
            Text("This is where your favorites would be, but currently you don't have any.")
                .font(.system(size: 36, weight: .regular, design: .default))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()

            HStack {
                Image("favs")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.white)

                Image("favs")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.white)

                Image("favs")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .background(Color.white)
            }
        }
        .background(Color(white: 1.0))
    }
}

struct NoFavsView_Previews: PreviewProvider {
    static var previews: some View {
        NoFavsView()
    }
}
