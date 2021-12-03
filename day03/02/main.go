package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func getShiftedBit(num int, idx int) int {
	return (num & (1 << idx)) >> idx
}

func filterNums(nums []int, inverse bool) int {
	cur_bit_idx := 11 // Swap endianness
	cur_len := len(nums)

	for cur_len > 1 && cur_bit_idx >= 0 {
		bit_col_sum := 0

		// Sum bits in column
		for i := 0; i < cur_len; i++ {
			bit := getShiftedBit(nums[i], cur_bit_idx)
			bit_col_sum += bit
		}

		// Quick round division to 0 or 1 (or inverse of)
		bit_col_sum_div := int((float32(bit_col_sum) / float32(cur_len)) + 0.5)
		if inverse {
			bit_col_sum_div = 1 - bit_col_sum_div
		}

		// Remove all entries that don't match the div bit in column
		for i := cur_len - 1; i >= 0; i-- {
			bit := getShiftedBit(nums[i], cur_bit_idx)
			if bit != bit_col_sum_div {
				// Remove element (non-ordered)
				cur_len -= 1
				nums[i] = nums[cur_len]
				nums = nums[:cur_len]
			}
		}

		cur_bit_idx -= 1
	}

	if cur_len < 1 {
		log.Fatal("Filtering numbers produced an invalid result (no numbers left)")
		os.Exit(1)
	}

	return nums[0]
}

func main() {
	// Read in the numbers
	numbers := make([]int, 0, 1024)
	file_len := 0
	{
		file, err := os.Open("../input.txt")
		if err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			num, err := strconv.ParseInt(line, 2, 32)
			if err != nil {
				log.Fatal(err)
				os.Exit(1)
			}
			numbers = append(numbers, int(num))
			file_len += 1
		}

		if err := scanner.Err(); err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
	}

	nums_copy := make([]int, file_len)

	copy(nums_copy, numbers)
	oxygen := filterNums(nums_copy, false)

	copy(nums_copy, numbers)
	co2 := filterNums(nums_copy, true)

	result := oxygen * co2

	fmt.Println("oxygen - value:", oxygen, ", binary:", strconv.FormatInt(int64(oxygen), 2))
	fmt.Println("co2 - value:", co2, ", binary:", strconv.FormatInt(int64(co2), 2))
	fmt.Println("result (oxygen * co2):", result)
}
