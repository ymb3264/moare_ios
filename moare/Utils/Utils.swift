//
//  Utils.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import Foundation

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

extension View {
    func innerShadow<S: Shape>(_ shape: S, radius: CGFloat = 10, opacity: Double = 0.4, offset: CGSize, width: CGFloat) -> some View {
        self
            .blendMode(.multiply)
            .background {
                ZStack {
                    shape.fill(Color(white: 1 - opacity)).frame(width: width)
                    shape.fill(Color.white).blur(radius: radius).offset(offset)
                }
            }
            .mask(self.overlay(shape))
    }
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        return window
    }
}

struct ShareHelper {
    static func sharActionSheet(url: String) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

enum TabIdentifier: Hashable {
    case post
    case profile
}

extension URL {
    var tabIdentifier: TabIdentifier? {
        switch path {
        case "/post/one":
            return .post
        default: return nil
        }
    }
    
    var yearAndMonth: String? {
        if tabIdentifier != nil {
            guard let query = query else { return  nil }
            
            let queryArr = query.split(separator: "&")
            
            return String(queryArr[0].split(separator: "=")[1])
        } else {
            return nil
        }
    }
    
    var postCreatedAt: String? {
        if tabIdentifier != nil {
            guard let query = query else { return  nil }
            
            let queryArr = query.split(separator: "&")
            
            return String(queryArr[1].split(separator: "=")[1])
        } else {
            return nil
        }
    }
}

struct DateHelper {
    static func getDays(createdAt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let objDate = dateFormatter.date(from: String(createdAt.split(separator: "T").first!)) ?? Date()
        let nowDate = dateFormatter.date(from: dateFormatter.string(from: Date())) ?? Date()
        
        let days = Calendar.current.dateComponents([.day], from: objDate, to: nowDate).day
        
        if let days = days {
            if days == 0 {
                return "오늘"
            } else if days < 4 {
                return "\(days)일전"
            } else {
                dateFormatter.dateFormat = "M월d일"
                let currentDate = dateFormatter.date(from: createdAt) ?? Date()
                return "\(dateFormatter.string(from: currentDate))"
            }
        } else {
            return ""
        }
    }
}

struct APIUtil {
    static let scheme = "https"
    static let host = "www.moare.kr"
    
    static func getResponse(request: URLRequest) async throws -> Data {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let (data, urlResponse) = try await session.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 400..<500:
            let response = try JSONDecoder().decode(MessageResponse.self, from: data)
            throw APIError.requestError(response: response)
        default:
            throw APIError.unknown
        }
    }
}

struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 30) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

//extension UINavigationController: UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        navigationBar.isHidden = true
//        interactivePopGestureRecognizer?.delegate = self
//    }
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        // locate far out of screen
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        UIApplication.shared.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
                 layer.render(in: rendererContext.cgContext)
        }
    }
}
