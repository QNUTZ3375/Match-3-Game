void fillEmptyCellsOutsidePlayField(){
  for(int i = 0; i < colLen; i++){
    for(int j = 0; j < 2; j++){
      board[i][j].currPiece.shrinkSize = 0;
      if(board[i][j].currPiece.pieceID == 0){
        int r = int(random(1, 7));
        while(r == prevID){
          r = int(random(1, 7));
        }
        board[i][j].currPiece.pieceID = r;
        prevID = r;
      }
    }
  }
}

//calculates the number of spaces within a continuous section of a row 
//(helps with the droppingPieces function to prevent weird behaviour i.e. moving diagonally before straight down)
int spacesInARow(int col, int row, int[] listOfHoles){
  int res = 0;
  //checks for all pieces in and above the row
  for(int j = row; j >= 2; j--){
    //checks if there is a hole within the contiguous range
    for(int k = 0; k < listOfHoles.length; k++){
      if (j == listOfHoles[k]){
        res++;
      }
    }
    //hits a border
    if(board[col][j].currPiece.pieceID == -1){
      break;
    }
    //hits an empty cell
    if(board[col][j].currPiece.pieceID == 0){
      res++;
    }
  }
  //checks for all pieces in and below the row
  for(int j = row; j < rowLen; j++){
    //checks if there is a hole within the contiguous range
    for(int k = 0; k < listOfHoles.length; k++){
      if (j == listOfHoles[k]){
        res++;
      }
    }
    //hits a border
    if(board[col][j].currPiece.pieceID == -1){
      break;
    }
    //hits an empty cell
    if(board[col][j].currPiece.pieceID == 0){
      res++;
    }
  }
  return res;
}

Cell[] droppingPieces = {}; //stores all the pieces currently dropping
int[][] droppingDisps = {}; //stores all the directions of the dropping pieces
boolean needsToDrop = false; //checks if there are pieces to drop
int dropCounter = 0; //sets the amount of times the dropping loop has to ocurr

