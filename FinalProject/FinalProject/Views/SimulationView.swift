//
//  SimulationView.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import SwiftUI
import ComposableArchitecture
import Simulation
import Grid

public struct SimulationView: View {
    let store: Store<SimulationState, SimulationState.Action>
    //@State var secondsElapsed = 0
    //@State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(store: Store<SimulationState, SimulationState.Action>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            ZStack {
                Color("simulateColor")
                    .edgesIgnoringSafeArea([.all])
                WithViewStore(store) { viewStore in
                    VStack {
                        GeometryReader { g in
                            if g.size.width < g.size.height {
                                self.verticalContent(for: viewStore, geometry: g)
                            } else {
                                self.horizontalContent(for: viewStore, geometry: g)
                            }
                        }
                        Spacer()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarTitle("Simulation")
                    .navigationBarHidden(false)
                    // Problem 6 - your answer goes here.
                    .onAppear(perform: { viewStore.send(.setShouldRestartTimer(true))})
                    .onDisappear {viewStore.send(.setShouldRestartTimer(false))}
                    /*.onReceive(timer) {
                        self.secondsElapsed = $0
                    }*/
                    
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    func verticalContent(
        for viewStore: ViewStore<SimulationState, SimulationState.Action>,
        geometry g: GeometryProxy
    ) -> some View {
            VStack {
                Spacer()
                InstrumentationView(
                    store: self.store,
                    width: g.size.width * 0.82
                )
                .frame(height: g.size.height * 0.35)
                .padding(.bottom, 16.0)
                
                Divider()
                    .foregroundColor(Color("accent"))
                
                EmptyView()
                    .modifier(
                        MyGridAnimationModifier(
                            fractionComplete: viewStore.atStart ? 0.0 : 1.0,
                            store: self.store.scope(
                                state: \.gridState,
                                action: SimulationState.Action.grid(action:)
                            ),
                            configuration: GridView.Configuration()
                        )
                    )
            }
    }

    func horizontalContent(
        for viewStore: ViewStore<SimulationState, SimulationState.Action>,
        geometry g: GeometryProxy
    ) -> some View {
            HStack {
                Spacer()
                InstrumentationView(store: self.store)
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Spacer()
                    EmptyView()
                        .modifier(
                            MyGridAnimationModifier(
                                fractionComplete: viewStore.atStart ? 0.0 : 1.0,
                                store: self.store.scope(
                                    state: \.gridState,
                                    action: SimulationState.Action.grid(action:)
                                ),
                                configuration: GridView.Configuration()
                            )
                        )
                    Spacer()
                }
                Spacer()
            }
    }
    
}

struct MyGridAnimationModifier: AnimatableModifier {
    typealias Body = GridView
    var fractionComplete: Double = 0.0
    var store: Store<GridState, GridState.Action>
    var configuration: GridView.Configuration
    
    var animatableData: Double {
        get { fractionComplete }
        set { fractionComplete = newValue }
    }
    
    func body(content: Content) -> GridView {
        GridView(
            store: store,
            configuration: GridView.Configuration(),
            fractionComplete: CGFloat(fractionComplete)
        )
    }
}

public struct SimulationView_Previews: PreviewProvider {
    static let previewState = SimulationState()
    public static var previews: some View {
        SimulationView(
            store: Store(
                initialState: previewState,
                reducer: simulationReducer,
                environment: SimulationEnvironment()
            )
        )
    }
}
