class Piece {
  int x, y;
  int pieceID;
  int xDisp, yDisp = 0;
  int fireworkPos = 0; //0 means nothing, 1 is vertical, 2 is horizontal, 3 is left diagonal, 4 is right diagonal
  int crossPos = 0; //0 means nothing, 1 is vertical, 2 is horizontal
  int specialVal = 0; //0 means nothing, 1 means present
  boolean hasCell = true;
  boolean isDropping = false;
  boolean hasFirework = false;
  boolean hasCross = false;
  boolean isSpecialPiece = false;
  float shrinkSize = 0; //size reduction of shape
  //Table for shrink size limits:
  //Square: 30
  //Circle: 30
  //Triangle: 30
  //Diamond: 30
  //Line: 20
  
  Piece(int _x, int _y, int temp){
    x = _x;
    y = _y;
    pieceID = temp;
  }
  
  boolean isModifiedPiece(){
    return hasFirework || hasCross || isSpecialPiece;
  }
  
  void changeDirection(int tempX, int tempY){
    xDisp += tempX;
    yDisp += tempY;
  }
  
  void resetDisplacement(){
    xDisp = yDisp = 0;
  }
  
  void show(){
    if(!hasCell){
      return;
    }
        
    int defaultX = xStartPos + x * cellSize + xDisp;
    int defaultY = yStartPos + y * cellSize + yDisp;
    if(hasFirework){
      strokeWeight(2);
      stroke(255, 0, 0);
      line(defaultX + cellSize / 2, defaultY + cellSize * 1/10, defaultX + cellSize / 2, defaultY + cellSize * 9/10);
      stroke(255, 125, 0);
      line(defaultX + cellSize * 1/10, defaultY + cellSize / 2, defaultX + cellSize * 9/10, defaultY + cellSize / 2);
      stroke(255, 255, 0);
      line(defaultX + cellSize * 1/10, defaultY + cellSize * 1/10, defaultX + cellSize * 9/10, defaultY + cellSize * 9/10);
      stroke(125, 255, 0);
      line(defaultX + cellSize * 1/10, defaultY + cellSize * 9/10, defaultX + cellSize * 9/10, defaultY + cellSize * 1/10);
    }
    noStroke();

    if(hasCross){
      fill(255);
      rect(defaultX + cellSize / 2, defaultY + cellSize / 2, cellSize * 1/5, cellSize * 4/5);
      rect(defaultX + cellSize / 2, defaultY + cellSize / 2, cellSize * 4/5, cellSize * 1/5);
    }
    
    if(isSpecialPiece){ //special (star) piece
      int len = cellSize * 3/10 - int(shrinkSize); //length of a point of the star to the center
      /*
      length = len
      center = x, y
      top = x, y - len
      bottom left = x - len * sin(36), y + len * sin(54)
      bottom right = x + len * sin(36), y + len * sin(54)
      top left = x - len * sin(72), y - len * sin(18)
      top right = x + len * sin(72), y - len * sin(18)
      */
      fill(255);
      beginShape();
      vertex(defaultX + cellSize / 2, defaultY + cellSize / 2 - len + len * shrinkSize/shrinkLimit); //Top
      vertex(defaultX + cellSize / 2 - len * sin(radians(36)), defaultY + cellSize / 2 + len * sin(radians(54))); //Bottom left
      vertex(defaultX + cellSize / 2 + len * sin(radians(72)), defaultY + cellSize / 2 - len * sin(radians(18))); //Right
      vertex(defaultX + cellSize / 2 - len * sin(radians(72)), defaultY + cellSize / 2 - len * sin(radians(18))); //Left
      vertex(defaultX + cellSize / 2 + len * sin(radians(36)), defaultY + cellSize / 2 + len * sin(radians(54))); //Bottom right
      endShape(CLOSE);
      return;
    }
    
    fill(255, 255, 255, 150);
    if(specialVal == 1){
      square(defaultX + cellSize/2, defaultY + cellSize/2, cellSize - 4 * shrinkSize);
    }
    
    switch (pieceID){
      //Square piece
      case 1:
        fill(255, 0, 0);
        square(defaultX + cellSize / 2, defaultY + cellSize / 2, max(0, cellSize / 2 - 2 * shrinkSize));
        break;
      //Triangle piece
      case 2:
        fill(0, 255, 0);
        triangle(defaultX + cellSize / 2, defaultY + cellSize * 1/5 + shrinkSize,    //Top
                 defaultX + cellSize * 1/5 + shrinkSize, defaultY + cellSize * 4/5 - shrinkSize,  //Left
                 defaultX + cellSize * 4/5 - shrinkSize, defaultY + cellSize * 4/5 - shrinkSize); //Right
        break;
      //Line Piece
      case 3:
        fill(0, 0, 255);
        rect(defaultX + cellSize / 2, defaultY + cellSize / 2, 
             cellSize * 3/4 - 75.0 * (shrinkSize/30.0), cellSize * 1/5 - 20.0 * (shrinkSize/30.0)); //75, 20
        break;
      //Circle Piece
      case 4:
        fill(255, 255, 0);
        circle(defaultX + cellSize / 2, defaultY + cellSize / 2, cellSize * 3/5 - 2 * shrinkSize);
        break;
      //Diamond piece
      case 5:
        fill(255, 125, 0);
        quad(defaultX + cellSize * 1/2, defaultY + cellSize * 1/5 + shrinkSize,  //Top
             defaultX + cellSize * 4/5 - shrinkSize, defaultY + cellSize * 1/2,  //Right
             defaultX + cellSize * 1/2, defaultY + cellSize * 4/5 - shrinkSize,  //Bottom
             defaultX + cellSize * 1/5 + shrinkSize, defaultY + cellSize * 1/2); //Left
        break;
      //Hexagon piece
      case 6:
        int radius = cellSize * 3/10 - int(shrinkSize); //cellSize * 0.5 - cellSize * 0.2 = cellSize * 0.3
        fill(240, 0, 240);
        beginShape();
        vertex(defaultX + cellSize / 2, defaultY + cellSize / 2 - radius); //Top
        vertex(defaultX + cellSize / 2 - radius * sin(radians(60)), defaultY + cellSize/2 - radius * cos(radians(60))); //Top left
        vertex(defaultX + cellSize / 2 - radius * sin(radians(60)), defaultY + cellSize/2 + radius * cos(radians(60))); //Bottom left
        vertex(defaultX + cellSize / 2, defaultY + cellSize / 2 + radius); //Bottom
        vertex(defaultX + cellSize / 2 + radius * sin(radians(60)), defaultY + cellSize/2 + radius * cos(radians(60))); //Bottom right
        vertex(defaultX + cellSize / 2 + radius * sin(radians(60)), defaultY + cellSize/2 - radius * cos(radians(60))); //Top right
        endShape(CLOSE);
        break;
      //Empty piece
      default:
    }
    
    strokeWeight(4);
    switch(fireworkPos){
      case 1:
        stroke(255, 0, 0);
        line(defaultX + cellSize / 2, defaultY, defaultX + cellSize / 2, defaultY + cellSize);
        break;
      case 2:
        stroke(255, 125, 0);
        line(defaultX, defaultY + cellSize / 2, defaultX + cellSize, defaultY + cellSize / 2);
         break;
      case 3:
        stroke(255, 255, 0);
        line(defaultX, defaultY, defaultX + cellSize, defaultY + cellSize);
        break;
      case 4:
        stroke(125, 255, 0);
        line(defaultX, defaultY + cellSize, defaultX + cellSize, defaultY);
        break;
      default:
    }
    noStroke();
    
    fill(255);
    switch(crossPos){
      case 1:
        rect(defaultX + cellSize / 2, defaultY + cellSize / 2, cellSize, cellSize * 1/5);
        break;
      case 2:
        rect(defaultX + cellSize / 2, defaultY + cellSize / 2, cellSize * 1/5, cellSize);
        break;
      default:
    }
  }
}
