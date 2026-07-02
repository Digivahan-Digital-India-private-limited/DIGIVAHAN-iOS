//
//  LocationManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 17/06/26.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    var latitude: Double?
    var longitude: Double?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {

        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {

        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {

        locationManager.stopUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude

        print("Latitude: \(latitude ?? 0)")
        print("Longitude: \(longitude ?? 0)")
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        print("Location error:", error.localizedDescription)
    }
}
