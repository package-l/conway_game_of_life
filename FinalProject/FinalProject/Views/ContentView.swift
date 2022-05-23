//
//  ContentView.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Simulation
import Configurations
import Statistics

struct ContentView: View {
    var store: Store<AppState, AppState.Action>
    @State var selectedTab = 0
    
    public init(store: Store<AppState, AppState.Action>) {
        self.store = store
        
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(named: "accent")!
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "accent")!
        ]
        UINavigationBar.appearance().tintColor = UIColor.clear //UIColor(named: "accent")
        UINavigationBar.appearance().barTintColor = UIColor.clear //UIColor(named: "accent")
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().tintColor = UIColor(named: "accent")
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
    
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.selectedTab,
                send: AppState.Action.setSelectedTab(tab:)
            )) {
                self.simulationView()
                    .tag(AppState.Tab.simulation)
                self.configurationsView()
                    .tag(AppState.Tab.configuration)
                self.statisticsView()
                    .tag(AppState.Tab.statistics)
            }
        }
        .accentColor(Color("accent"))
    }

    private func simulationView() -> some View {
        SimulationView(
            store: self.store.scope(
                state: \.simulationState,
                action: AppState.Action.simulationAction(action:)
            )
        )
        .tabItem {
            Image(systemName: "circle.grid.2x2")
            Text("Simulation")
        }
    }
    

    private func configurationsView() -> some View {
        ConfigurationsView(
            store: self.store.scope(
                state: \.configurationState,
                action: AppState.Action.configurationsAction(action:)
            )
        )
        .tabItem {
            Image(systemName: "dot.squareshape")
            Text("Configuration")
        }
        .background(Color("configColor"))
    }

    private func statisticsView() -> some View {
        StatisticsView(
            store: store.scope(
                state: \.statisticsState,
                action: AppState.Action.statisticsAction(action:)
            )
        )
       .tabItem {
            Image(systemName: "number.circle")
            Text("Statistics")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static let previewState = AppState()
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: previewState,
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
