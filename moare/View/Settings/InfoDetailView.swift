//
//  InfoDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct InfoDetailView: View {
    var url: String
    var title: String
    
    var body: some View {
        WebView(url: URL(string: url)!)
            .navigationTitle(title)
    }
}
