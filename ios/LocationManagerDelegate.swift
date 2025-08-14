import AMapLocationKit
import Foundation

class LocationManagerDelegate: NSObject, AMapLocationManagerDelegate {
    func amapLocationManager(
        _ manager: AMapLocationManager!,
        doRequireLocationAuth locationManager: CLLocationManager!
    ) {
        locationManager.requestAlwaysAuthorization()
    }
}
