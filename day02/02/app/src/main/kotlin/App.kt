import java.io.File

fun main() {
    var aim = 0
    var pos = 0
    var depth = 0

    File("src/main/resources/input.txt").forEachLine {
        val spl = it.split(" ")
        val value = Integer.parseInt(spl[1])
        when(spl[0]) {
            "forward" -> {
                pos += value
                depth += (aim * value)
            }
            "up" -> aim -= value
            "down" -> aim += value
        }
    }

    println("position: ${pos}, depth: ${depth}, multiplied: ${pos * depth}")
}
