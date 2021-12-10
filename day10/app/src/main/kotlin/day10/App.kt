package day10

import java.io.File
import java.util.ArrayDeque

val INPUT = "input.txt"

fun old() {
    val scoreMap = mapOf(')' to 3, ']' to 57, '}' to 1197, '>' to 25137)
    val chars: CharSequence = "([{<)]}>"
    val charMap = mapOf('(' to 0, ')' to 4,
                        '[' to 1, ']' to 5,
                        '{' to 2, '}' to 6,
                        '<' to 3, '>' to 7)
    var syntaxScore = 0
    var complScores = ArrayList<Long>()
    var stack = ArrayDeque<Int>()
    File(INPUT).forEachLine {
        stack.clear()
        var complScore: Long = 0
        var discard = false
        for (char in it) {
            var value = charMap.getValue(char)
            when (value) {
                in 0..3 -> {
                    stack.push(value)
                    print(char)
                }
                in 4..7 -> {
                    var eval = stack.pop()
                    if (eval - (value - 4) != 0) {
                        syntaxScore += scoreMap.getValue(char)
                        discard = true
                        print("\u001b[31m" + char + "\u001b[0m")
                        break;
                    }
                    else {
                        print(char)
                    }
                }
            }
        }

        if (!discard) {
            val len = stack.size
            for (i in 0..(len - 1)) {
                val value = (stack.pop() + 4)
                val char = chars[value]
                complScore = (complScore * 5) + (value - 3).toLong()
                print("\u001b[32m" + char + "\u001b[0m")
            }
            complScores.add(complScore)
        }
        print('\n')
    }
    complScores.sort()
    println("Syntax score: ${syntaxScore}")
    println("Mid score: ${complScores[(complScores.size / 2.0).toInt()]}")
}

fun new() {
    val scoreMap = mapOf(')' to 3, ']' to 57, '}' to 1197, '>' to 25137)
    val pairs = mapOf('(' to ')', '[' to ']', '{' to '}', '<' to '>')
    val pairKeys = pairs.keys
    var syntaxScore = 0
    var complScores = mutableListOf<Long>()
    var stack = mutableListOf<Char>()
    File(INPUT).forEachLine { line ->
        stack.clear()
        for (char in line) {
            if (char in pairKeys) { stack.add(char) }
            else if (char == pairs[stack.lastOrNull()]) { stack.removeLast() }
            else { syntaxScore += scoreMap[char]!!; stack.clear(); break }
        }
        if (stack.size > 0) complScores.add(stack.reversed().map { pairKeys.indexOf(it) + 1 }.fold(0L) { acc, x -> acc * 5 + x})
    }
    println("Syntax score: ${syntaxScore}, Mid score: ${complScores.sorted()[(complScores.size / 2.0).toInt()]}")
}

fun main() {
    old()
    println("===================================")
    new()
}
