//
//  GymWall.swift
//  rockaholic
//
//  Created by CJ Pais on 11/2/20.
//

import Foundation

struct GymWall: Identifiable, Hashable, Decodable {
    
    var id: Int?
    var gymId: Int?
    var name: String
    var wall_type: String = "Sport"
    var ropes: [GymRope]?
    
    init() {
        self.name = ""
        self.ropes = []
    }

}
