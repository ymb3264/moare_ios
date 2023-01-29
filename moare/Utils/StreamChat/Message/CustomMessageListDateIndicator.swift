//
//  CustomMessageListDateIndicator.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct CustomMessageListDateIndicator: View {
    
    var date: String
    
    var body: some View {
        Text(date)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}
