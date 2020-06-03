import SwiftUI

struct ContentView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading) {
        Text("Setup instructions")
        Text("Open System Preferences")
        Text("Go to the Extensions preference pange")
      }
      .frame(width: geometry.size.width,
             height: geometry.size.height)
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
