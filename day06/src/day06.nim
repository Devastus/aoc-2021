import std/[sequtils, strutils, sugar]

const INPUT = "input.txt"

# Entry 01: naive
when defined(entry01):
    block entry01:
        var fishes = newSeqOfCap[int](65535)
        for line in open(INPUT).lines:
            fishes.add(line.split(',').map((x) => parseInt(x)))

        for day in 1..80:
            for i in 0..<fishes.len():
                if fishes[i] < 1:
                    fishes.add(8)
                    fishes[i] = 6
                else:
                    fishes[i] -= 1
        echo "Entry #1 - Total fish: ", fishes.len()

# Entry 02: optimized
when defined(entry02):
    block entry02:
        var fishes: array[9, uint64]
        open(INPUT).readLine.split(',').map((x) => parseUint(x).uint64)
                                       .apply(proc (x: uint64) = fishes[x] += 1)
        for day in 1..256:
            let temp = fishes[0]
            for i in 0..7:
                fishes[i] = fishes[i + 1]
            fishes[8] = 0
            if temp > 0:
                fishes[6] += temp
                fishes[8] += temp
        echo "Entry #2 - Total fish: ", fishes.foldl(a + b)
