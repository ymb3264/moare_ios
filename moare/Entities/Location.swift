//
//  Location.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation

struct Coordinate: Codable {
    var x: String
    var y: String
}

struct CoordinateResponse: Codable {
    var documents: [CoordinateAddress]
}

struct CoordinateAddress: Codable {
    var generalAddress: CoordinateGeneralAddress?
    
    enum CodingKeys: String, CodingKey {
        case generalAddress = "address"
    }
}

struct CoordinateGeneralAddress: Codable {
    var address1: String
    var address2: String
    var address3: String
    
    enum CodingKeys: String, CodingKey {
        case address1 = "region_1depth_name"
        case address2 = "region_2depth_name"
        case address3 = "region_3depth_name"
    }
}

struct AddressResponse: Codable {
    let documents: [Address]
}

struct Address: Codable {
    var fullAddress: String
    var generalAddress: GeneralAddress?
    var x: String
    var y: String
    
    enum CodingKeys: String, CodingKey {
        case x, y
        case fullAddress = "address_name"
        case generalAddress = "address"
    }
}

struct GeneralAddress: Codable {
    var address1: String
    var address2: String
    var address3: String
    var address3_h: String
    
    enum CodingKeys: String, CodingKey {
        case address1 = "region_1depth_name"
        case address2 = "region_2depth_name"
        case address3 = "region_3depth_name"
        case address3_h = "region_3depth_h_name"
    }
}

struct AddressItem: Identifiable {
    var id = UUID()
    var address: String
    var x: String
    var y: String
}

struct UserDefaultLocation: Codable {
    var address: String
    var x: String
    var y: String
    
    func encoded() -> String {
        let data = try! JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)!
    }
    
    static func decode(responseString: String) -> UserDefaultLocation {
        let data = responseString.data(using: .utf8)
        return try! JSONDecoder().decode(UserDefaultLocation.self, from: data!)
    }
}

class Storage: NSObject {
    static func archiveArray(arr: [String]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: arr, requiringSecureCoding: false)
            return data
        } catch {
            print("\(error)")
            return Data()
        }
    }
    
    static func unarchiveArray(data: Data) -> [String] {
        guard let arr = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self], from: data) as? [String] else {
            return []
        }
        return arr
    }
}
