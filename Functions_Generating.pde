void generateBoardAndPieces(){
  for(int i = 0; i < colLen; i++){
    for(int j = 0; j < rowLen; j++){
      int r = int(random(1, 7));
      while(r == prevID){
        r = int(random(1, 7));
      }
      board[i][j] = new Cell(i, j, new Piece(i, j, r));
      prevID = r;
      if (j < 2){
        board[i][j].hasPiece = false;
      }
    }
  }
}

void generateDispsFromCenter(){
  /*
  find the center of the playfield (might not be in a cell) using the colLen / 2 and (2 + rowLen) / 2. 
  make a new 2D array that stores the vertical and horizontal displacements of each piece.
  */
  
  int rows = max(rowLen - 2, 0);
  
  //resizes both arrays to an appropriate size
  cellVertiDispsFromCenter = new int[colLen][rows]; 
  cellHorizDispsFromCenter = new int[colLen][rows]; 
  
  int[] centerXYPos = {xStartPos + int(float(cellSize)*(float(colLen) * 0.5)), yStartPos + int(float(cellSize) * (2 + float(rowLen)) * 0.5)};
  for(int i = 0; i < colLen; i++){
    for(int j = 0; j < rows; j++){
      cellHorizDispsFromCenter[i][j] = centerXYPos[0] - (xStartPos + board[i][j + 2].x * cellSize + cellSize / 2);
      cellVertiDispsFromCenter[i][j] = centerXYPos[1] - (yStartPos + board[i][j + 2].y * cellSize + cellSize / 2);
      //println(i, j);
      //println("X", cellVertiDispsFromCenter[i][j], "Y", cellHorizDispsFromCenter[i][j]);
    }
  }
}

void generateLevel(int level){
  //note: cellSize must be a multiple of ten to prevent weird behaviour within the rest of the program
  switch(level){
    case 1:
      colLen = 5;
      rowLen = 7;
      cellSize = 100;
      targetScore = 50 * scoreIncrement;
      moveCount = 15;
      break;
    case 2:  
      colLen = 6;
      rowLen = 8;
      cellSize = 90;
      targetScore = 75 * scoreIncrement;
      moveCount = 18;
      break;
    case 3:
      colLen = 5;
      rowLen = 9;
      cellSize = 80;
      targetScore = 85 * scoreIncrement;
      moveCount = 22;
      break;
    case 4:
      colLen = 7;
      rowLen = 9;
      cellSize = 80;
      targetScore = 80 * scoreIncrement;
      moveCount = 20;
      break;
    case 5:
      colLen = 7;
      rowLen = 9;
      cellSize = 80;
      targetScore = 90 * scoreIncrement;
      moveCount = 20;
      break;
    case 6:
      colLen = 7;
      rowLen = 9;
      cellSize = 80;
      targetScore = 75 * scoreIncrement;
      moveCount = 18;
      break;
    case 7:
      colLen = 7;
      rowLen = 12;
      cellSize = 60;
      targetScore = 100 * scoreIncrement;
      moveCount  = 20;
      break;
    case 8:
      colLen = 9;
      rowLen = 13;
      cellSize = 60;
      targetScore = 115 * scoreIncrement;
      moveCount = 23;
      break;
    case 9:
      colLen = 10;
      rowLen = 13;
      cellSize = 60;
      targetScore = 135 * scoreIncrement;
      moveCount = 25;
      break;
    default:
      colLen = rowLen = 0;
      cellSize = 0;
      targetScore = -1;
      moveCount = -1;
      playerScore = -1;
      return;
  }
  //calculates the starting x and y position according to the current board size
  //they both take the center of the playfield as the reference point (700, 350) 
  //then they count the cols and rows needed to shift by
  xStartPos = width * 2/3 - int(float(colLen) / 2.0 * cellSize);
  yStartPos = height / 2 - int((2 + rowLen) / 2.0 * cellSize);
  shrinkLimit = cellSize * 3 / 10;
  shrinkRate = float(cellSize) / 40;
  positiveDisp = cellSize / 10;
  negativeDisp = -1 * positiveDisp;
  board = new Cell[colLen][rowLen];
  playerScore = 0;
}

