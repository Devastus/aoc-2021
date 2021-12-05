import std/[sequtils, strutils, sugar, math]
import nimPNG

const MAP_WIDTH = 1000
const MAP_HEIGHT = 1000
const MAP_LENGTH = MAP_WIDTH * MAP_HEIGHT
const POINT_SEQ_CAP = 2048

proc printf*(format: cstring): cint {.importc, varargs, discardable, header: "<stdio.h>".}

type Map = array[MAP_LENGTH, uint8]
type Vec2 = tuple[x: int, y: int]

proc `+`(a: Vec2, b: Vec2): Vec2 {.inline.} =
    return (x: a.x + b.x, y: a.y + b.y)
proc `-`(a: Vec2, b: Vec2): Vec2 {.inline.} =
    return (x: a.x - b.x, y: a.y - b.y)
proc sgn(a: Vec2): Vec2 {.inline.} =
    return (x: sgn(a.x), y: sgn(a.y))

proc parsePoint(point_str: string): Vec2 =
    let values_str: seq[string] = point_str.split(',')
    return (x: parseInt(values_str[0]), y: parseInt(values_str[1]))

proc drawMap(vent_map: ptr Map, highest: uint8) =
    var pixels = newStringOfCap(MAP_LENGTH)
    vent_map[].apply((x: uint8) => pixels.add(char(uint8((float32(x) / float32(highest)) * 255))))
    discard savePNG("map.png", pixels, LCT_GREY, 8, MAP_WIDTH, MAP_HEIGHT)

proc e02(vent_map: ptr Map, p1: Vec2, p2: Vec2, highest: var uint8, overlaps_total: var int) =
    let diff = p2 - p1
    let dir = diff.sgn()
    var pos = p1

    when defined(debugPrint):
        echo "  - ", dir

    while true:
        let spot_idx = pos.x + (pos.y * MAP_WIDTH)
        let spot: ptr uint8 = addr vent_map[spot_idx]
        spot[] += 1

        when defined(debugPrint):
            echo "    - ", pos, ", ", spot[]

        if spot[] == 2:
            overlaps_total += 1
        if spot[] > highest:
            highest = spot[]
        if pos.x != p2.x or pos.y != p2.y:
            pos = pos + dir
        else:
            break

proc e01(vent_map: ptr Map, p1: Vec2, p2: Vec2, highest: var uint8, overlaps_total: var int) =
    if p1.x == p2.x or p1.y == p2.y:
        e02(vent_map, p1, p2, highest, overlaps_total)

proc eval() =
    var vent_map = cast[ptr Map](alloc0(sizeof Map))
    var points = newSeqOfCap[Vec2](POINT_SEQ_CAP)
    var overlaps_total = 0
    var highest = 0'u8

    block collectInput:
        let file = open("input.txt")
        defer: file.close()

        while not file.endOfFile():
            let line = file.readLine()
            points.add(line.strip().split(" -> ").map(parsePoint))

    block layoutMap:
        var i = 0
        while i < points.len():
            let p1 = points[i]
            let p2 = points[i + 1]

            when defined(debugPrint):
                echo "#", i, " ", p1, " -> ", p2

            when defined(entry01):
                # Entry 01: Consider only horiz/vert lines
                e01(vent_map, p1, p2, highest, overlaps_total)
            else:
                # Entry 02: Consider also diagonals
                e02(vent_map, p1, p2, highest, overlaps_total)

            i += 2

    echo "Overlaps: ", overlaps_total, ", Highest: ", highest

    when defined(drawmap):
        drawMap(vent_map, highest)

    dealloc(vent_map)

when isMainModule:
    eval()
