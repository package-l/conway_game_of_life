//
//  Application.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import ComposableArchitecture
import Combine
import FunctionalProgramming
import Simulation
import Configurations
import Configuration
import Statistics
import Foundation

struct AppState: Equatable {
    var selectedTab = Tab.simulation
    var simulationState = SimulationState()
    var configurationState = ConfigurationsState()
    var statisticsState = StatisticsState()
}

extension AppState {
    enum Tab {
        case simulation
        case configuration
        case statistics
    }
}

extension AppState: Codable {}

extension AppState {
    enum Action {
        case setSelectedTab(tab: Tab)
        case simulationAction(action: SimulationState.Action)
        case configurationsAction(action: ConfigurationsState.Action)
        case statisticsAction(action: StatisticsState.Action)
    }
}

extension AppState {
    func save() {
        guard let data = self.data else { return }
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: AppState.defaultsKey)
        defaults.synchronize()
    }

    static func restore() -> AppState {
        guard let savedData = UserDefaults.standard.data(forKey: AppState.defaultsKey) else {
            return AppState()
        }
        return AppState(data: savedData) ?? AppState()
    }
}

extension AppState {
    static let defaultsKey = "AppState"
    static let jsonDecoder = JSONDecoder()
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    var data: Data? {
        try? Self.jsonEncoder.encode(self)
    }

    init?(data: Data) {
        do {
            self = try Self.jsonDecoder.decode(AppState.self, from: data)
        } catch {
            return nil
        }
    }
}

extension AppState.Tab: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
            case 0: self = .simulation
            case 1: self = .configuration
            case 2: self = .statistics
            default: throw CodingError.unknownValue
        }
    }

    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            case AppState.Tab.simulation: try container.encode(0, forKey: .rawValue)
            case AppState.Tab.configuration: try container.encode(1, forKey: .rawValue)
            case AppState.Tab.statistics: try container.encode(2, forKey: .rawValue)
        }
    }
}


struct AppEnvironment {
    var simulationEnvironment = SimulationEnvironment()
    var configurationsEnvironment = ConfigurationsEnvironment()
    var statisticsEnvironment = StatisticsEnvironment()
}

let configurationToSimulationReducer = Reducer<AppState, ConfigurationsState.Action, AppEnvironment> { state, action, env in
    switch action {
        case .configuration(index: let index, action: let configAction):
            switch configAction {
                case .simulate(let grid):
                    state.simulationState.gridState.grid = grid
                default:
                    ()
            }
            return .none
        default:
            return .none
    }
}

let _appReducer = Reducer<AppState, AppState.Action, AppEnvironment>.combine(
    // swiftlint:disable trailing_closure
    /// Submodel reducers
    simulationReducer.pullback(
        state: \.simulationState,
        action: /AppState.Action.simulationAction,
        environment: \.simulationEnvironment
    ),
    configurationsReducer.pullback(
        state: \.configurationState,
        action: /AppState.Action.configurationsAction,
        environment: \.configurationsEnvironment
    ),
    statisticsReducer.pullback(
        state: \.statisticsState,
        action: /AppState.Action.statisticsAction,
        environment: \.statisticsEnvironment
    ),
    configurationToSimulationReducer.pullback(
        state: \.self,
        action: /AppState.Action.configurationsAction(action:),
        environment: identity
    ),
    /// Main reducer
    Reducer { state, action, env in
        switch action {
            case .setSelectedTab(let tab):
                state.selectedTab = tab
            case .simulationAction(action: .tick):
                state.statisticsState = StatisticsState(
                    statistics: state.statisticsState.statistics.add(
                        state.simulationState.gridState.grid
                    )
                )
                return .none
            case .simulationAction(action: .resetGridToRandom), .simulationAction(action: .resetGridToEmpty):
                return Just(AppState.Action.statisticsAction(action: .reset)).eraseToEffect()
            default:
                ()
        }
        state.save()
        return .none
    }
)

var appReducer: Reducer<AppState, AppState.Action, AppEnvironment> {
//    #if DEBUG
//    return _appReducer.debug()
//    #else
    return _appReducer
//    #endif
}
