void updateSpecialClears(Piece currPiece, String type){
  specialClears = Arrays.copyOf(specialClears, specialClears.length + 1);
  specialClears[specialClears.length - 1] = new Piece[0];
  
  specialClearTypes = Arrays.copyOf(specialClearTypes, specialClearTypes.length + 1);
  specialClearTypes[specialClearTypes.length - 1] = type;

  if (type == "FIREWORK"){
    int[][] tempXYVals = {{currPiece.x - 1, currPiece.y - 1}, {currPiece.x, currPiece.y - 1}, {currPiece.x + 1, currPiece.y - 1},
                          {currPiece.x - 1, currPiece.y}    , {currPiece.x + 1, currPiece.y},
                          {currPiece.x - 1, currPiece.y + 1}, {currPiece.x, currPiece.y + 1}, {currPiece.x + 1, currPiece.y + 1}};
    int[] directions = {3, 1, 4, 2, 2, 4, 1, 3};
                          
    for(int i = 0; i < tempXYVals.length; i++){
      //checks if the xy coordinates are in bounds
      if (tempXYVals[i][0] >= 0 && tempXYVals[i][0] <= colLen - 1 && tempXYVals[i][1] >= 2 && tempXYVals[i][1] <= rowLen - 1){
        //checks if the current piece isn't empty or disabled
        if(board[tempXYVals[i][0]][tempXYVals[i][1]].currPiece.pieceID > 0){
          //appends the piece to specialClears
          specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
          specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = board[tempXYVals[i][0]][tempXYVals[i][1]].currPiece;
          board[tempXYVals[i][0]][tempXYVals[i][1]].currPiece.fireworkPos = directions[i];
        }
      }
    }
  } else if (type == "CROSS"){
    //adds all pieces in the same column as the piece (excluding the piece itself)
    for(int i = 0; i < colLen; i++){
      if(board[i][currPiece.y].currPiece.pieceID > 0 && i != currPiece.x){
        //appends the piece to specialClears
        specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
        specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = board[i][currPiece.y].currPiece;
        board[i][currPiece.y].currPiece.crossPos = 1;
      }
    }
    //adds all pieces in the same row as the piece (excluding the piece itself)
    for(int j = 2; j < rowLen; j++){
      if(board[currPiece.x][j].currPiece.pieceID > 0 && j != currPiece.y){
        //appends the piece to specialClears
        specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
        specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = board[currPiece.x][j].currPiece;
        board[currPiece.x][j].currPiece.crossPos = 2;
      }
    }
  } else if (type == "SPECIAL"){
    //appends all the pieces in the board with the same id as the current piece
    for(int i = 0; i < colLen; i++){
      for(int j = 2; j < rowLen; j++){
        if(board[i][j].currPiece.pieceID == currPiece.pieceID && board[i][j].currPiece != currPiece){
          //appends the piece to specialClears
          specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
          specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = board[i][j].currPiece;
          board[i][j].currPiece.specialVal = 1;
        }
      }
    }
  }
  //resets all of the current piece attributes and appends it to specialClears
  currPiece.hasFirework = false;
  currPiece.hasCross = false;
  currPiece.isSpecialPiece = false;
  specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
  specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = currPiece;
}

void shrinkPieces(Piece[] listOfPieces){
  boolean hasShrinked = false;
  for(int i = 0; i < listOfPieces.length; i++){
    listOfPieces[i].shrinkSize += shrinkRate;
    if(listOfPieces[i].shrinkSize >= shrinkLimit){
      listOfPieces[i].pieceID = 0;
      listOfPieces[i].fireworkPos = 0;
      listOfPieces[i].crossPos = 0;
      listOfPieces[i].specialVal = 0;
    }else{
      hasShrinked = true;
    }
  }
  if(!hasShrinked){
    for(int j = 0; j < result.length - 1; j++){
      result[j] = result[j + 1];
    }
    result = Arrays.copyOf(result, result.length - 1);
    if (result.length <= 0){
      needsToClear = false;
      needsToDrop = true;
      clearAllPieces = false;
      dropPieces();
    }
  }
}
