import std/[ sequtils, strutils, strformat, tables, terminal, sugar ]

type
    Node {.acyclic.} = object
        id: int
        visited: int
        flags: uint8
        next {.cursor.}: seq[ptr Node]
    NodeLink {.acyclic.} = tuple[n: ptr Node, l_idx: int]

proc solve() =
    var
        nodes = newSeqOfCap[Node](128)
        stack = newSeqOfCap[NodeLink](256)
        paths = newSeqOfCap[seq[int]](16384)
        most_visited = 0

    block collectInput:
        var nodeMap = initTable[string, int]()
        let file = open("input.txt")
        defer: file.close()

        while not file.endOfFile():
            let link = file.readLine().split('-')
            var ln: array[2, ptr Node]
            for i,l in link:
                if not nodeMap.contains(l):
                    let ni = nodes.len()
                    let flags: uint8 = (if not l[0].isLowerAscii(): 1'u8 else: 0'u8) or
                                       (if l == "start": 2'u8 else: 0'u8) or
                                       (if l == "end": 4'u8 else: 0'u8)
                    nodes.add(Node(id: ni, flags: flags))
                    nodeMap.add(l, ni)
                ln[i] = addr nodes[nodeMap[l]]
            ln[0].next.add(ln[1])
            ln[1].next.add(ln[0])

        stack.add((addr nodes[nodeMap["start"]], 0))

    while stack.len() > 0:
        block nodeEval:
            let ln = addr stack[stack.high()]
            # We are at the end of a path
            if (ln[].n[].flags and 4) > 0:
                paths.add(stack.map((x) => x.n[].id))
            # Eval next nodes
            else:
                while ln[].l_idx < ln[].n[].next.len():
                    let next = ln[].n[].next[ln[].l_idx]
                    if (next[].flags and 1) < 1:
                        if (next[].flags and 2) > 0 or
                           (next[].visited > 0 and most_visited >= 2):
                            ln[].l_idx += 1
                            continue
                        next[].visited += 1
                        if  next[].visited > most_visited:
                            most_visited = next[].visited
                    stack.add((next, 0))
                    ln[].l_idx += 1
                    break nodeEval

            if ln[].n[].visited == most_visited:
                most_visited -= 1
            ln[].n[].visited -= 1
            discard stack.pop()

    when defined(print):
        for path in paths:
            for i in path:
                let n = nodes[i]
                if (n.flags and 1'u8) > 0:
                    stdout.styledWrite(fgYellow, $nodes[i].id, " ")
                elif (n.flags and 2'u8) > 0:
                    stdout.styledWrite(fgRed, $nodes[i].id, " ")
                elif (n.flags and 4'u8) > 0:
                    stdout.styledWrite(fgGreen, $nodes[i].id, " ")
                else:
                    stdout.styledWrite(fgDefault, $nodes[i].id, " ")
            stdout.styledWrite("\n")
    echo "Unique path count: ", paths.len()

when isMainModule:
    solve()
