//
//  GridView.swift
//  SwiftUIGameOfLife
//
//  Created by Van Simmons on 5/31/20.
//  Copyright © 2020 ComputeCycles, LLC. All rights reserved.
//
import SwiftUI
import ComposableArchitecture
import Grid
import GameOfLife

public struct GridView: View {
    var fractionComplete: CGFloat
    var store: Store<GridState, GridState.Action>
    @ObservedObject var viewStore: ViewStore<GridState, GridState.Action>
    let configuration: GridView.Configuration
    @State private var lastPosition: Grid.Offset? = .none
    @State private var gradient = false
    

    public init(
        store: Store<GridState, GridState.Action>,
        configuration: Configuration = Configuration(),
        fractionComplete: CGFloat
    ) {
        self.store = store
        self.viewStore = ViewStore(store, removeDuplicates: ==)
        self.configuration = configuration
        self.fractionComplete = CGFloat(fractionComplete)
    }

    func cellWidth(for viewStore: ViewStore<GridState, GridState.Action>, g: GeometryProxy) -> CGFloat {
        g.frame(in: .local).size.width / CGFloat(viewStore.grid.size.cols)
    }

    func cellHeight(for viewStore: ViewStore<GridState, GridState.Action>, g: GeometryProxy) -> CGFloat {
        g.frame(in: .local).size.height / CGFloat(viewStore.grid.size.rows)
    }

