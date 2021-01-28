//
//  LocationInfo.swift
//  rockon
//
//  Created by CJ Pais on 11/23/20.
//

import SwiftUI

struct LocationInfo: View {
    
    @ObservedObject var lm = LocationManager()
    
    var body: some View {
        
        VStack {
            Text("\(lm.location?.coordinate.latitude ?? 0)")
            Text("\(lm.location?.coordinate.longitude ?? 0)")
            Text("altitude \(lm.location?.altitude ?? 0)m")
            Text("accuracy \(lm.location?.horizontalAccuracy ?? 0)m")
        }
    }
}

struct LocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        LocationInfo()
    }
}
