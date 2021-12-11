import std/sequtils

type Point = tuple[x: int, y: int]
proc `+`*(a, b: Point): Point = return (a.x + b.x, a.y + b.y)

const INPUT = "input.txt"
const GRID_W = 10
const GRID_H = 10
const GRID_LEN = GRID_W * GRID_H
const STEPS = 1000
const adjacent: array[8, Point] = [ (0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1) ]

proc printf*(format: cstring): cint {.importc, varargs, discardable, header: "<stdio.h>".}
proc idxXY(x: int, y: int): int = return x + (y * GRID_W)

proc collect_nearby(neighbours: var seq[int], grid: seq[int], p: Point): var seq[int] =
    neighbours.setLen(0)
    for a in adjacent:
        let np = p + a
        if np.x >= 0 and np.x < GRID_W and
           np.y >= 0 and np.y < GRID_H:
            let ni = idxXY(np.x, np.y)
            if grid[ni] > 0:
                neighbours.add(ni)
    return neighbours

proc try_flash(grid: var seq[int], stack: var seq[Point], flashes: var uint64, i: int) =
    let o = addr grid[i]
    if o[] >= 9:
        stack.add((i mod GRID_W, i div GRID_W))
        flashes += 1
        o[] = 0
    else:
        o[] += 1

proc solve() =
    var
        grid = newSeqOfCap[int](GRID_LEN)
        stack = newSeqOfCap[Point](GRID_LEN)
        neighbours = newSeqOfCap[int](adjacent.len())
        sum = 0
        flashes: uint64 = 0
        syncstep = -1

    for line in readLines(INPUT, GRID_H):
        line.apply(proc (c: char) = grid.add(c.int - '0'.int))

    for step in 0..<STEPS:
        sum = 0
        for i,_ in grid:
            sum += grid[i]
            try_flash(grid, stack, flashes, i)

        while stack.len() > 0:
            for n in collect_nearby(neighbours, grid, stack.pop()):
                try_flash(grid, stack, flashes, n)


        when defined(print):
            for y in 0..<GRID_H:
                for x in 0..<GRID_W:
                    let v = grid[idxXY(x, y)]
                    if v == 0:
                        printf("\u001b[31m%d\u001b[0m ", v)
                    else:
                        printf("%d ", v)
                printf("\n")
            printf("=============================================\n")

        if syncstep < 0 and sum == 0:
            syncstep = step
            break;

    echo "Total flashes:", flashes, ", syncstep:", syncstep

when isMainModule:
    solve()
