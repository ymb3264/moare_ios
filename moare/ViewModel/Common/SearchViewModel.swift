//
//  SearchViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    private var searchApi = SearchAPI()
    private var joinApi = JoinAPI()
    
    @AppStorage("profile") var profile = ""
    
    var sportList = [String]()
    
    @Published var query = ""
    @Published var searchList = [String]()
    @Published var loading = false
    
    @MainActor init() {
        getSportList()
    }
    
    @MainActor func search() {
        Task {
            self.loading = true
            self.searchList.removeAll()
            if query.starts(with: "#") {
                self.loading = false
                self.searchList = sportList.filter { sport in
                    sport.contains(query)
                }
            } else if !query.isEmpty {
                do {
                    let respose = try await searchApi.searchUsername(query: query)
                    
                    var newList = respose
                    let decodedProfile = Profile.decode(profile)
                    if let blockedBy = decodedProfile.blockedBy {
                        for item in newList {
                            let blockedUser = item.userID + "+" + item.createdAt
                            if blockedBy.contains(blockedUser) {
                                newList.remove(at: newList.firstIndex(of: item)!)
                            }
                        }
                    }
                    
                    searchList = newList.map { obj in
                        obj.username
                    }
                    
                    self.loading = false
                } catch {
                    // nothing to do
                    self.loading = false
                    print("\(error)")
                }
            }
            self.loading = false
        }
    }
    
    @MainActor func getSportList() {
        Task {
            do {
                self.sportList = try await joinApi.getSportList().sportList
            } catch {
                print("\(error)")
            }
        }
    }
}
