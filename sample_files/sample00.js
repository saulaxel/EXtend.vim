const canvas = document.getElementById("myCanvas");
const ctx = canvas.getContext("2d");

function collisionDetection() {
    for (let c=0; c<grid.columns; c++) {
        for (let r=0; r<grid.rows; r++) {
            let b = bricks[c][r]
            if (b.status == 1) {
                if (x > b.x && x < b.x + brick.width && y > b.y && y <b.y + brick.height) {
                    dy = -dy
                    b.status = 0
                    status.score++
                    if (status.score == grid.rows * grid.columns) {
                        alert("YOU WIN, CONGRATS!")
                        document.location.reload()
                    }
                }
            }
        }
    }
}

draw();
