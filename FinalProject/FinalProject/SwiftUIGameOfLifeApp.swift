//
//  SwiftUIGameOfLifeApp.swift
//  FinalProject
//
//  Created by Van Simmons on 11/20/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@main
struct SwiftUIGameOfLife: App {
    let store = Store(
        initialState: AppState.restore(),
        reducer: appReducer,
        environment: AppEnvironment()
    )
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
