//
//  StatisticsView.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import SwiftUI
import ComposableArchitecture
import Statistics

public struct StatisticsView: View {
    let store: Store<StatisticsState, StatisticsState.Action>
    let viewStore: ViewStore<StatisticsState, StatisticsState.Action>

    public init(store: Store<StatisticsState, StatisticsState.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color("statColor")
                    .edgesIgnoringSafeArea([.all])
                VStack {
                    Form {
                        // Your Problem 7A code starts here
                        FormLine(
                            title: "Steps",
                            value: viewStore.state.statistics.steps
                        )
                        FormLine(
                            title: "Alive",
                            value: viewStore.state.statistics.alive
                        )
                        FormLine(
                            title: "Born",
                            value: viewStore.state.statistics.born
                        )
                        FormLine(
                            title: "Died",
                            value: viewStore.state.statistics.died
                        )
                        FormLine(
                            title: "Empty",
                            value: viewStore.state.statistics.empty
                        )
                        ThemedButton(text: "Reset") {
                            self.viewStore.send(.reset)
                        }
                        Spacer()
                    }
                    .padding(6.0)

                }
                .background(Color("statColor"))
            }
            .navigationBarTitle(Text("Statistics"))
            .navigationBarHidden(false)
            .background(Color("statColor"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

public struct StatisticsView_Previews: PreviewProvider {
    static let previewState = StatisticsState()
    public static var previews: some View {
        StatisticsView(
            store: Store(
                initialState: previewState,
                reducer: statisticsReducer,
                environment: StatisticsEnvironment()
            )
        )
    }
}
