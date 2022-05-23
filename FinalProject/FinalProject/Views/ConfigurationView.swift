//
//  ConfigurationView.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 6/1/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import ComposableArchitecture
import SwiftUI
import GameOfLife
import Configuration
import FunctionalProgramming

public struct ConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationState.Action>

    public init(store: Store<ConfigurationState, ConfigurationState.Action>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            // Your Problem 3c code goes here.
            NavigationLink(destination: GridEditorView.init(store: store)) {
                VStack {
                    HStack {
                        Text(viewStore.configuration.title)
                            .font(.system(size: 24.0))
                        Spacer()
                    }
                    HStack {
                        Text(viewStore.configuration.shape)
                            .font(.system(size: 14.0))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                }
                // you Problem 3C code ends here.
            }
        }
    }
}

public struct ConfigurationView_Previews: PreviewProvider {
    public static var previews: some View {
        ConfigurationView(
            store: Store<ConfigurationState, ConfigurationState.Action>(
                initialState: try! ConfigurationState(configuration: Grid.Configuration(title: "Demo", contents: [[1,1]])),
                reducer: configurationReducer,
                environment: ConfigurationEnvironment()
            )
        )
    }
}
