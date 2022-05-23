//
//  Simulation.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import ComposableArchitecture
import Combine
import Dispatch
import Grid
import GameOfLife

public struct SimulationState {
    public var gridState: GridState
    public var isRunningTimer = false
    public var shouldRestartTimer = false
    public var timerInterval = 0.5
    public var atStart = true

    public init(gridState: GridState = GridState()) {
        self.gridState = gridState
    }
}

extension SimulationState: Equatable {}


extension SimulationState: Codable { }

public extension SimulationState {
    enum Action {
        case setGridSize(Int)
        case update(grid: Grid)
        case setTimerInterval(Double)
        case stepGrid
        case resetGridToEmpty
        case resetGridToRandom
        case tick
        case startTimer
        case stopTimer
        case setShouldRestartTimer(Bool)
        case toggleTimer(Bool)
        case grid(action: GridState.Action)
        case startAnimation
    }
    
    enum Identifiers: Hashable {
        case simulationTimer
        case simulationCancellable
    }
}

public struct SimulationEnvironment {
    var scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    var gridEnvironment = GridEnvironment()
    var timerEffectCancellable: AnyCancellable? = .none
    
    public init(
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        gridEnvironment: GridEnvironment = GridEnvironment()
    ) {
        self.scheduler = scheduler
        self.gridEnvironment = gridEnvironment
    }
}

public let simulationReducer = Reducer<SimulationState, SimulationState.Action, SimulationEnvironment>.combine(
    gridReducer.pullback(
        state: \.gridState,
        action: /SimulationState.Action.grid(action:),
        environment: \.gridEnvironment 
    ),
    Reducer<SimulationState, SimulationState.Action, SimulationEnvironment>{ state, action, env in
        switch action {
            case .setGridSize(let newSize):
                state.gridState.grid = Grid(newSize, newSize, Grid.Initializers.empty)
                state.gridState.history.reset(with: state.gridState.grid)
                return .none
            case .update(grid: let grid):
                state.gridState.grid = grid
                state.gridState.history = Grid.History()
                state.gridState.history.add(state.gridState.grid)
                return .none
            case .setTimerInterval(let interval):
                state.isRunningTimer = false
                state.timerInterval = interval == 0.0 ? 0.01 : interval
                return Just(.stopTimer).eraseToEffect()
            case .resetGridToEmpty:
                state.isRunningTimer = false
                state.gridState.grid = Grid(
                    state.gridState.grid.size.rows,
                    state.gridState.grid.size.cols,
                    Grid.Initializers.empty
                )
                state.gridState.history = Grid.History()
                state.gridState.history.add(state.gridState.grid)
                return Just(.stopTimer).eraseToEffect()
            case .resetGridToRandom:
                state.isRunningTimer = false
                state.gridState.grid = Grid(
                    state.gridState.grid.size.rows,
                    state.gridState.grid.size.cols,
                    Grid.Initializers.random
                )
                state.gridState.history = Grid.History()
                state.gridState.history.add(state.gridState.grid)
                return Just(.stopTimer).eraseToEffect()
            case .stepGrid:
                state.isRunningTimer = false
                state.gridState.grid = state.gridState.grid.next
                state.gridState.history = Grid.History()
                return Just(.stopTimer).eraseToEffect()
            case .tick:
                state.gridState.grid = state.gridState.grid.next
                state.gridState.history.add(state.gridState.grid)
                return state.gridState.history.cycleLength == .none
                    ? .none
                    : Just(.stopTimer).eraseToEffect()
            case .startTimer:
                state.gridState.history.reset(with: state.gridState.grid)
                state.isRunningTimer = true
                return Effect
                    .timer(
                        id: SimulationState.Identifiers.simulationTimer,
                        every: .seconds(state.timerInterval),
                        on: env.scheduler
                )
                .map {_ in .tick }
                .cancellable(id: SimulationState.Identifiers.simulationCancellable)
            case .stopTimer:
                state.isRunningTimer = false
                return .cancel(id: SimulationState.Identifiers.simulationCancellable)
            case .setShouldRestartTimer(let shouldRestart):
                state.shouldRestartTimer = shouldRestart
                return (state.shouldRestartTimer ? Just(.stopTimer) : Just(.startTimer))
                    .eraseToEffect()
            case .toggleTimer(let onOff):
                return Just(onOff ? .startTimer : .stopTimer).eraseToEffect()
            case .grid(action:):
                return .none
            case .startAnimation:
                if (state.atStart == true) {
                    state.atStart = false
                }
                else if (state.atStart == false) {
                    state.atStart = true
                }
                state.isRunningTimer = false
                state.gridState.grid = state.gridState.grid.next
                state.gridState.history = Grid.History()
                return Just(.stopTimer).eraseToEffect()
        }
    }
)
