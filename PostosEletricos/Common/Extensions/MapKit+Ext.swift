//
//  MapKit+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 05/05/24.
//

import MapKit

// MARK: MKCoordinateRegion

extension MKCoordinateRegion {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let latitudeDelta = span.latitudeDelta / 2.0
        let longitudeDelta = span.longitudeDelta / 2.0

        let latitudeRange = (center.latitude - latitudeDelta)...(center.latitude + latitudeDelta)
        let longitudeRange = (center.longitude - longitudeDelta)...(center.longitude + longitudeDelta)

        return latitudeRange.contains(coordinate.latitude) && longitudeRange.contains(coordinate.longitude)
    }
}

extension MKCoordinateRegion: Equatable {
    public static func ==(lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center && lhs.span == rhs.span
    }
}


// MARK: MKCoordinateSpan

extension MKCoordinateSpan: Equatable {
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}


// MARK: CLLocationCoordinate2D

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


// MARK: levenshteinDistance

func levenshteinDistance(from s: String, to t: String) -> Int {
    let sCount = s.count
    let tCount = t.count
    var matrix = [[Int]](repeating: [Int](repeating: 0, count: tCount + 1), count: sCount + 1)

    for i in 0...sCount {
        matrix[i][0] = i
    }
    for j in 0...tCount {
        matrix[0][j] = j
    }

    for i in 1...sCount {
        for j in 1...tCount {
            let cost = (s[s.index(s.startIndex, offsetBy: i - 1)] == t[t.index(t.startIndex, offsetBy: j - 1)]) ? 0 : 1
            matrix[i][j] = min(min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1), matrix[i - 1][j - 1] + cost)
        }
    }

    return matrix[sCount][tCount]
}
