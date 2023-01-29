//
//  QuestionsView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/11.
//

import SwiftUI

struct ContactView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("문의사항은")
                    .font(.body)
                
                Text(verbatim: " ymb3264@naver.com으로")
                    .font(.body)
                    .underline()
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 2)
            
            HStack {
                Text("문의주시기 바랍니다.")
                    .font(.body)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(Text(StringResources.contactNavigationTitle))
        .padding(.horizontal)
    }
}


