import std/[sequtils, strutils, math, sugar]

const INPUT = "input.txt"

# Entry: naive
when defined(e01):
    block e01:
        var
            values = open(INPUT).readLine.split(',').map(parseInt)
            highest = values[values.maxIndex()]
            res = newSeq[int64](highest + 1)
        for v in values:
            for h in 0..highest:
                let dist = abs(v - h)
                for f in 0..dist:
                    res[h] += f
        let ideal_idx = res.minIndex()
        echo "Entry #01 - Ideal position: ", ideal_idx, ", consumption: ", res[ideal_idx]

# Entry: close enough
when defined(e02):
    proc reduce*[T](s: seq[T], op: proc(acc: T, it: T): T): T =
        for it in s:
            result = op(result, it)
    proc count*[T](s: seq[T], op: proc(it: T): bool): int =
        for it in s:
            if op(it): result += 1

    block e02:
        var values = open(INPUT).readLine.split(',').map(parseInt)
        let avg = values.foldl(a + b) / values.len()
        let res = math.round(avg + (values.len() - 2 * (values.count((it) => it < avg.int))) / (2 * values.len())).int
        let consumption = values.reduce((acc, it) => (result = acc; for f in 1..abs(res - it): result += f))
        echo "Entry #02 - Ideal position: ", res, ", consumption: ", consumption