    func lines(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> some View {
        return Path { p in
            guard self.cellWidth(for: viewStore, g: g) > 5.0 else { return }
            (0 ... viewStore.grid.size.cols).forEach { i in
                p.move(to: CGPoint(
                    x: g.frame(in: .local).origin.x + self.cellWidth(for: viewStore, g: g) * CGFloat(i),
                    y: g.frame(in: .local).origin.y
                ))
                p.addLine(to: CGPoint(
                    x: g.frame(in: .local).origin.x + self.cellWidth(for: viewStore, g: g) * CGFloat(i),
                    y: g.frame(in: .local).origin.y + g.frame(in: .local).size.height
                ))
            }
            (0 ... viewStore.grid.size.rows).forEach { i in
                p.move(to: CGPoint(
                    x: g.frame(in: .local).origin.x - self.configuration.lineWidth/CGFloat(2.0),
                    y: g.frame(in: .local).origin.y + self.cellHeight(for: viewStore, g: g) * CGFloat(i)
                ))
                p.addLine(to: CGPoint(
                    x: g.frame(in: .local).origin.x + g.frame(in: .local).size.width + self.configuration.lineWidth/CGFloat(2.0),
                    y: g.frame(in: .local).origin.y + self.cellHeight(for: viewStore, g: g) * CGFloat(i)
                ))
            }
        }
        .stroke(Color("gridLine"), lineWidth: self.configuration.lineWidth)
    }

    func cells(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> some View {
        ForEach (viewStore.grid.allOffsets, id: \.self) {
            viewStore.grid[$0.row][$0.col] == .empty
                ? nil
                : Cell(
                    offset: $0,
                    gridSize: viewStore.grid.size,
                    configuration: self.configuration,
                    gridRect: g.frame(in: .local),
                    cellState: viewStore.grid[$0.row][$0.col]
                )
        }
        .frame(
            width: g.size.width,
            height: g.size.height,
            alignment: .center
        )
        .offset(x: 0.0, y: 0.0)
    }

    func squareSize(for g: GeometryProxy) -> CGFloat {
        min(g.size.width, g.size.height) * 0.92
    }

    func cellWidthOffset(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> CGFloat {
        (
            self.cellWidth(for: viewStore, g: g)
            - g.size.width
            - configuration.lineWidth
            - (configuration.inset * 2.0)
        ) / 2.0
    }

    func cellHeightOffset(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> CGFloat {
        (
            self.cellHeight(for: viewStore, g: g)
            - g.size.height
            - configuration.lineWidth
            - (configuration.inset * 2.0)
        ) / 2.0
    }
    
    func littleRectSize(_ g: GeometryProxy) -> CGFloat {
        g.size.width * 0.1
    }
    
    func cellTypeDied(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> some View {
        ForEach (viewStore.grid.allOffsets, id: \.self) {
            viewStore.grid[$0.row][$0.col] == .died
                ? Cell(
                    offset: $0,
                    gridSize: viewStore.grid.size,
                    configuration: self.configuration,
                    gridRect: g.frame(in: .local),
                    cellState: viewStore.grid[$0.row][$0.col]
                )
                : nil
        }
        .frame(
            width: g.size.width,
            height: g.size.height,
            alignment: .center
        )
        .offset(x: 0.0, y: 0.0)
    }
    
    func cellTypeAlive(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> some View {
        ForEach (viewStore.grid.allOffsets, id: \.self) {
            viewStore.grid[$0.row][$0.col] == .alive
                ? Cell(
                    offset: $0,
                    gridSize: viewStore.grid.size,
                    configuration: self.configuration,
                    gridRect: g.frame(in: .local),
                    cellState: viewStore.grid[$0.row][$0.col]
                )
                : nil
        }
        .frame(
            width: g.size.width,
            height: g.size.height,
            alignment: .center
        )
        .offset(x: 0.0, y: 0.0)
    }
    
    func cellTypeBorn(
        for viewStore: ViewStore<GridState, GridState.Action>,
        g: GeometryProxy
    ) -> some View {
        ForEach (viewStore.grid.allOffsets, id: \.self) {
            viewStore.grid[$0.row][$0.col] == .born
                ? Cell(
                    offset: $0,
                    gridSize: viewStore.grid.size,
                    configuration: self.configuration,
                    gridRect: g.frame(in: .local),
                    cellState: viewStore.grid[$0.row][$0.col]
                )
                : nil
        }
        .frame(
            width: g.size.width,
            height: g.size.height,
            alignment: .center
        )
        .offset(x: 0.0, y: 0.0)
    }
    

    public var body: some View {
        Spacer()
        GeometryReader { boundingBox in
            VStack {
                HStack {
                    Spacer()
                    GeometryReader { g in
                        self.lines(for: self.viewStore, g: g)
                            .background(Color("gridBackground"))
                            .gesture(self.touchHandler(geometry: g))
                            .rotation3DEffect(
                                Angle(
                                    radians: Double(fractionComplete)
                                        * 2.0 * Double.pi
                                ),
                                axis: (x: 1.0, y: 1.0, z: 1.0),
                                anchor: .center,
                                anchorZ: 0.0,
                                perspective: 1.0
                            )
                        self.cells(for: self.viewStore, g: g)
                            .offset(
                                x: self.cellWidthOffset(for: self.viewStore, g: g),
                                y: self.cellHeightOffset(for: self.viewStore, g: g)
                            )
                            .rotationEffect(
                                Angle(
                                    radians: Double(fractionComplete) * 2.0 * Double.pi
                                )
                            )
                            .hueRotation(
                                Angle(
                                    radians: Double(fractionComplete)
                                        * 20.0 * Double.pi
                                )
                            )
                        self.cellTypeDied(for: self.viewStore, g: g)
                            .offset(
                                x: self.cellWidthOffset(for: self.viewStore, g: g),
                                y: self.cellHeightOffset(for: self.viewStore, g: g)
                            )
                            .rotation3DEffect(
                                Angle(
                                    radians: Double(fractionComplete) * 2.0 * Double.pi
                                ),
                                axis: (x: 1.0, y: 1.0, z: 1.0),
                                anchor: .center,
                                anchorZ: 0.0,
                                perspective: 1.0
                            )
                        self.cellTypeAlive(for: self.viewStore, g: g)
                            .offset(
                                x: self.cellWidthOffset(for: self.viewStore, g: g),
                                y: self.cellHeightOffset(for: self.viewStore, g: g)
                            )
                            .rotation3DEffect(
                                Angle(
                                    radians: Double(fractionComplete) * 2.0 * Double.pi
                                ),
                                axis: (x: 1.0, y: 1.0, z: 1.0),
                                anchor: .center,
                                anchorZ: 0.0,
                                perspective: 1.0
                            )
                        self.cellTypeBorn(for: self.viewStore, g: g)
                            .offset(
                                x: self.cellWidthOffset(for: self.viewStore, g: g),
                                y: self.cellHeightOffset(for: self.viewStore, g: g)
                            )
                            .rotation3DEffect(
                                Angle(
                                    radians: Double(fractionComplete) * 2.0 * Double.pi
                                ),
                                axis: (x: 1.0, y: 1.0, z: 1.0),
                                anchor: .center,
                                anchorZ: 0.0,
                                perspective: 1.0
                            )
                    }
                    .frame(
                        width: self.squareSize(for: boundingBox),
                        height: self.squareSize(for: boundingBox),
                        alignment: .center
                    )
                    Spacer()
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .frame(alignment: .center)
    }
}

extension GridView {
    private func touchHandler(geometry g: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                guard let touchedCell = self.convert(value.location, geometry: g),
                    touchedCell.row != self.lastPosition?.row || touchedCell.col != self.lastPosition?.col
                    else { return }
                self.viewStore.send(.toggle(touchedCell.row, touchedCell.col))
                self.lastPosition = touchedCell
            }
            .onEnded { _ in
                self.lastPosition = .none
            }
    }
}

extension GridView {
    private func convert(_ touch: CGPoint, geometry g: GeometryProxy) -> Grid.Offset? {
        let touchY = touch.y - (configuration.lineWidth/2.0)
        let row = touchY / g.frame(in: .local).size.height * CGFloat(self.viewStore.grid.size.rows)

        let touchX = touch.x - (configuration.lineWidth/2.0)
        let col = touchX / g.frame(in: .local).size.width * CGFloat(self.viewStore.grid.size.cols)

        let pos = Grid.Offset(row: Int(row), col: Int(col))

        guard pos.row >= 0 && pos.row < viewStore.grid.size.rows
            && pos.col >= 0 && pos.col < viewStore.grid.size.cols
            else { return .none }

        return pos
    }
}

public extension GridView {
    struct Configuration {
        var inset: CGFloat
        var lineWidth: CGFloat
        var aliveColor: String
        var bornColor: String
        var diedColor: String
        var emptyColor: String

        public init(
            inset: CGFloat = 0.5,
            lineWidth: CGFloat = 1.0,
            aliveColor: String = "alive",
            bornColor: String = "born",
            diedColor: String = "died",
            emptyColor: String = "empty"
        ) {
            self.inset = inset
            self.lineWidth = lineWidth
            self.aliveColor = aliveColor
            self.bornColor = bornColor
            self.diedColor = diedColor
            self.emptyColor = emptyColor
        }

        func color(for cellState: CellState) -> String {
            switch cellState {
            case .alive: return aliveColor
            case .born:  return bornColor
            case .died:  return diedColor
            case .empty: return emptyColor
            }
        }
    }
}

extension GridView {
    struct Cell: View {
        var gridOffset: Grid.Offset
        var gridSize: Grid.Size
        var configuration: GridView.Configuration
        var gridRect: CGRect
        var cellState: CellState

        init(
            offset: Grid.Offset,
            gridSize: Grid.Size,
            configuration: GridView.Configuration,
            gridRect: CGRect,
            cellState: CellState
        ) {
            self.gridOffset = offset
            self.gridSize = gridSize
            self.configuration = configuration
            self.gridRect = gridRect
            self.cellState = cellState
        }

        var body: some View {
            Ellipse()
                .fill(Color(color))
                .frame(width: frame.width, height: frame.height)
                .offset(offset)
        }

        // MARK: Helper Methods
        var row: Int { gridOffset.row }
        var col: Int { gridOffset.col }

        var width: CGFloat {
            self.gridRect.size.width / CGFloat(gridSize.cols)
        }

        var height: CGFloat {
            self.gridRect.size.height / CGFloat(gridSize.rows)
        }

        var color: String {
            configuration.color(for: cellState)
        }

        var frame: CGSize {
            switch cellState {
            case .alive, .born, .died, .empty:
                return CGSize(
                    width: size(width),
                    height: size(height)
                )
            }
        }

        func size(_ cellDimension: CGFloat) -> CGFloat {
            cellDimension - configuration.lineWidth - (2.0 * configuration.inset)
        }

        var rect: CGRect {
            CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: size(width), height: size(height))
            )
        }

        var offset: CGSize {
            CGSize(
                width: origin(rect.origin.x, width, col),
                height: origin(rect.origin.y, height, row)
            )
        }

        func origin(_ start: CGFloat, _ increment: CGFloat, _ offset: Int) -> CGFloat {
            start
                + (increment * CGFloat(offset))
                + self.configuration.lineWidth / 2.0
                + self.configuration.inset
        }
    }
}
public struct GridView_Previews: PreviewProvider {
    static let previewState = GridState()
    public static var previews: some View {
        GeometryReader { g in
            GridView(
                store: Store(
                    initialState: previewState,
                    reducer: gridReducer,
                    environment: GridEnvironment()
                ), fractionComplete: 0.0
            )
        }
    }
}
