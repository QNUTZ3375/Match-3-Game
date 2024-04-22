import java.util.Arrays;
int xStartPos = 300;
int yStartPos = -300;
int cellSize = 50;
int colLen = 7; //i = colLen
int rowLen = 9; //j = rowLen
Cell[][] board = new Cell[colLen][rowLen];
boolean hasClickedOnce = false;
int currX1, currY1, currX2, currY2 = 0; //Stores the first piece and second piece coordinates for selecting
boolean needsToClear = false; //checks if there is a piece to clear
boolean clearAllPieces = false; //checks if the entire board needs to be cleared due to double special piece swap
boolean needToSwapBack = false; //checks if the most recent swap didn't match anything
boolean isReshuffling = false; //checks if the reshuffling animation is currently happening
int shrinkLimit = cellSize * 3 / 10; //The shrink size limit is 30% of the cellSize for all shapes (designed to reduce complexity)
float shrinkRate = float(cellSize) / 40;
Piece[][] result = {}; //stores the list of matches, usually should be empty
Piece[][] specialClears = {}; //stores the list of pieces that are cleared due to special pieces
String[] specialClearTypes = {}; //stores the types of special clears (paired with specialClears)
int[] piece1Disp = {0, 0};
int[] piece2Disp = {0, 0};
int positiveDisp = cellSize / 10;
int negativeDisp = -1 * positiveDisp; //negativeDisp has to have the same magnitude as positiveDisp
int[][] cellVertiDispsFromCenter = {}; //stores all vertical displacements of the cells from the center
int[][] cellHorizDispsFromCenter = {}; //stores all horizontal displacements of the cells from the center
int shuffleOrder = 1; //specifies the order of the shuffling animation 
//(1 = Towards center, 0 = actually swapping pieces, -1 = Away from center)
String shuffleDirection = "VERTICAL"; //specifies in which direction the pieces are to move during the animation
boolean currentlyShuffling = false; //checks if any piece is still moving
int prevID = -1; //holds the ID of the previous piece generated
int targetScore = -1;
int playerScore = -1;
int scoreIncrement = 100;
int moveCount = -1;
int currLevel = 1;
PFont f;
int resultingState = 0; //0 means nothing, 1 means passed level, -1 means failed level
int counterBeforeShuffle = 0;

void generateNewLevel(int level){
  resetAllParameters();
  generateLevel(level);
  generateBoardAndPieces();
  generateHoles(level);

  result = checkBoardState();
  if (result.length > 0){
    result = checkSpecialMatches(result, false);
    needsToClear = true;
  }
  generateDispsFromCenter();
}

void resetAllParameters(){
  hasClickedOnce = false;
  currX1 = currY1 = currX2 = currY2 = 0;
  needsToClear = false;
  needToSwapBack = false;
  isReshuffling = false;
  result = Arrays.copyOf(result, 0);
  piece1Disp[0] = piece1Disp[1] = 0;
  piece2Disp[0] = piece2Disp[1] = 0;
  cellVertiDispsFromCenter = Arrays.copyOf(cellVertiDispsFromCenter, 0);
  cellHorizDispsFromCenter = Arrays.copyOf(cellHorizDispsFromCenter, 0);
  shuffleOrder = 1;
  shuffleDirection = "VERTICAL"; 
  currentlyShuffling = false;
  droppingPieces = Arrays.copyOf(droppingPieces, 0);
  droppingDisps = Arrays.copyOf(droppingDisps, 0);
  needsToDrop = false;
  dropCounter = 0;
  swapCounter = 0;
  resultingState = 0;
}

void addScores(int regular, int fireworks, int cross, int special){
  /*
  firework = 3x
  cross = 4x
  special = 5x
  */
  playerScore += regular * scoreIncrement;
  playerScore += fireworks * 3 * scoreIncrement;
  playerScore += cross * 4 * scoreIncrement;
  playerScore += special * 5 * scoreIncrement;
  
  println(regular, fireworks, cross, special);
}

void reshufflePieces(){
  Cell[] allCells = {};
  //flattens the board cells into a one-dimensional array
  for(int i = 0; i < colLen; i++){
    for(int j = 2; j < rowLen; j++){
      //prevents empty or disabled pieces from being swapped
      if(board[i][j].currPiece.pieceID > 0){
        allCells = Arrays.copyOf(allCells, allCells.length + 1);
        allCells[allCells.length - 1] = board[i][j];
      }
    }
  }
  //swaps the last element with a random element excluding the last one then removes it (the last one) from the array, it keeps going until there's one element left
  for(int i = allCells.length - 1; i > 0; i--){
    int r = int(random(0, allCells.length - 2));
    allCells[i].swapPiece(false, allCells[r]);
    allCells = Arrays.copyOf(allCells, allCells.length - 1);
  }
}

