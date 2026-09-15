//
//  ChallanRefreshManager.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/08/26.
//

import Foundation
import UIKit

class ChallanRefreshManager {

    static let shared = ChallanRefreshManager()

    private init() {}

    private let REFRESH_INTERVAL: Int64 = 24 * 60 * 60 * 1000

    func checkVehicleChallanOncePerDay(
        vehicleNumber: String,
        viewController: ChallanListVC
    ) {

        DispatchQueue.global(qos: .background).async {

            let entity = VehicleChallanDatabase.shared.get(
                vehicleNumber: vehicleNumber
            )

            DispatchQueue.main.async {

                if entity == nil {

                    print("📡 No local data, calling API")

                    viewController.getChallanList(
                        vehicleNumber: vehicleNumber,
                        isRefresh: true
                    )

                } else {

                    self.getServerTimeAndHandleRefresh(
                        entity: entity!,
                        vehicleNumber: vehicleNumber,
                        viewController: viewController
                    )
                }
            }
        }
    }

    private func getServerTimeAndHandleRefresh(
        entity: VehicleChallanEntity,
        vehicleNumber: String,
        viewController: ChallanListVC
    ) {

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_APP_INFO,
            method: "GET"
        ) { response, status, message in

            var serverMillis: Int64

            if status {

                let serverDate =
                    response?["currentDate"] as? String ?? ""

                let serverTime =
                    response?["currentTime"] as? String ?? ""

                serverMillis = TimeUtils.parseServerDateTimeToMillis(
                    date: serverDate,
                    time: serverTime
                )

            } else {

                serverMillis = Int64(Date().timeIntervalSince1970 * 1000)
            }

            self.handleRefreshDecision(
                entity: entity,
                vehicleNumber: vehicleNumber,
                serverMillis: serverMillis,
                viewController: viewController
            )
        }
    }

    private func handleRefreshDecision(
        entity: VehicleChallanEntity,
        vehicleNumber: String,
        serverMillis: Int64,
        viewController: ChallanListVC
    ) {

        let nextAllowed =
            entity.lastHitServerMillis + REFRESH_INTERVAL

        let remaining =
            nextAllowed - serverMillis

        if remaining > 0 {

            RefreshTimerBottomSheet.shared.configure(
                remainingMillis: remaining,
                canRefresh: false
            )

            RefreshTimerBottomSheet.shared.show(
                on: viewController
            )

        } else {

            viewController.getChallanList(
                vehicleNumber: vehicleNumber,
                isRefresh: true
            )

            RefreshTimerBottomSheet.shared.configure(
                remainingMillis: 0,
                canRefresh: true
            )

            RefreshTimerBottomSheet.shared.show(
                on: viewController
            )
        }
    }
}
