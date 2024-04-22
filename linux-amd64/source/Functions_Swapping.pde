Piece[][] checkSwappedPieces(){
  //case where two special piece have been swapped
  if(board[currX1][currY1].currPiece.isSpecialPiece && board[currX2][currY2].currPiece.isSpecialPiece){
    Piece[] res = {};
    for(int i = 0; i < colLen; i++){
      for(int j = 2; j < rowLen; j++){
        if(board[i][j].currPiece.pieceID > 0){
          board[i][j].currPiece.specialVal = 1;
          res = Arrays.copyOf(res, res.length + 1);
          res[res.length - 1] = board[i][j].currPiece;
        }
      }
    }
    playerScore += 1000;
    addScores(res.length - 2, 0, 0, 2);
    result = Arrays.copyOf(result, result.length + 1);
    result[result.length - 1] = res;
    return result;
  }
  //case where a special piece has been swapped with
  if(board[currX1][currY1].currPiece.isSpecialPiece || board[currX2][currY2].currPiece.isSpecialPiece){
    Piece[][] ret = {{board[currX1][currY1].currPiece, board[currX2][currY2].currPiece}};
    return ret;
  }
  
  //case where two modified pieces of any type have been swapped
  if(board[currX1][currY1].currPiece.isModifiedPiece() && board[currX2][currY2].currPiece.isModifiedPiece()){
    Piece[][] ret = {{board[currX1][currY1].currPiece, board[currX2][currY2].currPiece}};
    return ret;
  }
  
  Piece[][] vertiMatches = {};
  Piece[][] horizMatches = {};
  //checks for horizontal and vertical matches for both pieces
  for(int i = 0; i < 4; i++){
    Piece[] matches = {};
    int[][] visited = {};
    switch(i){
      case 0:
        matches = checkPiece(currX1, currY1, board[currX1][currY1].currPiece.pieceID, "HORIZONTAL", matches, visited);
        break;
      case 1:
        matches = checkPiece(currX1, currY1, board[currX1][currY1].currPiece.pieceID, "VERTICAL", matches, visited);
        break;
      case 2:
        matches = checkPiece(currX2, currY2, board[currX2][currY2].currPiece.pieceID, "HORIZONTAL", matches, visited);
        break;
      case 3:
        matches = checkPiece(currX2, currY2, board[currX2][currY2].currPiece.pieceID, "VERTICAL", matches, visited);
        break;
    }
    if (matches.length >= 3){
      boolean isIncluded = false;
      if(i % 2 == 1){ //Vertical matches
        for(int idx = 0; idx < vertiMatches.length; idx++){ //removes duplicate vertical values
          if (vertiMatches[idx][0].pieceID == matches[0].pieceID && vertiMatches[idx][0].x == matches[0].x){
            isIncluded = true;
            break;
          }
        }
        if(!isIncluded){
          vertiMatches = Arrays.copyOf(vertiMatches, vertiMatches.length + 1);
          vertiMatches[vertiMatches.length - 1] = matches;
        }
      } else{ //Horizontal matches
        for(int idx = 0; idx < horizMatches.length; idx++){ //removes duplicate horizontal values
          if (horizMatches[idx][0].pieceID == matches[0].pieceID && horizMatches[idx][0].y == matches[0].y){
            isIncluded = true;
            break;
          }
        }
        if(!isIncluded){
          horizMatches = Arrays.copyOf(horizMatches, horizMatches.length + 1);
          horizMatches[horizMatches.length - 1] = matches;
        }
      }
    }
    if(horizMatches.length > 0 && vertiMatches.length > 0){ //checks if both arrays are non-empty
      for(int k = 0; k < horizMatches[horizMatches.length - 1].length; k++){
        boolean foundIntersect = false;
        for(int l = 0; l < vertiMatches[vertiMatches.length - 1].length; l++){
          if(horizMatches[horizMatches.length - 1][k] == vertiMatches[vertiMatches.length - 1][l]){ //Checks if a piece has made both a vertical and horizontal match
            foundIntersect = true;
            for(int idx = 1; idx < vertiMatches[vertiMatches.length - 1].length; idx++){ //appends the vertical result to the horizontal array
              horizMatches[horizMatches.length - 1] = Arrays.copyOf(horizMatches[horizMatches.length - 1], horizMatches[horizMatches.length - 1].length + 1);
              horizMatches[horizMatches.length - 1][horizMatches[horizMatches.length - 1].length - 1] = vertiMatches[vertiMatches.length - 1][idx];
            }
          }
        }
        if(foundIntersect){
          //deletes the record from vertiMatches to preven duplicate entries in result (important for checkSpecialMatches function to work)
          vertiMatches = Arrays.copyOf(vertiMatches, vertiMatches.length - 1);
          break;
        }
      }
    }
  }
  //println("V: ", vertiMatches.length, "H: ", horizMatches.length);
  Piece[][] ret = {}; //combines both vertical and horizontal matches into one array
  for(int i = 0; i < vertiMatches.length; i++){
    ret = Arrays.copyOf(ret, ret.length + 1);
    ret[ret.length - 1] = vertiMatches[i];
  }
  for(int i = 0; i < horizMatches.length; i++){
    ret = Arrays.copyOf(ret, ret.length + 1);
    ret[ret.length - 1] = horizMatches[i];
  }
  return ret;
}

int swapCounter = 0; //counts how many times the pieces have to move during the swapping animation

void switchPieces(Piece piece1, Piece piece2){
  //piece1 is the first piece selected, piece2 is the second piece selected
  swapCounter = cellSize / positiveDisp; //positiveDisp should be a factor of cellSize for smooth movement 
  //(otherwise it becomes jittery)
  int xDisp = piece1.x - piece2.x;
  int yDisp = piece1.y - piece2.y;
  
  switch(xDisp){
    case 1: //Case where first piece is to the right of the second piece
      piece1Disp[0] = negativeDisp;
      piece2Disp[0] = positiveDisp;
      return;
    case -1: //Case where first piece is to the left of the second piece
      piece1Disp[0] = positiveDisp;
      piece2Disp[0] = negativeDisp;
      return;
    default:
  }
  
  switch(yDisp){
    case 1: //Case where first piece is below the second piece
      piece1Disp[1] = negativeDisp;
      piece2Disp[1] = positiveDisp;
      return;
    case -1: //Case where first piece is above the second piece
      piece1Disp[1] = positiveDisp;
      piece2Disp[1] = negativeDisp;
      return;
    default:
  }
}
