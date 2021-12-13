import std/[ sequtils, strutils, terminal ]

type
    Point = tuple[x: int, y: int]
    FoldOp = tuple[axis: char, val: int]

const FOLD_OP_START = "fold along ".len()

var
    area: array[1024 * 8192, uint8] # 8mb of RAM
    fold_ops = newSeqOfCap[FoldOp](32)
    width = 0
    height = 0

proc fold(op: FoldOp) =
    case op.axis:
    of 'x':
        let width2 = min(width - op.val, op.val)
        let length = width2 * height
        var proj = newSeq[uint8](length)
        for i in 0..<length:
            let x1 = (op.val - 1) - (i mod width2)
            let x2 = (op.val + 1) + (i mod width2)
            let y = i div width2
            proj[x1 + (y * width2)] = area[x1 + (y * width)] + area[x2 + (y * width)]
        width = op.val
        for i,v in proj: area[i] = v
    of 'y':
        let height2 = min(height - op.val, op.val)
        let length = width * height2
        for i in 0..<length:
            let x = (width - 1) - (i mod width)
            let y1 = (i div width) * width
            let y2 = (op.val + (height2 - i div width)) * width
            area[x + y1] += area[x + y2]
        height = op.val
    else: return

proc printArea() =
    when defined(print):
        for y in 0..<height:
            for x in 0..<width:
                let val = area[x + (y * width)]
                if val > 0:
                    stdout.styledWrite(fgRed, "■")
                else:
                    stdout.styledWrite(fgWhite, ".")
            stdout.styledWrite("\n")
        echo "=".repeat(width)

proc solve() =
    block collectInput:
        var dots = newSeqOfCap[Point](2048)
        var readMode = 0
        let file = open("input.txt")
        defer: file.close()

        while not file.endOfFile():
            var line = file.readLine()
            if line.len() < 1:
                readMode = 1
            else:
                case readMode
                of 0: # Points
                    let dot = line.split(',').map(parseInt)
                    if width <= dot[0]: width = dot[0] + 1
                    if height <= dot[1]: height = dot[1] + 1
                    dots.add((dot[0], dot[1]))
                of 1: # Folds
                    let op = line[FOLD_OP_START..^1].split('=')
                    fold_ops.add((op[0][0], parseInt(op[1])))
                else:
                    break
        for dot in dots:
            area[dot.x + (dot.y * width)] = 1

    when defined(p1):
        fold(fold_ops[0])
        printArea()

        var sum = 0
        for i in 0..<(width * height):
            if area[i] > 0: sum += 1
        echo "Amount of dots: ", sum

    when defined(p2):
        for i in 0..<fold_ops.len():
            fold(fold_ops[i])
        printArea()

when isMainModule:
    solve()
