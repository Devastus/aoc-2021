import std/[sequtils, sugar]
import strutils
import strformat

const BOARD_SIZE = 5
const BOARD_LENGTH = BOARD_SIZE * BOARD_SIZE

type Board = object
    numbers: array[BOARD_LENGTH, int]
    marks_x: array[BOARD_SIZE, int]
    marks_y: array[BOARD_SIZE, int]
    mark_flags: uint
    unmarked_sum: int
    position: int

proc printf*(format: cstring): cint {.importc, varargs, discardable, header: "<stdio.h>".}

proc printBoard(board: Board) =
    printf("==================================\n")
    for i in 0..<BOARD_LENGTH:
        let num    = board.numbers[i]
        let mask   = (1 shl i).uint
        let marked = (board.mark_flags and mask) == mask

        if marked == true:
            printf("[%d]\t", num)
        else:
            printf("%d\t", num)

        if i mod BOARD_SIZE == 4:
            printf("\n")
    printf("==================================\n")

proc eval() =
    # Persistent variables
    var first_board_idx  = -1
    var last_board_idx   = -1
    var first_win_number = 0
    var last_win_number  = 0
    var bingo_nums: seq[int]
    var boards: seq[Board]

    # Collect input into bingo numbers and boards
    block inputCollect:
        let file = open("input.txt", fmRead)
        defer: file.close()

        var curBoard    = -1
        var curBoardIdx = 0
        boards = newSeq[Board](100)
        bingo_nums = file.readLine().split(',').map((x: string) => parseInt(x))

        # Collect boards
        while not file.endOfFile():
            let line = file.readLine()

            if line.isEmptyOrWhitespace():
                boards.add(Board())
                curBoardIdx = 0
                curBoard += 1
            else:
                var board: ptr Board = addr boards[curBoard]
                for i in 0 ..< BOARD_SIZE:
                    let idx = i * 3
                    let num = parseInt(line[idx .. (idx + 1)].strip())
                    board.numbers[curBoardIdx] = num
                    board.unmarked_sum += num
                    board.position = -1
                    curBoardIdx += 1

    # Simulate rounds of bingo for all boards
    block simulateBingo:
        var bingo_round  = 0
        var max_rounds   = bingo_nums.len() div BOARD_SIZE
        var win_position = 0
        var round_nums: seq[int]

        while bingo_round < max_rounds:
            # Initialize round
            let round_idx = bingo_round * BOARD_SIZE
            round_nums = bingo_nums[round_idx ..< (round_idx + BOARD_SIZE)]

            for round_num in round_nums:
                for board_idx in 0 ..< boards.len():
                    # Skip boards that already have won (optimizable)
                    var board: ptr Board = addr boards[board_idx]
                    if board.position >= 0:
                        continue

                    for i in 0 ..< BOARD_LENGTH:
                        let num = board.numbers[i]

                        if num == round_num:
                            board.unmarked_sum -= num
                            board.mark_flags = board.mark_flags or (1 shl i).uint

                            # Map number to x/y planes to mark strips accordingly
                            let y = i mod BOARD_SIZE
                            let x = i div BOARD_SIZE
                            board.marks_x[x] += 1
                            board.marks_y[y] += 1

                            # We have a winner if current spot in plane is equal to board size
                            if (board.marks_x[x] >= BOARD_SIZE or
                                board.marks_y[y] >= BOARD_SIZE):
                                board.position = win_position
                                win_position += 1

                                # Track first and last boards
                                if first_board_idx < 0:
                                    first_board_idx = board_idx
                                    first_win_number = num
                                elif last_board_idx != board_idx:
                                    last_board_idx = board_idx
                                    last_win_number = num

            bingo_round += 1

    # Declare winner
    if first_board_idx < 0:
        echo "Failed to find a winning board"
        quit(1)

    let winning_board = boards[first_board_idx]
    echo(fmt "\nWinning board: #{first_board_idx}")
    printBoard(winning_board)
    echo(fmt "Winning number: {first_win_number}, Unmarked sum: {winning_board.unmarkedSum}")
    echo(fmt "Result: {winning_board.unmarkedSum * first_win_number}")

    # Declare loser
    if last_board_idx < 0:
        echo "Failed to find a losing board"
        quit(1)

    let losing_board = boards[last_board_idx]
    echo(fmt "\nLosing board: #{last_board_idx}")
    printBoard(losing_board)
    echo(fmt "Winning number: {last_win_number}, Unmarked sum: {losing_board.unmarkedSum}")
    echo(fmt "Result: {losing_board.unmarkedSum * last_win_number}")

when isMainModule:
    eval()
