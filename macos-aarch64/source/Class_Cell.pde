class Cell {
  int x, y;
  Piece currPiece;
  int clickOrder = 0;
  boolean hasPiece = true;
  
  Cell(int _x, int _y, Piece curr){
    x = _x;
    y = _y;
    currPiece = curr;
  }
  
  void disableCell(){
    hasPiece = false;
    currPiece.hasCell = false;
    currPiece.pieceID = -1;
  }
  
  void show(){
    if(!hasPiece){
      return;
    }
    switch (clickOrder){
      case 1:
        fill(0, 150, 125);
        break;
      case 2:
        fill(125, 0, 0);
        break;
      default:
        fill(150);
    }
    strokeWeight(1);
    stroke(0);
    square(xStartPos + x * cellSize + cellSize / 2, yStartPos + y * cellSize + cellSize / 2, cellSize);
  }
  
  void swapPiece(boolean resetDisp, Cell toSwap){
    if(!currPiece.hasCell || !toSwap.currPiece.hasCell){
      return;
    }
    //checks if the two pieces want their displacements to be reset 
    //(this is used to differentiate between the reshuffling sequence and everything else)
    if(resetDisp){
      currPiece.resetDisplacement();
      toSwap.currPiece.resetDisplacement();
    } else{ //otherwise swaps their displacements (for reshuffling)
      int tempXDisp = toSwap.currPiece.xDisp;
      int tempYDisp = toSwap.currPiece.yDisp;
      toSwap.currPiece.xDisp = currPiece.xDisp;
      toSwap.currPiece.yDisp = currPiece.yDisp;
      currPiece.xDisp = tempXDisp;
      currPiece.yDisp = tempYDisp;
    }
    
    //Note: swap the x, y, and reference of the pieces. 
    //Swapping the references ensures there are no coordinate errors
    //and swapping the x y values is necessary for the swapping animation to work
    
    //swapping references mean the cells now hold different pieces 
    //but both of the piece's original xy coordinates stay unchanged (so both cell's pieces are in the wrong positions)
    //swapping those xy coordinates afterwards fixes that issue
    int tempx = toSwap.currPiece.x;
    int tempy = toSwap.currPiece.y;
    Piece ref = toSwap.currPiece;
    toSwap.currPiece.x = currPiece.x;
    toSwap.currPiece.y = currPiece.y;
    toSwap.currPiece = currPiece;
    currPiece.x = tempx;
    currPiece.y = tempy;
    currPiece = ref;
  }
  
  boolean isSwappableOnPlayField(){
    return hasPiece && currPiece.pieceID > 0 && currPiece.hasCell;
  }
}