void setup(){
  //note: the window size should be in a 3:2 ratio
  size(1050, 700);
  rectMode(CENTER);
  f = createFont("AmericanTypewriter", 40, true);
  generateLevel(currLevel);
  generateBoardAndPieces();
  generateHoles(currLevel);
  
  result = checkBoardState();
  if (result.length > 0){
    result = checkSpecialMatches(result, false);
    needsToClear = true;
  }
  generateDispsFromCenter();
}

void draw(){
  switch(resultingState){
    case 1:
      background(100, 255, 100);
      break;
    case -1:
      background(255, 100, 100);
      break;
    default:
      background(180);
  }
  //The two double-for loops deal with the visual bug where a piece slides under the grid 
  //when doing the swapping animation
  for(int i = 0; i < colLen; i++){
    for(int j = 0; j < rowLen; j++){
      board[i][j].show();
    }
  }
  for(int i = 0; i < colLen; i++){
    for(int j = 0; j < rowLen; j++){
      board[i][j].currPiece.show();
    }
  }
  switch(resultingState){
    case 1:
      fill(100, 255, 100);
      break;
    case -1:
      fill(255, 100, 100);
      break;
    default:
      fill(180);
  }
  //rectangle that hides the pieces above the playfield
  rect(width/2, yStartPos + cellSize, width, cellSize * 2);
  //left light blue rectangle
  fill(100, 230, 230);
  rect(175, height/2, 350, height);
  //text that shows metrics
  fill(0);
  textFont(f, 40);
  text("TARGET\nSCORE\nMOVES", 20, 70);
  text(":\n:\n:", 190, 67);
  text(targetScore + "\n" + playerScore + "\n" + moveCount, 210, 70);
  text("LEVEL", 98, 270);
  textFont(f, 80);
  text(currLevel, 140 - 20*(str(currLevel).length() - 1), 350);
  //draws line separating green and gray rectangles
  strokeWeight(3);
  stroke(0);
  line(350, 0, 350, height);
  //the next 2 lines are used to find the centerpoint of the playfield (used for calibration)
  //line(700, 0, 700, height);
  //line(350, 350, 1050, 350);
  noStroke();
  
  textFont(f, 40);
  if(isReshuffling){
    text("RESHUFFLING...", 365, height - 20);
  }
  
  textFont(f, 28);
  if(resultingState == 1){
    text("CONGRATULATIONS!\nPRESS ANY KEY\nFOR THE NEXT LEVEL", 20, 500);
  }
  if(resultingState == -1){
    text("PRESS ANY KEY\nTO RETRY", 20, 500);
  }
  
  if(swapCounter > 0){ //checks if there is a swap to be made
    swapCounter--;
    if(swapCounter <= 0){ //checks if the swap is done
      //resets all of the displacement variables and swaps the actual pieces at the end
      piece1Disp[0] = piece1Disp[1] = piece2Disp[0] = piece2Disp[1] = 0;
      board[currX1][currY1].swapPiece(true, board[currX2][currY2]);
      //Check swapped pieces
      result = checkSwappedPieces();
      if (result.length > 0){ //if there are matches to be cleared
        result = checkSpecialMatches(result, true);
        moveCount = max(0, --moveCount);
        needsToClear = true;
      } else{ //case where no matches are found after swapping
        needToSwapBack = !needToSwapBack; //switches the state of the boolean variable depending on how many times the pieces have swapped
      }
    }
    //updates the position of the two pieces 
    board[currX1][currY1].currPiece.changeDirection(piece1Disp[0], piece1Disp[1]);
    board[currX2][currY2].currPiece.changeDirection(piece2Disp[0], piece2Disp[1]);
  } else if(needToSwapBack){
    switchPieces(board[currX1][currY1].currPiece, board[currX2][currY2].currPiece); //swaps back the pieces if no matches are found
  } else if(needsToClear || clearAllPieces){    
    shrinkPieces(result[0]);
  } else if(needsToDrop){
    if(dropCounter > 0){
      dropCounter--;
      
      if(dropCounter <= 0){ //checks if the dropping is done
        while(droppingPieces.length > 0 && droppingDisps.length > 0){
          droppingPieces[0].currPiece.isDropping = false;
          board[droppingPieces[0].x + droppingDisps[0][0] / positiveDisp] //pt1
               [droppingPieces[0].y + droppingDisps[0][1] / positiveDisp].swapPiece(true, droppingPieces[0]); //pt2
          for(int i = 0; i < droppingPieces.length - 1; i++){
            droppingPieces[i] = droppingPieces[i + 1];
            droppingDisps[i] = droppingDisps[i + 1];
          }
          droppingPieces = Arrays.copyOf(droppingPieces, droppingPieces.length - 1);
          droppingDisps = Arrays.copyOf(droppingDisps, droppingDisps.length - 1);
        }
        dropPieces(); //finds the next set of pieces to drop
        fillEmptyCellsOutsidePlayField();
      }
      for(int i = 0; i < droppingPieces.length - 1; i++){ //drops all the pieces according to their directions
        droppingPieces[i].currPiece.changeDirection(droppingDisps[i][0], droppingDisps[i][1]);
      }
    }
  } else if(isReshuffling){
    //all animation starts with vertical motion, followed by horizontal motion
    switch(shuffleOrder){
      case 1: //towards center
        if(shuffleDirection == "VERTICAL"){
          //default case where no pieces moved
          currentlyShuffling = false;
          for(int i = 0; i < colLen; i++){
            for(int j = 2; j < rowLen; j++){
              //case where piece is above center point of playfield
              if(j <= (rowLen + 2)/2 && board[i][j].currPiece.yDisp < cellVertiDispsFromCenter[i][j - 2]){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(0, positiveDisp);
              //case where piece is below center point of playfield
              } else if (j >= (rowLen + 2)/2 && board[i][j].currPiece.yDisp > cellVertiDispsFromCenter[i][j - 2]){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(0, negativeDisp);
              }
            }
          }
          if(!currentlyShuffling){
            shuffleDirection = "HORIZONTAL";
          }
        } else if(shuffleDirection == "HORIZONTAL"){
          //default case where no pieces moved
          currentlyShuffling = false;
          for(int i = 0; i < colLen; i++){
            for(int j = 2; j < rowLen; j++){
              //case where piece is to the left of the center point of playfield
              if(i <= colLen/2 && board[i][j].currPiece.xDisp < cellHorizDispsFromCenter[i][j - 2]){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(positiveDisp, 0); 
              }
              //case where piece is to the right of the center point of playfield
              if(i >= colLen/2 && board[i][j].currPiece.xDisp > cellHorizDispsFromCenter[i][j - 2]){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(negativeDisp, 0); 
              }
            }
          }
          if(!currentlyShuffling){
            shuffleDirection = "VERTICAL";
            shuffleOrder = 0;
          }
        }
        break;
      case 0: //shuffles pieces (actually shuffles them now)
        reshufflePieces();
        shuffleOrder = -1; 
        break;
      case -1: //away from center
        if(shuffleDirection == "VERTICAL"){
          //default case where no pieces moved
          currentlyShuffling = false;
          for(int i = 0; i < colLen; i++){
            for(int j = 2; j < rowLen; j++){
              //case where piece should return to above center point of playfield
              if(j <= (rowLen + 2)/2 && board[i][j].currPiece.yDisp > 0){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(0, negativeDisp);
              //case where piece should return to below center point of playfield
              } else if (j >= (rowLen + 2)/2 && board[i][j].currPiece.yDisp < 0){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(0, positiveDisp);
              }
            }
          }
          if(!currentlyShuffling){
            shuffleDirection = "HORIZONTAL";
          }
        } else if(shuffleDirection == "HORIZONTAL"){
          //default case where no pieces moved
          currentlyShuffling = false;
          for(int i = 0; i < colLen; i++){
            for(int j = 2; j < rowLen; j++){
              //case where piece should return to the left of the center point of playfield
              if(i <= colLen/2 && board[i][j].currPiece.xDisp > 0){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(negativeDisp, 0); 
              }
              //case where piece is to the right of the center point of playfield
              if(i >= colLen/2 && board[i][j].currPiece.xDisp < 0){
                currentlyShuffling = true;
                board[i][j].currPiece.changeDirection(positiveDisp, 0); 
              }
            }
          }
          if(!currentlyShuffling){
            shuffleDirection = "VERTICAL";
            shuffleOrder = 1;
            isReshuffling = false;
          }
        }
        break;
    }
  }
  if(!needsToDrop && !needsToClear && swapCounter <= 0 && !isReshuffling && rowLen > 0 && colLen > 0){
    result = checkBoardState();
    if (result.length > 0){
      result = checkSpecialMatches(result, false);
      needsToClear = true;
    }else if(!checkValidSwitches(false)){
      if(counterBeforeShuffle >= 30){
        isReshuffling = true;
        counterBeforeShuffle = 0;
      } 
      else{
        counterBeforeShuffle++;
      }
    }else if(playerScore >= targetScore){
      resultingState = 1;
    }else if(moveCount <= 0 && playerScore < targetScore){
      resultingState = -1;
    }
  }
}

