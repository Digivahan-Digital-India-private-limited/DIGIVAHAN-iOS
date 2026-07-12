//
//  CommonFunctions.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import UIKit
import MapKit

class CommonFunctions {

    // MARK: - Show TextField Error

    static func showTextFieldError(fieldLayout: UIView, errorLayout: UIStackView,
        errorLabel: UILabel,
        message: String
    ) {

        fieldLayout.layer.borderColor = UIColor.red.cgColor
        fieldLayout.layer.borderWidth = 1
        fieldLayout.layer.cornerRadius = 8
        
        errorLayout.isHidden = false

        errorLabel.text = message
        
    }

    // MARK: - Clear TextField Error

    static func clearTextFieldError(fieldLayout: UIView, errorLayout: UIStackView
    ) {

        fieldLayout.layer.borderWidth = 0
        
        errorLayout.isHidden = true

    }
    
    
    static func parseUserFromJson(_ userJson: [String: Any]) -> User {

        let user = User()

        if let basicDetails = userJson["basic_details"] as? [String: Any] {

            user.firstName =
                basicDetails["first_name"] as? String ?? ""

            user.lastName =
                basicDetails["last_name"] as? String ?? ""

            user.phoneNumber =
                basicDetails["phone_number"] as? String ?? ""

            user.phoneNumberVerified =
                basicDetails["phone_number_verified"] as? Bool ?? false

            user.isPhoneNumberPrimary =
                basicDetails["is_phone_number_primary"] as? Bool ?? false


            

            

            user.email =
                basicDetails["email"] as? String ?? ""

            user.isEmailVerified =
                basicDetails["is_email_verified"] as? Bool ?? false

            user.isEmailPrimary =
                basicDetails["is_email_primary"] as? Bool ?? false

            user.password =
                basicDetails["password"] as? String ?? ""

            user.occupation =
                basicDetails["occupation"] as? String ?? ""

            user.profileCompletionPercent =
                basicDetails["profile_completion_percent"] as? Int ?? 0

            user.profilePic =
                basicDetails["profile_pic"] as? String ?? ""

            user.profileId =
                basicDetails["profile_id"] as? String ?? ""
        }

        if let publicDetails = userJson["public_details"] as? [String: Any] {

            user.nickName =
                publicDetails["nick_name"] as? String ?? ""

            user.address =
                publicDetails["address"] as? String ?? ""

            user.age =
                publicDetails["age"] as? String ?? ""

            user.gender =
                publicDetails["gender"] as? String ?? ""

            user.publicPic =
                publicDetails["public_pic"] as? String ?? ""

            user.publicId =
                publicDetails["public_id"] as? String ?? ""
        }

        return user
    }
    
    static func showSuccessDialog(
        from vc: UIViewController,
        verificationType: String
    ) {

        let title: String
        let message: String
        let buttonTitle: String

        switch verificationType {
        case "verify":
            title = "Account verified successfully"
            message = "Your account is verified successfully. Please login again."
            buttonTitle = "Verified"

        case "createAccount":
            title = "Account Created"
            message = "Welcome to Digivahan."
            buttonTitle = "Login"

        case "changePassword":
            title = "Password Changed"
            message = "Your password has been changed. Please use the new password next time you log in."
            buttonTitle = "OK"

        default:
            title = "Success"
            message = "Operation completed successfully."
            buttonTitle = "OK"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: buttonTitle,
            style: .default
        ) { _ in

            if verificationType == "changePassword" {
                vc.navigationController?.popViewController(animated: true)
            } else {
                NavigationManager.moveToScreen(
                    from: vc,
                    storyboardName: "Auth",
                    viewControllerID: "LoginScreenVC"
                )
            }
        })

