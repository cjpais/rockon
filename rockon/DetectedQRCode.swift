//
//  DetectedQRCodes.swift
//  rockon
//
//  Created by CJ Pais on 12/1/20.
//

import Foundation
import UIKit

class DetectedQRCode {
    var url: URL
    var route: GymRoute
    var point: CGPoint

    init(url: URL, route: GymRoute, point: CGPoint) {
        self.url = url
        self.route = route
        self.point = point
    }
}
