import std/[ sequtils, strutils, sets, terminal ]

const FOLD_OP_START = "fold along ".len()

type
    Point = tuple[x: int, y: int]
    FoldOp = tuple[axis: char, val: int]

proc fold(points: var HashSet[Point], width, height: var int, op: FoldOp) =
    var newPoints = initHashSet[Point](points.len())
    case op.axis:
    of 'x':
        for p in points.items:
            let np = (op.val - abs(p.x - op.val), p.y)
            newPoints.incl(np)
        width = op.val
    of 'y':
        for p in points.items:
            let np = (p.x, op.val - abs(p.y - op.val))
            newPoints.incl(np)
        height = op.val
    else: return
    points = newPoints

proc printArea(points: var HashSet[Point], width, height: int) =
    when defined(print):
        for y in 0..<height:
            for x in 0..<width:
                if points.contains((x, y)):
                    stdout.styledWrite(fgRed, "■")
                else:
                    stdout.styledWrite(fgWhite, ".")
            stdout.styledWrite("\n")
        echo "=".repeat(width)

proc solve() =
    var
        points = initHashSet[Point]()
        fold_ops = newSeqOfCap[FoldOp](32)
        width = 0
        height = 0

    block collectInput:
        let file = open("input.txt")
        defer: file.close()

        var readMode = 0
        while not file.endOfFile():
            var line = file.readLine()
            if line.len() < 1:
                readMode = 1
            else:
                case readMode
                of 0: # Points
                    let dot = line.split(',').map(parseInt)
                    points.incl((dot[0], dot[1]))
                of 1: # Folds
                    let op = line[FOLD_OP_START..^1].split('=')
                    fold_ops.add((op[0][0], parseInt(op[1])))
                else:
                    break

    when defined(p1):
        fold(points, width, height, fold_ops[0])
        printArea(points, width, height)

        var sum = 0
        for i in 0..<(width * height):
            if area[i] > 0: sum += 1
        echo "Amount of dots: ", sum

    when defined(p2):
        for i in 0..<fold_ops.len():
            fold(points, width, height, fold_ops[i])
        printArea(points, width, height)

when isMainModule:
    solve()
