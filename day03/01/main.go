package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	file, err := os.Open("../input.txt")
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	fileLen := 0
	bits := [12]int{0}
	{
		defer file.Close()
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			for i := 0; i < 12; i++ {
				bits[11-i] += int(line[i] - '0') // swap endianness
			}
			fileLen += 1
		}

		if err := scanner.Err(); err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
	}

	gamma := 0
	epsilon := 0
	for i := 0; i < 12; i++ {
		bit := bits[i]
		div := int(float32(bit)/float32(fileLen) + 0.5) // quick round to zero or one
		gamma |= div << i
		epsilon |= (1 - div) << i
	}

	result := gamma * epsilon

	fmt.Println("Gamma:", strconv.FormatInt(int64(gamma), 2), ", Epsilon:", strconv.FormatInt(int64(epsilon), 2), ", Result:", result)
}