void mousePressed(){
  //prevents mouse clicks if there are any actions being performed or if a level has been cleared or failed 
  if(swapCounter > 0 || needsToClear || needsToDrop || needToSwapBack || isReshuffling || moveCount <= 0 || resultingState != 0){
    return;
  }
  //prevents the mouse click from registering if it's outside of the play field
  if(mouseX <= xStartPos || mouseY <= yStartPos + 2*cellSize || mouseX >= xStartPos + colLen * cellSize || mouseY >= yStartPos + rowLen * cellSize){
    hasClickedOnce = false;
    board[currX2][currY2].clickOrder = 0;
    board[currX1][currY1].clickOrder = 0;
    return;
  }
  //case where player hasn't selected another piece yet
  if(!hasClickedOnce){
    board[currX1][currY1].clickOrder = 0;
    board[currX2][currY2].clickOrder = 0;
    currX1 = int((mouseX - xStartPos) / cellSize);
    currY1 = int((mouseY - yStartPos) / cellSize);
    if(board[currX1][currY1].hasPiece && board[currX1][currY1].currPiece.pieceID > 0){
      hasClickedOnce = true;
      board[currX1][currY1].clickOrder = 1;
    }
    return;
  }
  
  currX2 = int((mouseX - xStartPos) / cellSize);
  currY2 = int((mouseY - yStartPos) / cellSize);
  //resets the boolean variable if the piece being selected is disabled or is a border
  if(!board[currX2][currY2].hasPiece || board[currX2][currY2].currPiece.pieceID <= 0){
    hasClickedOnce = false;
    board[currX2][currY2].clickOrder = 0;
    board[currX1][currY1].clickOrder = 0;
    return;
  }

  int tempXDisp = abs(currX2 - currX1);
  int tempYDisp = abs(currY2 - currY1);
  //checks if the two pieces selected are directly adjacent to each other
  if ((tempXDisp == 1 && tempYDisp == 0) || (tempXDisp == 0 && tempYDisp == 1)){ 
    //checks if the two selected pieces are adjacent and if the cell has a piece in it
    hasClickedOnce = false;
    board[currX2][currY2].clickOrder = 2;
    switchPieces(board[currX1][currY1].currPiece, board[currX2][currY2].currPiece);
  } else{ //moves x2 and y2 into x1 and y1
    board[currX1][currY1].clickOrder = 0;
    board[currX2][currY2].clickOrder = 1;
    currX1 = currX2;
    currY1 = currY2;
  }
}

