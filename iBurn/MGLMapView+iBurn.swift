//
//  MGLMapView+iBurn.swift
//  iBurn
//
//  Created by Chris Ballinger on 6/14/17.
//  Copyright © 2017 Burning Man Earth. All rights reserved.
//

import Foundation
import Mapbox

public extension MGLMapView {
    /// Sets default iBurn behavior for mapView
    @objc public func brc_setDefaults() {
        styleURL = URL(string: kBRCMapBoxStyleURL)
        showsUserLocation = true
        minimumZoomLevel = 12
        backgroundColor = UIColor.brc_mapBackground
        translatesAutoresizingMaskIntoConstraints = false
        brc_moveToBlackRockCityCenter(animated: false)
    }
}