        vc.present(alert, animated: true)
    }
    
    static func shareAppWithImage(
            from viewController: UIViewController
        ) {

            DispatchQueue.global(qos: .userInitiated).async {

                guard let image = UIImage(
                    named: "share_image"
                ) else {

                    print("Image not found")
                    return
                }

                // Save image to temporary directory
                let tempDirectory =
                FileManager.default.temporaryDirectory

                let fileURL =
                tempDirectory.appendingPathComponent(
                    "share_image.png"
                )

                guard let imageData =
                image.pngData() else {

                    print("Unable to convert image")
                    return
                }

                do {

                    try imageData.write(
                        to: fileURL
                    )

                    let message =
                    getAppSharingMessage()

                    DispatchQueue.main.async {

                        let activityVC =
                        UIActivityViewController(
                            activityItems: [
                                message,
                                fileURL
                            ],
                            applicationActivities: nil
                        )

                        // iPad Support
                        if let popover =
                            activityVC.popoverPresentationController {

                            popover.sourceView =
                            viewController.view

                            popover.sourceRect =
                            CGRect(
                                x: viewController.view.bounds.midX,
                                y: viewController.view.bounds.midY,
                                width: 0,
                                height: 0
                            )
                        }

                        viewController.present(
                            activityVC,
                            animated: true
                        )
                    }

                } catch {

                    print(
                        "Share Error:",
                        error.localizedDescription
                    )
                }
            }
        }
    
    static func getAppSharingMessage() -> String {
        
//        let appURL = "https://apps.apple.com/app/id\(appID)"

        let defaultMessage = """
        Undi mandi shandi,
        jo is app ko download na kare,
        uski gaadi ki mileage ho jaaye kam… permanently! 😜🚗!

        👉 https://apps.apple.com/app/idXXXXXXXXX
        """

        let customMessage =
        PreferenceManager.shared.getString(
            key: "APP_SHARING_MESSAGE"
        )

        if !customMessage.isEmpty {
            return customMessage
        }

        return defaultMessage
    }
    
    /// Shows Logout / Login Expired Dialog
        ///
        /// Parameters:
        /// - viewController: Current screen
        /// - isLogout:
        ///     - true  = Show Logout Confirmation
        ///     - false = Session Expired Dialog
        ///
        /// Usage:
        ///
        /// ```swift
        /// CommonFunctions.logout(
        ///     from: self,
        ///     isLogout: true
        /// )
        /// ```
        ///
        /// ```swift
        /// CommonFunctions.logout(
        ///     from: self,
        ///     isLogout: false
        /// )
        /// ```
        ///
        static func logout(
            from viewController: UIViewController,
            isLogout: Bool
        ) {

            let title =
            isLogout
            ? "Logout from device."
            : "Login Expired"

            let message =
            isLogout
            ? "Are you sure you want to log out?"
            : "Please login again"

            let actionTitle =
            isLogout
            ? "Yes"
            : "Login"

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            // Close Button
            if isLogout {

                alert.addAction(
                    UIAlertAction(
                        title: "Cancel",
                        style: .cancel
                    )
                )
            }

            // Logout/Login Button
            alert.addAction(
                UIAlertAction(
                    title: actionTitle,
                    style: .destructive
                ) { _ in

                    self.performLogout(
                        from: viewController
                    )
                }
            )

            viewController.present(
                alert,
                animated: true
            )
        }

        // MARK: - Perform Logout

        /// Clears local data
        /// Logs out from OneSignal
        /// Opens Login Screen
        private static func performLogout(
            from viewController: UIViewController
        ) {

            // Clear Preferences
            PreferenceManager.shared.clearAll()

            // Keep First Launch False
            PreferenceManager.shared.setLoggedIn(false)

            // TODO:
            // OneSignal Logout
            //
            // OneSignal.logout()
            //
            // Push Subscription OptOut
            //
            // OneSignal.User.pushSubscription.optOut()

            print("User Logged Out")

            NavigationManager.moveToNavigationController(
                from: viewController,
                storyboardName: "Auth",
                navigationControllerID: "AuthNavigationController"
            )
        }
    
    static func checkValue(_ value: String?) -> Int {

        return (value != nil &&
                !value!.isEmpty &&
                value!.lowercased() != "null") ? 1 : 0
    }
    
    
    static func compressImage(
            _ image: UIImage,
            targetSizeKB: Int = 1024
        ) -> Data? {

            let maxWidth: CGFloat = 1280
            let maxHeight: CGFloat = 1280

            var actualWidth = image.size.width
            var actualHeight = image.size.height

            let ratio = min(maxWidth / actualWidth, maxHeight / actualHeight)

            if actualWidth > maxWidth || actualHeight > maxHeight {
                actualWidth *= ratio
                actualHeight *= ratio
            }

            UIGraphicsBeginImageContextWithOptions(
                CGSize(width: actualWidth, height: actualHeight),
                false,
                1.0
            )

            image.draw(in: CGRect(
                x: 0,
                y: 0,
                width: actualWidth,
                height: actualHeight
            ))

            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            guard let finalImage = resizedImage else {
                return nil
            }

            let targetBytes = targetSizeKB * 1024

            var compression: CGFloat = 0.9
            let minCompression: CGFloat = 0.3

            guard var imageData = finalImage.jpegData(compressionQuality: compression) else {
                return nil
            }

            while imageData.count > targetBytes && compression > minCompression {

                compression -= 0.05

                if let data = finalImage.jpegData(compressionQuality: compression) {
                    imageData = data
                }

                print("📉 Quality: \(compression)")
                print("📦 Size: \(imageData.count / 1024) KB")
            }

            print("✅ Final Size: \(imageData.count / 1024) KB")

            return imageData
        }
    
    
    static func setScrolling(
            for textField: UITextField,
            in scrollView: UIScrollView,
            to targetView: UIView
        ) {

            textField.addTarget(
                self,
                action: #selector(textFieldDidBeginEditing(_:)),
                for: .editingDidBegin
            )

            objc_setAssociatedObject(
                textField,
                &AssociatedKeys.scrollView,
                scrollView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            objc_setAssociatedObject(
                textField,
                &AssociatedKeys.targetView,
                targetView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        @objc private static func textFieldDidBeginEditing(_ textField: UITextField) {

            guard let scrollView = objc_getAssociatedObject(
                textField,
                &AssociatedKeys.scrollView
            ) as? UIScrollView,

            let targetView = objc_getAssociatedObject(
                textField,
                &AssociatedKeys.targetView
            ) as? UIView else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

                let rect = targetView.convert(targetView.bounds, to: scrollView)

                scrollView.scrollRectToVisible(
                    CGRect(
                        x: rect.origin.x,
                        y: rect.origin.y - 20,
                        width: rect.width,
                        height: rect.height + 100
                    ),
                    animated: true
                )
            }
        }

        private struct AssociatedKeys {
            static var scrollView = "scrollView"
            static var targetView = "targetView"
        }
    
    static func getDatePart(from dateString: String?, type: String?) -> String {

        guard let dateString = dateString,
              let type = type,
              let parsedDate = parseDateSafely(dateString) else {
            return ""
        }

        let calendar = Calendar.current

        switch type.lowercased() {

        case "year":
            return String(calendar.component(.year, from: parsedDate))

        case "month":
            return String(calendar.component(.month, from: parsedDate)) // 1–12

        case "day", "date":
            return String(calendar.component(.day, from: parsedDate))

        case "hour":
            return String(calendar.component(.hour, from: parsedDate)) // 0–23

        case "minute":
            return String(calendar.component(.minute, from: parsedDate))

        case "second":
            return String(calendar.component(.second, from: parsedDate))

        case "age":
            return String(TimeUtils.calculateAge(from: parsedDate))

        default:
            return ""
        }
    }
    
    
    static func parseDateSafely(_ dateString: String) -> Date? {

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd" // adjust format as needed
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        return formatter.date(from: dateString)
    }
    
    
    static func addDashedBorder(
        to view: UIView,
        color: UIColor = UIColor(named: "iconColor") ?? .systemGreen,
        cornerRadius: CGFloat = 20
    ) {

        // Remove old border if already added
        view.layer.sublayers?.removeAll(where: {
            $0.name == "DashedBorderLayer"
        })

        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBorderLayer"
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [10, 8] // dash length, gap length
        shapeLayer.frame = view.bounds
        shapeLayer.path = UIBezierPath(
            roundedRect: view.bounds,
            cornerRadius: cornerRadius
        ).cgPath

        view.layer.addSublayer(shapeLayer)
    }
    
    static func closeKeyboard() {

            DispatchQueue.main.async {

                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        }
    
    static func safeValue(_ value: String?) -> String {

        let text = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if text.isEmpty ||
            text.lowercased() == "na" ||
            text.lowercased() == "n/a" ||
            text.lowercased() == "null" {

            return "Not Defined"
        }

        return text
    }
    
    
    static func getFormattedOwner(_ ownershipDetails: String?) -> String {

        guard var ownershipDetails = ownershipDetails?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ownershipDetails.isEmpty else {
            return ""
        }

        // If already "First Owner", return as is
        if ownershipDetails.caseInsensitiveCompare("First Owner") == .orderedSame {
            return "First Owner"
        }

        // Handle "Owner X" pattern
        if ownershipDetails.lowercased().hasPrefix("owner") {

            // Extract digits
            let numberPart = ownershipDetails.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()

            if let ownerNumber = Int(numberPart) {

                switch ownerNumber {
                case 1:
                    return "First Owner"
                case 2:
                    return "Second Owner"
                case 3:
                    return "Third Owner"
                case 4:
                    return "Fourth Owner"
                case 5:
                    return "Fifth Owner"
                case 6:
                    return "Sixth Owner"
                case 7:
                    return "Seventh Owner"
                case 8:
                    return "Eighth Owner"
                case 9:
                    return "Ninth Owner"
                default:
                    return ownershipDetails // beyond 9 → keep original
                }
            }
        }

        // Fallback → return server value
        return ownershipDetails
    }
    
    // MARK: - Vehicle Age

    static func getVehicleAge(
        currentDateStr: String?,
        registrationDateStr: String?
    ) -> String {

        guard
            let currentDate = TimeUtils.parseDateSafely(currentDateStr),
            let registrationDate = TimeUtils.parseDateSafely(registrationDateStr)
        else {
            return "Not Defined"
        }

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: registrationDate,
            to: currentDate
        )

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        var ageParts: [String] = []

        if years > 0 {
            ageParts.append("\(years) year\(years > 1 ? "s" : "")")
        }

        if months > 0 {
            ageParts.append("\(months) month\(months > 1 ? "s" : "")")
        }

        if days > 0 || ageParts.isEmpty {
            ageParts.append("\(days) day\(days > 1 ? "s" : "")")
        }

        return ageParts.joined(separator: ", ")
    }
    
    
    static func openGoogleMaps(latitude: String?, longitude: String?) {

            guard
                let latString = latitude,
                let lonString = longitude,
                let lat = Double(latString),
                let lon = Double(lonString)
            else {
                print("Invalid latitude or longitude")
                return
            }

            if let googleURL = URL(string: "comgooglemaps://?q=\(lat),\(lon)"),
               UIApplication.shared.canOpenURL(googleURL) {

                UIApplication.shared.open(googleURL)

            } else {

                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "Location"

                mapItem.openInMaps()
            }
        }
    
    static func fetchAppInfo() {

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_APP_INFO,
            method: "GET"
        ) { response, status, message in

            let manager = PreferenceManager.shared

            guard status,
                  let data = response?["data"] as? [String: Any] else {

                manager.setCurrentDate("")
                manager.setOneSignalId("")
                manager.setAppSharingMessage("")
                return
            }

            // Current Date
            if let currentDate = data["currentDate"] as? String,
               !currentDate.isEmpty {

                manager.setCurrentDate(currentDate)

            } else {

                manager.setCurrentDate("")
            }

            // OneSignal ID
            if let oneSignalId = data["oneSignalID"] as? String,
               !oneSignalId.isEmpty {

                manager.setOneSignalId(oneSignalId)

            } else {

                manager.setOneSignalId("")
            }

            // App Sharing Message
            if let appSharingMessage = data["appSharingMessage"] as? String,
               !appSharingMessage.isEmpty {

                manager.setAppSharingMessage(appSharingMessage)

            } else {

                manager.setAppSharingMessage("")
            }
        }
    }
    
}
