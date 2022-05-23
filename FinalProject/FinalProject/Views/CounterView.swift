//
//  CounterView.swift
//  FinalProject
//
//  Created by Van Simmons on 7/25/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import SwiftUI
import ComposableArchitecture
import Configurations

struct CounterView: View {
    let store: Store<CounterState, CounterAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button("−") { viewStore.send(.decrementButtonTapped) }
                Text("\(viewStore.count)")
                    .font(Font.title.monospacedDigit())
                Button("+") { viewStore.send(.incrementButtonTapped) }
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: Store<CounterState, CounterAction>(
                initialState: CounterState(count: 10),
                reducer: counterReducer,
                environment: CounterEnvironment()
            )
        )
    }
}
