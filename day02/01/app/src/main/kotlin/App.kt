import java.io.File

fun main() {
    var pos = 0
    var depth = 0

    File("src/main/resources/input.txt").forEachLine {
        val spl = it.split(" ")
        val value = Integer.parseInt(spl[1])
        when(spl[0]) {
            "forward" -> pos += value
            "up" -> depth -= value
            "down" -> depth += value
        }
    }

    println("position: ${pos}, depth: ${depth}, multiplied: ${pos * depth}")
}
