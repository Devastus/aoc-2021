const fs = require("fs");

function idxXY(x, y, w) { return x + (y * w); }
function inBounds(x, y, w, h) { return x >= 0 && x < w && y >= 0 && y < h; }
function colored(color, txt) { return "\033[0;" + color + "m" + txt + "\u001b[0m"; }

const grid = [];
fs.readFileSync("input.txt", "UTF-8")
  .split(/\r?\n/)
  .filter((line) => line.length > 0)
  .map((line, i) => { grid[i] = line.split('').map((x) => { return {val: parseInt(x, 10)}; }); });
const grid_w = grid[0].length;
const grid_h = grid.length;

function nearby(x, y) {
    return [
        [x, y + 1],
        [x + 1, y],
        [x, y - 1],
        [x - 1, y],
    ].filter((it) => inBounds(it[0], it[1], grid_w, grid_h))
    .map((it) => { return {
        val: grid[it[1]][it[0]].val,
        x: it[0],
        y: it[1]
    }});
}

//////////////////////////////////////////////
// PART 1
//////////////////////////////////////////////

const lowest = [];
grid.forEach((row, y) => row.forEach((it, x) => {
    const near = nearby(x, y).filter((z) => z.val <= it.val);
    if (near.length < 1) {
        it.lowest = true;
        lowest.push({val: it.val, x, y});
    }
}))
let lowest_sum = 0;
lowest.forEach(x => lowest_sum += x.val + 1);

//////////////////////////////////////////////
// PART 2
//////////////////////////////////////////////

const basins = [];
const basin_stack = [];
lowest.forEach((_, idx) => {
    // Breadth-first search
    let point = lowest[idx];
    basins[idx] = { [idxXY(point.x, point.y, grid_w)]: point };
    while (point != undefined) {
        nearby(point.x, point.y)
            .filter((it) => {
                return basins[idx][idxXY(it.x, it.y, grid_w)] == undefined &&
                       it.val < 9 &&
                       it.val > point.val;
            })
            .map((it) => {
                basins[idx][idxXY(it.x, it.y, grid_w)] = it;
                basin_stack.push(it);
                grid[it.y][it.x].basin = true;
            });
        point = basin_stack.pop();
    }
});

const biggest = basins.map((row) => Object.keys(row).length).sort((a, b) => b -a).slice(0, 3);
const biggest_sum = biggest.reduce((acc, it) => acc * it);

//////////////////////////////////////////////
// PRINT
//////////////////////////////////////////////

let printed = ""
grid.forEach((row) => {
    row.forEach((it) => {
        if (it.lowest) {
            printed += colored(31, `${it.val} `);
        } else if (it.basin) {
            printed += colored(35, `${it.val} `);
        } else {
            printed += colored(37, `${it.val} `);
        }
    });
    printed += "\n";
});
console.log(printed);

console.log("Part 1:", lowest_sum);
console.log("Part 2:", biggest, biggest_sum);
