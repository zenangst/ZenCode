import Cocoa

class SystemPreferenceController {
  func openSystemPreferences() {
    let url = NSURL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane", isDirectory: true)
    let dictionary = [
      "action": "revealExtensionPoint",
      "protocol": ""
    ]

  }
}