void keyPressed(){
  if(resultingState != 0){
    if(resultingState == 1){
      currLevel++;
    }
    generateNewLevel(currLevel);
    return; //prevents special keys from triggering their blocks of code
  }
  if(48 <= (int) key && (int) key <= 57){
    currLevel = (int) key - 48;
    generateNewLevel(currLevel);
  }
  if(keyCode == LEFT && currLevel > 1){
    currLevel--;
    generateNewLevel(currLevel);
  }
  if(keyCode == RIGHT && currLevel < 9){
    currLevel++;
    generateNewLevel(currLevel);
  }
  if(key == 'h'){
    println(checkValidSwitches(true));
  }
  if(key == 's'){
    isReshuffling = true;
  }
}

/*
Notes:
- 28 Dec: made board and the pieces with colors, added mouse clicking recognition
- 29 Dec: added a piece swap function, fixed visual bug where the pieces weren't getting swapped correctly
- 29 Dec: added a conditional check that makes sure only adjacent pieces are allowed to swap (no diagonals)
- 29 Dec: added piece swapping animation, added a function to check the whole board for any consecutive matches
- 30 Dec: tweaked the check board function to only add elements to array if the element is at least 3 long
- 30 Dec: added a check to remove duplicate values in the check pieces function
- 30 Dec: added piece clearing animations for all pieces, checked if swapped pieces created any matches
- 31 Dec: tweaked the piece checking function so it can detect L-shaped, T-shaped, and Cross-shaped matches from one move
- 31 Dec: prevented empty cells from being selected and swapped with other cells
- 31 Dec: finished a working prototype of the dropPieces function
- 1 Jan: added support for checking piece matches after dropping pieces (some are still not registering)
- 1 Jan: attempted to check for larger matches

- 4 Jan: returned to this project. started working on a longDrop function. fixed a bug where pieces didn't want to drop all the way down
(switched hasPiece condition to hasCell condition in cell class for swapPiece function)
- 5 Jan: completed the longDropPieces function. fixed a lot of bugs along the way (arrays not being reset after use, multiple function calls etc)
- 5 Jan: added a function to fill all empty spots outside of play field, added a function to check if a valid swap is possible in a given board state
- 6 Jan: added a reshufflePieces function, set a condition so that the player can't make moves during reshuffling
- 6 Jan: added animation sequence for reshuffling pieces, tweaked the swapPiece function
- 7 Jan: prevented 3 of the same piece to spawn vertically at the same time, added a bar to hide the pieces outside the playfield
- 7 Jan: added scoring and move counting, added level concept (levels 1, 5)
- 8 Jan: refactored some code using guard clauses concept, added star piece and hexagon piece w/ shrink animation
- 8 Jan: added firework and cross graphics
- 9 Jan: added a function to check if a match creates any of the special pieces mentioned above
- 10 Jan: finished the function that checks if any special pieces were matched, and any subsequent matches after that
- 10 Jan: fixed a lot of bugs, including one where crosses wouldn't form properly due to duplicate values within
horizMatches, causing the cross piece to get erased too along with the other pieces
- 10 Jan: added sprites for each special piece that can be assigned to each piece within specialClears
- 10 Jan: swapped the hexagon and the star piece IDs, added multipliers for each special piece
- 10 Jan: added a clear board function on the rare case where two special pieces are swapped with each other

- 12 Jan: took a rest day, added progression, automated the shuffling and checkValidSwitches() condition
- 12 Jan: added X level, bomb level, and shield level (levels 2, 6, 7)
- 12 Jan: modified the generateLevels() function so now the x and y start positions are relative to colLen and rowLen
- 12 Jan: modified checkValidSwitches so now it only prints a valid switch when prompted, improved the resultingState
update so that it only checks after everything stops moving, added text and background changes according to resultingState
- 12 Jan: fixed a bug where dropPieces wouldn't register the top right diagonal cell as a droppable piece to use (control flow issue)
- 12 Jan: removed the longDrop function after discovering a bug that when fixed, allowed dropPieces to function just as fast as longDropPieces
modified dropPieces twice, one where the function starts inside the playfield instead of the very top (which fixed the control flow bug above)
and the other is where the function goes from bottom to top now instead of top to bottom, so that it prioritizes straight down drops first
- 12 Jan: changed the condition for rowLen, instead of making rowLen being twice the actual rows it now requires itself to be 2 + actual rows in playfield
- 12 Jan: added extra conditions within droppingPieces and a helper function to fix the priority of diagonal vs vertical dropping
- 12 Jan: added another check (an array) holesMade to work in conjunction with the helper function to fix the same issue
- 12 Jan: modified dropPieces to now check if the piece is empty and in the playfield when attempting diagonal movement 
(bug can be caused in bomb level with far left middle match, causing top left to diagonally accept top right)
- 13 Jan: (basically) overhauled the dropPieces function, added a helper function to check for holes within a continuous column section
- 13 Jan: added border checks (doesn't allow pieces outside playfield for diagonal movement), added checks using the helper function
- 13 Jan: fixed a lot of bugs over the course of the afternoon due to the faulty design of the old dropPieces function
- 14 Jan: reworked the user interface, refactored the mousePressed function, added H level, Xv2 level, hourglass level, tree level (levels 3, 4, 8, 9)
- 14 Jan: allowed modified pieces to be swapped regardless of pieceID.

THIS PROJECT IS CURRENTLY FINISHED AS OF NOW (Might add some more in the future), 2005 Lines of code
*/
