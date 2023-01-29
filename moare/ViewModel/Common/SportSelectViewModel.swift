//
//  SportSelectViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

class SportSelectViewModel: ObservableObject {
    private let api = JoinAPI()
    
    @Published var sportList = [String: Bool]()
    @Published var newSportList = [String: Bool]()
    
    @Published var query = ""
    
    @Published var networkError = false
    
    @Published var selectedSport = [String]()
    var userHashtag = [String]()
    
    @Published var loading = false
    
    @MainActor init() {
        getSportList()
    }
    
    @MainActor func getSportList(sportHashtag: [String] = []) {
        loading = true
        Task {
            do {
                let response = try await api.getSportList().sportList
                
                loading = false
                response.forEach { sport in
                    sportList[sport] = false
                }
                if !sportHashtag.isEmpty {
                    sportHashtag.forEach { sport in
                        selectSport(key: sport)
                    }
                }
            } catch {
                loading = false
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.networkError = true
                    case .serverError:
                        self.networkError = true
                    default:
                        self.networkError = true
                    }
                } else {
                    self.networkError =  true
                    print("\(error)")
                }
            }
        }
    }
    
    func selectSport(key: String) {
        sportList[key]?.toggle()
        
        if sportList[key] == true {
            selectedSport.append(key)
        } else {
            if selectedSport.contains(key) {
                selectedSport.remove(at: selectedSport.firstIndex(of: key)!)
            }
        }
    }
    
    func newSelectSport(key: String) {
        newSportList[key]?.toggle()
        sportList[key]?.toggle()
        
        if sportList[key] == true {
            selectedSport.append(key)
        }  else {
            if selectedSport.contains(key) {
                selectedSport.remove(at: selectedSport.firstIndex(of: key)!)
            }
        }
    }
    
    func searchSport(query: String) {
        newSportList = sportList.filter { sport in
            sport.key.contains(query)
        }
    }
    
    func deleteSelectedSport(index: Int) {
        if userHashtag.contains(selectedSport[index]) {
            if let i = userHashtag.firstIndex(of: selectedSport[index]) {
                userHashtag.remove(at: i)
            }
        }
        sportList[selectedSport[index]]?.toggle()
        selectedSport.remove(at: index)
    }
}
