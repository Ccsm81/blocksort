import Cocoa
import WebKit

// Minimal macOS app: a window with a WKWebView loading Block Sort (web/index.html from the bundle).
final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let rect = NSRect(x: 0, y: 0, width: 480, height: 860)   // portrait puzzle
        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Block Sort"
        window.minSize = NSSize(width: 360, height: 560)
        window.center()
        window.backgroundColor = NSColor(red: 0.725, green: 0.541, blue: 0.627, alpha: 1)

        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: rect, configuration: config)
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
        window.contentView = webView

        if let res = Bundle.main.resourceURL {
            let index = res.appendingPathComponent("web/index.html")
            webView.loadFileURL(index, allowingReadAccessTo: res.appendingPathComponent("web"))
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "http" || url.scheme == "https",
           navigationAction.navigationType == .linkActivated {
            NSWorkspace.shared.open(url); decisionHandler(.cancel); return
        }
        decisionHandler(.allow)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
let mainMenu = NSMenu()
let appItem = NSMenuItem(); mainMenu.addItem(appItem)
let appMenu = NSMenu()
appMenu.addItem(withTitle: "Quit Block Sort", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
appItem.submenu = appMenu
app.mainMenu = mainMenu
app.run()
