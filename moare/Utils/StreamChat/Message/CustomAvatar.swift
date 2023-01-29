//
//  CustomAvatar.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct CustomAvatar: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(
            url: url,
            content: { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            },
            placeholder: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
        )
    }
}
