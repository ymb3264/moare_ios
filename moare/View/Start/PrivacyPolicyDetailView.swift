//
//  PrivacyPolicyDetailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/11.
//

import SwiftUI

struct PrivacyPolicyDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: StringResources.privacyPolicyUrl)!)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(StringResources.privacyPolicy)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color("moare"))
                        }
                    }
                }
        }
    }
}
