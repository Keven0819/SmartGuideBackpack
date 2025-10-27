//
//  LocationService.swift
//  SmartGuideBackpack
//

import CoreLocation
import Combine

public class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // MARK: -- 單例模式
    public static let shared = LocationService()
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder() // 單一實例
    private var lastGeocodeTime = Date.distantPast
    private var lastCoordinate: CLLocation?
    
    // MARK: -- Published 屬性
    @Published public var coordinate: CLLocationCoordinate2D?
    @Published public var heading: CLHeading?
    @Published public var address: String?  // 中文地址
    
    // MARK: -- 初始化
    private override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    // MARK: -- CLLocationManagerDelegate 方法
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        coordinate = coord
        reverseGeocodeIfNeeded(coord) { address in
            self.address = address
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        default:
            break
        }
    }
    
    // MARK: -- 反向地理編碼節流
    public func reverseGeocodeIfNeeded(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (String?) -> Void
    ) {
        let now = Date()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if now.timeIntervalSince(lastGeocodeTime) < 10 {
            completion(self.address)
            return
        }
        if let last = lastCoordinate, last.distance(from: location) < 50 {
            completion(self.address)
            return
        }
        lastGeocodeTime = now
        lastCoordinate = location

        if geocoder.isGeocoding { geocoder.cancelGeocode() }
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                let addr: String?
                if let placemark = placemarks?.first {
                    addr = [placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare, placemark.subThoroughfare]
                        .compactMap { $0 }.joined(separator: " ")
                } else {
                    addr = "無法取得地址"
                }
                self?.address = addr
                completion(addr)
            }
        }
    }
}
