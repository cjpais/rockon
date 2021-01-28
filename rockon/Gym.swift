//
//  Gym.swift
//  rockaholic
//
//  Created by CJ Pais on 11/2/20.
//

import Foundation

struct Gym: Identifiable, Hashable, Decodable {
    static func == (lhs: Gym, rhs: Gym) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int
    var name: String
    var ownerID: Int
    var location: String
    var address: String
    var email: String
    var phone: String
    var webURL: String
    var reservationLink: String
    //var owner: GymOwner?
    var walls: [GymWall]?
    var ropes: [GymRope]?
    var routes: [GymRoute]?
    
}
