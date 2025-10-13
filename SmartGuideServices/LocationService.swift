//
//  LocationService.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import CoreLocation
import Combine

public class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    public static let shared = LocationService()
    private let manager = CLLocationManager()
    
    @Published public var coordinate: CLLocationCoordinate2D?
    @Published public var heading: CLHeading?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        case .denied, .restricted:
            coordinate = nil
            heading = nil
            print("定位權限被拒絕或限制")
        case .notDetermined:
            print("尚未決定定位權限")
        @unknown default:
            break
        }
    }
}
