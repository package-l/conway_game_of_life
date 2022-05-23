import XCTest
import ComposableArchitecture
import Combine
import Grid
import GameOfLife
@testable import SimulationView

final class SimulationViewTests: XCTestCase {
    static var allTests = [
        ("testExample", testResetTicks),
    ]

    func testResetTicks() {
        let store = TestStore(
            initialState: SimulationState(
                gridState: GridState(grid: Grid(10, 10, Grid.Initializers.empty))
            ),
            reducer: simulationReducer,
            environment: SimulationEnvironment()
        )
        store.assert(
            .send(.resetTicks) { $0.gridState.ticks = 0 }
        )
    }

    func testTimer() {
        let scheduler = DispatchQueue.testScheduler
        let env = SimulationEnvironment(scheduler: AnyScheduler(scheduler))
        let gridState = GridState(grid: Grid(10, 10, Grid.Initializers.empty))
        let store = TestStore(
          initialState: SimulationState(gridState: gridState),
          reducer: simulationReducer,
          environment: env
        )
        store.assert(
            .send(.startTimer) { $0.isRunningTimer = true },
            .do { scheduler.advance(by: 1.0) },
            .receive(.tick) { $0.gridState.ticks = 1 },
            .send(.stopTimer) { $0.isRunningTimer = false }
        )
    }
}
