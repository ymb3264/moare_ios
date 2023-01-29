//
//  ShareSheet.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import UIKit
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
