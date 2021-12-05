import std/[sequtils, strutils, sugar, math]

var vent_map: array[1000 * 1000, int]
var overlaps = 0
for line in open("input.txt").lines:
    var points = line.strip().split(" -> ").map((x) => x.split(',').map((j) => parseInt(j)))
    while true:
        vent_map[points[0][0] + (points[0][1] * 1000)] += 1
        if vent_map[points[0][0] + (points[0][1] * 1000)] == 2:
            overlaps += 1
        if points[0][0] != points[1][0] or points[0][1] != points[1][1]:
            points[0][0] += (points[1][0] - points[0][0]).sgn()
            points[0][1] += (points[1][1] - points[0][1]).sgn()
        else:
            break
echo "Overlaps: ", overlaps
