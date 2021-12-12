import std/[ sequtils, strutils, strformat, tables, terminal ]

const INPUT = "input.txt"

type
    Node = object
        id: string
        is_big: bool
        linked: seq[int]

var
    nodes = newSeqOfCap[Node](256)
    paths = newSeqOfCap[seq[int]](1024)
    node_stack = newSeqOfCap[int](256)
    link_stack = newSeqOfCap[int](256)
    special_node_ids = [ "start", "end" ]

proc combined() =
    when not defined(p1):
        var little_visited = newSeq[int](nodes.len())
    while node_stack.len() > 0:
        block nodeEval:
            let nnum = node_stack[node_stack.high()]
            let node = nodes[nnum]
            if node.id == special_node_ids[1]:
                var path = newSeqOfCap[int](node_stack.len())
                path.add(node_stack)
                paths.add(path)
            else:
                let link_idx = addr link_stack[link_stack.high()]
                while link_idx[] < node.linked.len():
                    let lnum = node.linked[link_idx[]]
                    let lnode = nodes[lnum]
                    if not lnode.is_big:
                        when not defined(p1):
                            if lnode.id == special_node_ids[0] or
                               (node_stack.contains(lnum) and little_visited.any(proc (x: int): bool = x >= 2)):
                                link_idx[] += 1
                                continue
                            little_visited[lnum] += 1
                        else:
                            if node_stack.contains(lnum):
                                link_idx[] += 1
                                continue
                    node_stack.add(lnum)
                    link_stack.add(0)
                    link_idx[] += 1
                    break nodeEval

            when not defined(p1):
                if not node.is_big:
                    little_visited[nnum] -= 1
            discard node_stack.pop()
            discard link_stack.pop()

proc solve() =
    block collectInput:
        var nodeMap = initTable[string, int]()
        let file = open(INPUT)
        defer: file.close()

        while not file.endOfFile():
            let link = file.readLine().split("-")
            var linkNodes: array[2, int]

            for i,node_id in link:
                if not nodeMap.contains(node_id):
                    nodes.add(Node(
                        id: node_id,
                        is_big: not node_id[0].isLowerAscii(),
                        linked: newSeqOfCap[int](32)))
                    nodeMap.add(node_id, nodes.high())
                linkNodes[i] = nodeMap[node_id]

            nodes[linkNodes[0]].linked.add(linkNodes[1])
            nodes[linkNodes[1]].linked.add(linkNodes[0])

        node_stack.add(nodeMap["start"])
        link_stack.add(0)

    combined()

    when defined(print):
        for path in paths:
            for i in path:
                stdout.styledWrite(nodes[i].id, " ")
            stdout.styledWrite("\n")
    echo "Unique path count: ", paths.len()

when isMainModule:
    solve()
