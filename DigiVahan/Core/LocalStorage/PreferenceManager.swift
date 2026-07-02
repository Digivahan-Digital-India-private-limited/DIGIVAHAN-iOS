//
//  PreferenceManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 13/05/26.
//

import Foundation

class PreferenceManager {

    // MARK: - Singleton Instance
    
    static let shared = PreferenceManager()

    
    // MARK: - Keys
    
    struct Keys {

        static let userId = "user_id"
        static let authToken = "auth_token"
        static let isLoggedIn = "is_logged_in"
        static let firstLaunch = "is_first_launch"

        static let imagePath = "image_path"
        static let liveTracking = "live_tracking"

        static let appSharingMessage = "app_sharing_message"

        static let garageCache = "garage_cache"
        static let fuelCache = "fuel_cache"
        static let trendingCache = "trending_cache"

        static let notificationSound = "notification_sound"

        static let KEY_USER_DATA = "USER_DATA"
    }

    
    // MARK: - UserDefaults Instance
    
    private let defaults = UserDefaults.standard

    
    // MARK: - Save String
    
    func setString(value: String,
                   key: String) {

        defaults.set(value, forKey: key)
    }

    
    // MARK: - Get String
    
    func getString(key: String) -> String {

        return defaults.string(forKey: key) ?? ""
    }

    
    // MARK: - Save Bool
    
    func setBool(value: Bool,
                 key: String) {

        defaults.set(value, forKey: key)
    }

    
    // MARK: - Get Bool
    
    func getBool(key: String) -> Bool {

        return defaults.bool(forKey: key)
    }

    
    // MARK: - Save Int
    
    func setInt(value: Int,
                key: String) {

        defaults.set(value, forKey: key)
    }

    
    // MARK: - Get Int
    
    func getInt(key: String) -> Int {

        return defaults.integer(forKey: key)
    }

    
    // MARK: - Save Double
    
    func setDouble(value: Double,
                   key: String) {

        defaults.set(value, forKey: key)
    }

    
    // MARK: - Get Double
    
    func getDouble(key: String) -> Double {

        return defaults.double(forKey: key)
    }

    
    // MARK: - Remove Single Value
    
    func removeValue(key: String) {

        defaults.removeObject(forKey: key)
    }

    
    /// Clears all saved data except first launch status
    func clearAll() {

        // Save first launch value
        let firstLaunchValue = isFirstLaunch()

        if let bundleID = Bundle.main.bundleIdentifier {

            defaults.removePersistentDomain(
                forName: bundleID
            )

            defaults.synchronize()
        }

        // Restore first launch value
        setFirstLaunch(firstLaunchValue)
    }

    
    // MARK: - Login Status
    
    func setLoggedIn(_ value: Bool) {

        defaults.set(value,
                     forKey: Keys.isLoggedIn)
    }

    func isLoggedIn() -> Bool {

        return defaults.bool(forKey: Keys.isLoggedIn)
    }

    
    // MARK: - Auth Token
    
    func setAuthToken(_ token: String) {

        defaults.set(token,
                     forKey: Keys.authToken)
    }

    func getAuthToken() -> String {

        return defaults.string(forKey: Keys.authToken) ?? ""
    }

    
    // MARK: - User ID
    
    func setUserId(_ userId: String) {

        defaults.set(userId,
                     forKey: Keys.userId)
    }

    func getUserId() -> String {

        return defaults.string(forKey: Keys.userId) ?? ""
    }
    
    
    
    // MARK: - First Launch Status
    func setFirstLaunch(_ value: Bool) {

        defaults.set(value,
                     forKey: Keys.firstLaunch)
    }

    func isFirstLaunch() -> Bool {

        return defaults.bool(forKey: Keys.firstLaunch)
    }
    
    
    func saveUser(_ user: User) {

            do {

                let data = try JSONEncoder().encode(user)

                UserDefaults.standard.set(data, forKey: Keys.KEY_USER_DATA)

            } catch {

                print("Failed to save user")
            }
        }

        func getUser() -> User? {

            guard let data = UserDefaults.standard.data(forKey: Keys.KEY_USER_DATA)
            else {
                return nil
            }

            do {

                return try JSONDecoder().decode(User.self, from: data)

            } catch {

                return nil
            }
        }

        func clearUser() {

            UserDefaults.standard.removeObject(forKey: Keys.KEY_USER_DATA)
        }
}
