//
//  Maze.swift
//  Maze
//
//  Created by Toma Alexandru on 14/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let DEFAULT_START_NODE: Tile = Tile(row: 1, column: 1)
// top, right, bottom, left
let NEIGHBOURS_VECTOR: [(i: Int, j: Int)] = [(-1, 0), (0, 1), (1, 0), (0, -1)]
let DEFAULT_MAZE_COLOR = UIColor.white
let DEFAULT_MAZE_LOOPS = 5

enum Orientation: Int {
    case top = 0, right, bottom, left
    
    func isHorizontal() -> Bool {
        return self == Orientation.top || self == Orientation.bottom
    }
    
    static func getOrientation(_ node1: Tile, node2: Tile) -> Orientation {
        for q in 0..<NEIGHBOURS_VECTOR.count {
            if node1.row + NEIGHBOURS_VECTOR[q].i == node2.row &&
                node1.column + NEIGHBOURS_VECTOR[q].j == node2.column {
                switch q {
                case 0: return Orientation.top
                case 1: return Orientation.right
                case 2: return Orientation.bottom
                default: return Orientation.left
                }
            }
        }
        
        fatalError("Orientation: No case matched \(node1) \(node2)")
    }
}

class Matrix<T> {
    let rows: Int
    let columns: Int
    var grid: [T]
    
    init(rows: Int, columns: Int, repeatedValue: T) {
        self.rows = rows + 2
        self.columns = columns + 2
        grid = [T](repeating: repeatedValue, count: rows * columns)
    }
    
    func getElementIndex(_ row: Int, column: Int) -> Int {
        return row * columns + column
    }
    
    func printElements() {
        for i in 0..<rows {
            for j in 0..<columns {
                print(self[i, j], terminator: " ")
            }
            print()
        }
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            return grid[getElementIndex(row, column: column)]
        }
        
        set {
            grid[getElementIndex(row, column: column)] = newValue
        }
    }
}

class MazeGenerator {
    // SpriteKit functions ----------------------------------------------------------------
    // returns the mazeSprite
    static func getMazeSprite(configuration conf: MazeConfiguration,
                            maze: [Tile : Set<Tile>]) -> SKSpriteNode {
        let conf = getTrueConfiguration(conf)
        let mazeSprite = SKSpriteNode()
        mazeSprite.anchorPoint =  CGPoint(x: 0, y: 1)
        mazeSprite.color = DEFAULT_MAZE_COLOR
        mazeSprite.size = CGSize(width: CGFloat(conf.columns - 2) * (conf.blockSize.width + conf.wallThickness) + conf.wallThickness,
                                 height: CGFloat(conf.rows - 2) * (conf.blockSize.height + conf.wallThickness) + conf.wallThickness)
        mazeSprite.position = CGPoint(x: -(mazeSprite.frame.width / 2),
                                      y: mazeSprite.frame.height / 2)
        
        setGaps(conf, root: mazeSprite)
        setWalls(conf, maze: maze, root: mazeSprite)
        
        return mazeSprite
    }
    
    static fileprivate func setGaps(_ conf: MazeConfiguration, root: SKNode) {
        for i in 1..<conf.rows {
            for j in 1..<conf.columns {
                let gap = SKSpriteNode()
                var pos = conf.getTilePosition(Tile(row: i, column: j))
                
                pos.x -= conf.wallThickness
                pos.y += conf.wallThickness
                
                gap.color = UIColor.black
                gap.size = CGSize(width: conf.wallThickness, height: conf.wallThickness)
                gap.anchorPoint = CGPoint(x: 0, y: 1)
                gap.position = pos
                
                root.addChild(gap)
            }
        }
    }
    
    static fileprivate func setWalls(_ conf: MazeConfiguration, maze: [Tile : Set<Tile>], root: SKNode) {
        for i in 0..<conf.rows {
            for j in 0..<conf.columns {
                let node = Tile(row: i, column: j)
                let neighbours = getNeighbours(conf, node: node)
                
                guard let paths = maze[node] else {
                    fatalError("Missing path \(node)")
                }
                
                for neighbour in neighbours {
                    if !paths.contains(neighbour) {
                        putWall(conf, root: root, node1: node, node2: neighbour)
                    }
                }
            }
        }
    }
    
    static fileprivate func putWall(_ conf: MazeConfiguration, root: SKNode, node1: Tile, node2: Tile) {
        let orientation = Orientation.getOrientation(node1, node2: node2)
        let wall = SKSpriteNode()
        wall.name = "\(node1) \(node2)"
        wall.color = UIColor.black
        wall.size = CGSize(width: orientation.isHorizontal() ? conf.blockSize.width : conf.wallThickness,
                          height: orientation.isHorizontal() ? conf.wallThickness : conf.blockSize.height)
        wall.anchorPoint = CGPoint(x: 0, y: 1)
        
        var pos = conf.getTilePosition(node1)
        
        switch orientation {
        case .top:
            pos.y += conf.wallThickness
        case .right:
            pos.x += conf.blockSize.width
        case .bottom:
            pos.y -= conf.blockSize.height
        case .left:
            pos.x -= conf.wallThickness
        }
        
        wall.position = pos
        
        root.addChild(wall)
    }
    