void generateHoles(int level){
  int bottomY = 2;
  switch(level){
    case 2:
      for(int idx = 2; idx <= 3; idx++){
        board[idx][bottomY].disableCell();
        board[idx][rowLen - 1].disableCell();
        board[0][bottomY + idx].disableCell();
        board[colLen - 1][bottomY + idx].disableCell();
      }
      break;
    case 3:
      for(int j = 0; j < rowLen; j++){
        if(j == (bottomY + rowLen) / 2){
          continue;
        }
        board[2][j].disableCell();
      }
      break;
    case 4:
      for(int idx = 2; idx <= 4; idx++){
        board[idx][bottomY].disableCell();
        board[idx][rowLen - 1].disableCell();
        board[0][bottomY + idx].disableCell();
        board[colLen - 1][bottomY + idx].disableCell();
      }
      board[3][bottomY + 1].disableCell();
      board[3][rowLen - 2].disableCell();
      board[1][bottomY + 3].disableCell();
      board[colLen - 2][bottomY + 3].disableCell();
      break;
    case 5:
      int[] cols = {0, colLen/2, colLen - 1};
      for(int idx = 0; idx < cols.length; idx++){
        board[cols[idx]][bottomY].disableCell();
        board[cols[idx]][(bottomY + rowLen)/2].disableCell();
        board[cols[idx]][rowLen - 1].disableCell();
      }
      break;
    case 6:
      for(int idx = 0; idx <= 2; idx++){
        board[idx][bottomY + 2 - idx].disableCell();
        board[colLen - 1 - idx][bottomY + 2 - idx].disableCell();
        board[idx][rowLen - 3 + idx].disableCell();
        board[colLen - 1 - idx][rowLen - 3 + idx].disableCell();
      }
      board[3][(bottomY + rowLen) / 2].disableCell();
      break;
    case 7:
      for(int j = bottomY + 5; j < rowLen; j++){
        board[0][j].disableCell();
        board[colLen - 1][j].disableCell();
        if(j >= bottomY + 7){
          board[1][j].disableCell();
          board[colLen - 2][j].disableCell();
        }
      }
      board[2][rowLen - 1].disableCell();
      board[4][rowLen - 1].disableCell();
      break;
    case 8:
      for(int j = bottomY + 2; j < rowLen - 2; j++){
        board[0][j].disableCell();
        board[colLen - 1][j].disableCell();
        if(j >= bottomY + 3 && j < rowLen - 3){
          board[1][j].disableCell();
          board[colLen - 2][j].disableCell();
        }
        if(j >= bottomY + 4 && j < rowLen - 4){
          board[2][j].disableCell();
          board[colLen - 3][j].disableCell();
        }
        if(j >= bottomY + 5 && j < rowLen - 5){
          board[3][j].disableCell();
          board[colLen - 4][j].disableCell();
        }
      }
      break;
    case 9:
      for(int i = 0; i < colLen; i++){
        if(i < 4 || i > colLen - 5){
          board[i][bottomY].disableCell();
          board[i][bottomY + 4].disableCell();
          board[i][rowLen - 1].disableCell();
          board[i][rowLen - 2].disableCell();
        }
        if(i < 3 || i > colLen - 4){
          board[i][bottomY + 1].disableCell();
          board[i][bottomY + 5].disableCell();
          
        }
        if(i < 2 || i > colLen - 3){
          board[i][bottomY + 2].disableCell();
          board[i][bottomY + 6].disableCell();
        }
        if(i < 1 || i > colLen - 2){
          board[i][bottomY + 3].disableCell();
          board[i][bottomY + 7].disableCell();
        }
      }
      break;
    default:
  }
}
