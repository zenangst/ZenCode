import SwiftUI

struct ContentView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack {
        InstructionsView()
          .frame(maxWidth: geometry.size.width / 1.5)
      }
    }.frame(minWidth: 450, minHeight: 300)
  }
}

struct InstructionsView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: 16) {
        Text("Setup instructions")
          .font(.headline)
          .multilineTextAlignment(.center)
          .frame(width: geometry.size.width)
        Text("Open “Extensions” in System Preferences.")
        Button(action: {}, label: { Text("Open System preferences") })
          .frame(width: geometry.size.width)
        Text("Choose “Xcode Source Editor” in the left sidebar")
        Text("Enable ZenCode")
        Text("Now to go Xcode, there should be a menu item called “ZenCode” at the bottom of the “Editor” menu")
      }
      .lineLimit(nil)
      .padding(32)
      .frame(height: geometry.size.height, alignment: .top)
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
