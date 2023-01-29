//
//  SearchBar.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isFocused = true
    var search: () -> () = {}

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var placeholder: String
        var search: () -> () = {}

        init(text: Binding<String>, placeholder: String, search: @escaping () -> ()) {
            _text = text
            self.placeholder = placeholder
            self.search = search
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            search()
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, placeholder: placeholder, search: search)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        if isFocused {
            searchBar.becomeFirstResponder()
        }
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
    }
}