void dropPieces(){
  dropCounter = cellSize / positiveDisp;
  boolean needToKeepLooping = true;
  //an array keeping track of the holes made when making movements (when a piece is moved in a row, a hole is made on that row)
  int[][] holesMade = new int[colLen][];
  for(int i = 0; i < holesMade.length; i++){
    holesMade[i] = new int[0];
  }
  /*  
  drop priority (chooses the first piece available):
  1. right above
  2. diagonally top left***
  3. diagonally top right***
  
  ***: has a condition where the row either to the left or right (depends on which direction it's taking from) 
  MUST be fully filled within the section that is directly next to the current piece it's being taken from 
  (rows separated by borders won't be considered), before allowing pieces to the left or right to take a piece within its column
  
  continuously loop doing the following:
  start from the top left of the board (go column by column). If the current piece is empty and the any 3 above are non-empty (and not going to move due to another empty piece),
  check if the piece is on the zeroth row. If it is, spawn a piece in it. 
  Delete the current piece and move the any of the three pieces above it according to the drop priority. 
  If a piece has moved in a current row, finish checking the current row, then restart from the top left.
  
  If the loop has reached the end and no pieces have moved at all, then break out of the loop.
  */

  //this double for loop gets all of the pieces that need to be moved in one cycle
  for(int i = 0; i < colLen; i++){
    int finalRow = 0;
    //start from the first row of the playfield to prevent a bug where it detects the first row outside the playfield, 
    //causing delays between drops (because the function returns with droppingPieces.length = 0 without it actually reaching the end of the board)
    for(int j = 2; j < rowLen; j++){
      finalRow = j;
      if(board[i][j].currPiece.pieceID != 0 || board[i][j].currPiece.isDropping){ 
        continue;
      }
      //checks if curr piece is an empty piece (not disabled) and isn't dropping
      needToKeepLooping = false; //disables the need to keep looping as a match is found
      for(; j >= 0; j--){ //keeps going up the rows until j = 0
        if(j == 0){
          if(board[i][j].currPiece.pieceID == 0){ //checks if the piece on the top row is empty and not disabled
            int r = int(random(1, 7));
            while(r == prevID){
              r = int(random(1, 7));
            }
            board[i][0].currPiece = new Piece(i, 0, r);
            prevID = r;
          }
        } else if(board[i][j].currPiece.pieceID != -1){ //checks if the current piece isn't disabled
          boolean foundPiece = false; //condition to check if a piece has been found for dropping
          
          //checks if the piece isn't dropping and isn't disabled
          if(board[i][j - 1].currPiece.pieceID != -1 && !board[i][j - 1].currPiece.isDropping){ 
            println(i, j, "E", spacesInARow(i, j, holesMade[i]));
            //checks if any holes were made in this row (meaning there is room to drop down into)
            if(spacesInARow(i, j, holesMade[i]) > 0){
              //needToKeepLooping = true;
              //appends the row into holesMade according to its column number
              holesMade[i] = Arrays.copyOf(holesMade[i], holesMade[i].length + 1);
              holesMade[i][holesMade[i].length - 1] = j;
              println("HI", i, j);
              //adds the current piece to droppingPieces
              droppingPieces = Arrays.copyOf(droppingPieces, droppingPieces.length + 1);
              droppingPieces[droppingPieces.length - 1] = board[i][j - 1];
              board[i][j - 1].currPiece.isDropping = true;
              
              //adds the direction of the current piece to droppingDisps
              droppingDisps = Arrays.copyOf(droppingDisps, droppingDisps.length + 1);
              droppingDisps[droppingDisps.length - 1] = new int[2];
              droppingDisps[droppingDisps.length - 1][0] = 0;
              droppingDisps[droppingDisps.length - 1][1] = positiveDisp;
              
              foundPiece = true;
            }
          }
          //check if the cell wanting the diagonal piece is within the playfield and hasn't taken a piece from the previous condition
          if(i > 0 && j >= 2 && !foundPiece){
            //checks if the piece isn't dropping and isn't disabled
            if(board[i - 1][j - 1].currPiece.pieceID != -1 && !board[i - 1][j - 1].currPiece.isDropping){ 
              //checks if there are any holes to the right or if the current row is full 
              if(spacesInARow(i - 1, j, holesMade[i - 1]) > 0 || spacesInARow(i, j, holesMade[i]) == 0){ 
                println(i, j, "B", board[i][j].currPiece.pieceID,  board[i][j - 1].currPiece.pieceID);
                needToKeepLooping = true;
              } else{
                println(i, j, "A");
                //appends the row into holesMade according to its column number
                holesMade[i - 1] = Arrays.copyOf(holesMade[i - 1], holesMade[i - 1].length + 1);
                holesMade[i - 1][holesMade[i - 1].length - 1] = j;
                //adds the current piece to droppingPieces
                droppingPieces = Arrays.copyOf(droppingPieces, droppingPieces.length + 1);
                droppingPieces[droppingPieces.length - 1] = board[i - 1][j - 1];
                board[i - 1][j - 1].currPiece.isDropping = true;
                
                //adds the direction of the current piece to droppingDisps
                droppingDisps = Arrays.copyOf(droppingDisps, droppingDisps.length + 1);
                droppingDisps[droppingDisps.length - 1] = new int[2];
                droppingDisps[droppingDisps.length - 1][0] = positiveDisp;
                droppingDisps[droppingDisps.length - 1][1] = positiveDisp;
                
                foundPiece = true;
                i--; //updates the i position so that the next piece checked matches the current match
              }
            }
          }
          //check if the cell wanting the diagonal piece is within the playfield and hasn't taken a piece from the previous two conditions
          if(i < colLen - 1 && j >= 2 && !foundPiece){ 
            //checks if the piece isn't dropping and isn't disabled
            if(board[i + 1][j - 1].currPiece.pieceID != -1 && !board[i + 1][j - 1].currPiece.isDropping){
              //checks if there are any holes to the left or if the current row is full
              if(spacesInARow(i + 1, j, holesMade[i + 1]) > 0 || spacesInARow(i, j, holesMade[i]) == 0){
                println(i, j, "C", spacesInARow(i + 1, j, holesMade[i + 1]), board[i][j].currPiece.pieceID);
                needToKeepLooping = true;
              } else{
                println(i, j, "A", spacesInARow(i + 1, j, holesMade[i + 1]), board[i][j].currPiece.pieceID);
                //appends the row into holesMade according to its column number
                holesMade[i + 1] = Arrays.copyOf(holesMade[i + 1], holesMade[i + 1].length + 1);
                holesMade[i + 1][holesMade[i + 1].length - 1] = j;
                //adds the current piece to droppingPieces
                droppingPieces = Arrays.copyOf(droppingPieces, droppingPieces.length + 1);
                droppingPieces[droppingPieces.length - 1] = board[i + 1][j - 1];
                board[i + 1][j - 1].currPiece.isDropping = true;
                
                //adds the direction of the current piece to droppingDisps
                droppingDisps = Arrays.copyOf(droppingDisps, droppingDisps.length + 1);
                droppingDisps[droppingDisps.length - 1] = new int[2];
                droppingDisps[droppingDisps.length - 1][0] = negativeDisp;
                droppingDisps[droppingDisps.length - 1][1] = positiveDisp;
                
                foundPiece = true;
                i++; //updates the i position so that the next piece checked matches the current match
              }
            }
          }
        }
      }
      break;
    }
    if(!needToKeepLooping){
      break; 
    } else if(i == colLen - 1 && finalRow == rowLen - 1){
      needsToDrop = false;
    }
  }
  for(int i = 0; i < droppingPieces.length; i++){
    println(droppingPieces[i].x, droppingPieces[i].y);
  }
}