    // AUX functions ----------------------------------------------------------------
    static fileprivate func getTrueConfiguration(_ conf: MazeConfiguration) -> MazeConfiguration {
        return MazeConfiguration(rows: conf.rows + 2, columns: conf.columns + 2, blockSize: conf.blockSize, wallThickness: conf.wallThickness, playerStartTile: conf.playerStartTile, exitTile: conf.exitTile)
    }
    
    static fileprivate func getNeighbours(_ conf: MazeConfiguration, node: Tile) -> Set<Tile> {
        var neighbours = Set<Tile>()
        
        for q in 0..<NEIGHBOURS_VECTOR.count {
            let row = node.row + NEIGHBOURS_VECTOR[q].i
            let column = node.column + NEIGHBOURS_VECTOR[q].j
            
            if isNodeValid(conf, node: Tile(row: row, column: column)) {
                neighbours.insert(Tile(row: row, column: column))
            }
        }
        
        return neighbours
    }
    
    static fileprivate func isNodeValid(_ conf: MazeConfiguration, node: Tile) -> Bool {
        return node.row >= 1 && node.row < conf.rows - 1 &&
            node.column >= 1 && node.column < conf.columns - 1
    }
    
    // Maze Generation functions ----------------------------------------------------------------
    // returns new generated maze
    static func generateNewMaze(configuration conf: MazeConfiguration) -> [Tile : Set<Tile>] {
        let conf = getTrueConfiguration(conf)
        var maze = generateFullGraph(conf)
        maze = randomDFS(conf, maze: maze, startNode: DEFAULT_START_NODE)
        // insertLoops(conf, maze: maze)
        return maze
    }
    
    static fileprivate func insertLoops(_ conf: MazeConfiguration, maze: [Tile : Set<Tile>]) {
        func isBounds(_ tile: Tile) -> Bool {
            return tile.row == 0 ||
                    tile.column == 0 ||
                    tile.row == conf.rows - 1 ||
                    tile.column == conf.columns - 1
        }
        
        func returnByIndex(_ index: Int) -> Tile {
            for (i, tile) in maze.enumerated() {
                if i == index {
                    return tile.0
                }
            }
            return Tile(row: conf.rows / 2, column: conf.columns / 2)
        }
        
        for _ in 0..<DEFAULT_MAZE_LOOPS {
            var tile: Tile = Tile(row: 0, column: 0)
            while isBounds(tile) {
                let randomIndex = Int(arc4random_uniform(UInt32(maze.count)))
                tile = returnByIndex(randomIndex)
            }
        }
    }
    
    static fileprivate func generateFullGraph(_ conf: MazeConfiguration) -> [Tile : Set<Tile>] {
        var maze: [Tile : Set<Tile>] = [:]
        for i in 1..<(conf.rows - 1) {
            for j in 1..<(conf.columns - 1) {
                let node = Tile(row: i, column: j)
                maze[node] = getNeighbours(conf, node: node)
            }
        }
        return maze
    }
    
    static fileprivate func randomDFS(_ conf: MazeConfiguration, maze: [Tile : Set<Tile>], startNode: Tile) -> [Tile: Set<Tile>] {
        var visited = Set<Tile>()
        let visit = {(tile: Tile) in visited.insert(tile)}
        var stack: [Tile] = []
        var result: [Tile: Set<Tile>] = [:]
        let insert = {(tile1: Tile, tile2: Tile) in
                        result[tile1]?.insert(tile2)
                        result[tile2]?.insert(tile1)}
        
        for i in 0..<conf.rows {
            for j in 0..<conf.columns {
                result[Tile(row: i, column: j)] = []
            }
        }
        
        visit(startNode)
        stack.append(startNode)
        
        while stack.count != 0 {
            guard let node = stack.last else {
                fatalError("Stack Empty")
            }
            
            guard let nodes = maze[node] else {
                fatalError("Missing \(node) entry in maze dictionary")
            }
            
            var unvisited = [Tile]()
            
            for n in nodes {
                if !visited.contains(n) {
                    unvisited.append(n)
                }
            }
            
            if unvisited != [] {
                // just get array form of Set
                let nextNode = unvisited[Int(arc4random_uniform(UInt32(unvisited.count)))]
                visit(nextNode)
                insert(node, nextNode)
                stack.append(nextNode)
            } else {
                stack.popLast()
            }
        }
        
        return result
    }
    
    // Debug functions ----------------------------------------------------------------
    static func printMaze(_ conf: MazeConfiguration, maze: [Tile : Set<Tile>]) {
        let conf = getTrueConfiguration(conf)
        for i in 0..<conf.rows {
            for j in 0..<conf.columns {
                print("(\(i), \(j)) -> \(maze[Tile(row: i, column: j)])")
            }
        }
    }
}
