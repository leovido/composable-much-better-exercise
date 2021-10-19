//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import ComposableArchitecture
import Foundation

public enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
    case userNotifications(UserNotificationClient.DelegateEvent)
    case fetchToken
    case receiveToken(Result<CognitoToken, NSError>)
}
