Piece[] checkPiece(int xPos, int yPos, int prevID, String direction, Piece[] matches, int[][] visited){
  /*
  basically a graph traversal algorithm using DFS to check for matches of length 3 or longer given a current piece.
  */
  for(int i = 0; i < visited.length; i++){
    if (xPos == visited[i][0] && yPos == visited[i][1]){ //case where piece has been explored before
      return matches;
    }
  }
  //Adds current piece to visited
  visited = Arrays.copyOf(visited, visited.length + 1);
  visited[visited.length - 1] = new int[2];
  visited[visited.length - 1][0] = xPos;
  visited[visited.length - 1][1] = yPos;
  
  if (board[xPos][yPos].currPiece.pieceID != prevID){
    return matches;
  } //checks if the piece does not have the same ID as the previous piece

  matches = Arrays.copyOf(matches, matches.length + 1);  
  matches[matches.length - 1] = board[xPos][yPos].currPiece;
  //only check the neighbors if the current piece matches the previous one
  //Note: it only considers cells that have their hasPiece value set to true (included in play field)
  if(direction == "HORIZONTAL"){
    if(xPos > 0){
      if(board[xPos - 1][yPos].hasPiece){
        matches = checkPiece(xPos - 1, yPos, board[xPos][yPos].currPiece.pieceID, "HORIZONTAL", matches, visited);
      }
    }
    if(xPos < colLen - 1){
      if(board[xPos + 1][yPos].hasPiece){
        matches = checkPiece(xPos + 1, yPos, board[xPos][yPos].currPiece.pieceID, "HORIZONTAL", matches, visited);
      }
    }
  } else if (direction == "VERTICAL"){
    if(yPos > 2){
      if(board[xPos][yPos - 1].hasPiece){
        matches = checkPiece(xPos, yPos - 1, board[xPos][yPos].currPiece.pieceID, "VERTICAL", matches, visited);
      }
    }
    if(yPos < rowLen - 1){
      if(board[xPos][yPos + 1].hasPiece){
        matches = checkPiece(xPos, yPos + 1, board[xPos][yPos].currPiece.pieceID, "VERTICAL", matches, visited);
      }
    }
  }
  return matches;
}

Piece[][] checkBoardState(){
  /*
  go through every cell in the playfield. check in all four directions if there are any matches of length 3 or longer.
  record those matches in vertiMatches and horizMatches.
  */
  Piece[][] vertiMatches = {};
  Piece[][] horizMatches = {};
  for(int i = 0; i < colLen; i++){
    for(int j = 2; j < rowLen; j++){
      if(!board[i][j].hasPiece){
        continue;
      }
      int[][] visited1 = {};
      int[][] visited2 = {};

      Piece[] temp1 = {};
      Piece[] temp2 = {};
      temp1 = checkPiece(i, j, board[i][j].currPiece.pieceID, "VERTICAL", temp1, visited1);
      if (temp1.length >= 3){
        boolean isIncluded = false;
        for(int idx = 0; idx < vertiMatches.length; idx++){ //removes duplicate vertical values
          if (vertiMatches[idx][0].pieceID == temp1[0].pieceID && vertiMatches[idx][0].x == temp1[0].x){
            isIncluded = true;
            break;
          }
        }
        if(!isIncluded){
          vertiMatches = Arrays.copyOf(vertiMatches, vertiMatches.length + 1);
          vertiMatches[vertiMatches.length - 1] = temp1;
        }
      }
      temp2 = checkPiece(i, j, board[i][j].currPiece.pieceID, "HORIZONTAL", temp2, visited2);
      if(temp2.length >= 3){
        boolean isIncluded = false;
        for(int idx = 0; idx < horizMatches.length; idx++){ //removes duplicate horizontal values
          if (horizMatches[idx][0].pieceID == temp1[0].pieceID && horizMatches[idx][0].y == temp1[0].y){
            isIncluded = true;
            break;
          }
        }
        if(!isIncluded){
          horizMatches = Arrays.copyOf(horizMatches, horizMatches.length + 1);
          horizMatches[horizMatches.length - 1] = temp2;
        }
      }
      if(horizMatches.length > 0 && vertiMatches.length > 0){ //checks if both arrays are non-empty
        for(int k = 0; k < horizMatches[horizMatches.length - 1].length; k++){
          boolean foundIntersect = false;
          for(int l = 0; l < vertiMatches[vertiMatches.length - 1].length; l++){
            if(horizMatches[horizMatches.length - 1][k] == vertiMatches[vertiMatches.length - 1][l]){ //Checks if a piece has made both a vertical and horizontal match
              foundIntersect = true;
              for(int idx = 0; idx < vertiMatches[vertiMatches.length - 1].length; idx++){ //appends the vertical result to the horizontal array
                if(idx != l){
                  horizMatches[horizMatches.length - 1] = Arrays.copyOf(horizMatches[horizMatches.length - 1], horizMatches[horizMatches.length - 1].length + 1);
                  horizMatches[horizMatches.length - 1][horizMatches[horizMatches.length - 1].length - 1] = vertiMatches[vertiMatches.length - 1][idx];
                }
              }
            }
          }
          if(foundIntersect){
            //deletes the record from vertiMatches to preven duplicate entries in result (important for checkSpecialMatches function to work)
            vertiMatches = Arrays.copyOf(vertiMatches, vertiMatches.length - 1);
            break;
          }
        }
        //removes duplicates within a single element of horizMatches
        Piece[] checkDupes = {};
        for(int idx = 0; idx < horizMatches[horizMatches.length - 1].length; idx++){
          boolean isIn = false;
          for(int idx2 = 0; idx2 < checkDupes.length; idx2++){
            if(checkDupes[idx2] == horizMatches[horizMatches.length - 1][idx]){
              isIn = true;
            }
          }
          if(!isIn){
            checkDupes = Arrays.copyOf(checkDupes, checkDupes.length + 1);
            checkDupes[checkDupes.length - 1] = horizMatches[horizMatches.length - 1][idx];
          }
        }
        horizMatches[horizMatches.length - 1] = checkDupes;
      }
    }
  }
  for (int i = 0; i < horizMatches.length; i++){
    for (int j = 0; j < horizMatches[i].length; j++){
      println("H", horizMatches[i][j].x, horizMatches[i][j].y, horizMatches[i][j].pieceID);
    }
    println();
  }
  
  for (int i = 0; i < vertiMatches.length; i++){
    for (int j = 0; j < vertiMatches[i].length; j++){
      println("V", vertiMatches[i][j].x, vertiMatches[i][j].y, vertiMatches[i][j].pieceID);
    }
    println();
  }
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

boolean checkValidSwitches(boolean shouldPrint){
  /*
  go through whole board in playfield. check all 4 directions (only length 3 because it's the bare minimum).
  if any direction contains three in a row, return true preemptively 
  (shouldn't ever happen normally due to checkBoardState).
  if any direction contains two of the same ID (including root piece), perform subroutine below. 
  if neither condition is true, then just continue to next piece. 
  if subroutine returns True then return true, else continue. 
  if it reaches the end without returning true once, return false.
  
  subroutine: 
  perform the check on the odd one out. check if any of the four directions (excluding the two pieces from above)
  contains another piece of the same ID as the two above. return True if found. return False otherwise.
  */
  for(int i = 0; i < colLen; i++){
    for(int j = 2; j < rowLen; j++){
      if(board[i][j].currPiece.isSpecialPiece){
        if(shouldPrint){
          println("X: ", i, "Y: ", j - 2, "SPECIAL PIECE PRESENT");
        }
        return true;
      }
      //check current piece in all 4 directions (do it one by one to prevent bugs with disabled pieces and borders)
      int currID = board[i][j].currPiece.pieceID;
      int[] oddOneOutPos = new int[2];
      if (j >= 2){ //check upwards
        //checks if both pieces above the current one are not disabled and are in playfield
        if(board[i][j - 1].isSwappableOnPlayField() && board[i][j - 2].isSwappableOnPlayField()){
          int upMatches = 1;
          if(board[i][j - 1].currPiece.pieceID == currID){
            upMatches++;
            oddOneOutPos[0] = i;
            oddOneOutPos[1] = j - 2;
          }
          if(board[i][j - 2].currPiece.pieceID == currID){
            upMatches++;
            oddOneOutPos[0] = i;
            oddOneOutPos[1] = j - 1;
          }
          if (upMatches == 3){
            if(shouldPrint){
              println("X: ", i, "Y: ", j - 2, "\nUP 3");
            }
            return true;
          } else if(upMatches == 2){
            //check left neighbor (if piece is not on first column)
            if(oddOneOutPos[0] > 0){
              if(board[oddOneOutPos[0] - 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nUP, neighbor on Left");
                }
                return true;
              }
            }
            //check right neighbor (if piece is not on last column)
            if(oddOneOutPos[0] < colLen - 1){
              if(board[oddOneOutPos[0] + 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nUP, neighbor on Right");
                }
                return true;
              }
            }
            //check top neighbor (if odd one out is the edge (not the center) and edge is not on first row (of playfield))
            if(oddOneOutPos[1] == j - 2 && oddOneOutPos[1] > 2){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] - 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nUP, neighbor on Up");
                }
                return true;
              }
            }
          }
        }
      }
      if (j <= rowLen - 3){ //check downwards
        //checks if both pieces above the current one are not disabled and are in playfield
        if(board[i][j + 1].isSwappableOnPlayField() && board[i][j + 2].isSwappableOnPlayField()){
          int downMatches = 1;
          if(board[i][j + 1].currPiece.pieceID == currID){
            downMatches++;
            oddOneOutPos[0] = i;
            oddOneOutPos[1] = j + 2;
          }
          if(board[i][j + 2].currPiece.pieceID == currID){
            downMatches++;
            oddOneOutPos[0] = i;
            oddOneOutPos[1] = j + 1;
          }
          if (downMatches == 3){
            if(shouldPrint){
              println("X: ", i, "Y: ", j - 2, "\nDOWN 3");
            }
            return true;
          } else if(downMatches == 2){
            //check left neighbor (if piece is not on first column)
            if(oddOneOutPos[0] > 0){
              if(board[oddOneOutPos[0] - 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nDOWN, neighbor on Left");
                }
                return true;
              }
            }
            //check right neighbor (if piece is not on last column)
            if(oddOneOutPos[0] < colLen - 1){
              if(board[oddOneOutPos[0] + 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nDOWN, neighbor on Right");
                }
                return true;
              }
            }
            //check bottom neighbor (if odd one out is the edge (not the center) and edge is not on last row)
            if(oddOneOutPos[1] == j + 2 && oddOneOutPos[1] < rowLen - 1){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] + 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nDOWN, neighbor on Bottom");
                }
                return true;
              }
            }
          }
        }
      }
      if (i >= 2){ //check leftwards
        //checks if both pieces left of the current one are not disabled and are in playfield
        if(board[i - 1][j].isSwappableOnPlayField() && board[i - 2][j].isSwappableOnPlayField()){
          int leftMatches = 1;
          if(board[i - 1][j].currPiece.pieceID == currID){
            leftMatches++;
            oddOneOutPos[0] = i - 2;
            oddOneOutPos[1] = j;
          }
          if(board[i - 2][j].currPiece.pieceID == currID){
            leftMatches++;
            oddOneOutPos[0] = i - 1;
            oddOneOutPos[1] = j;
          }
          if (leftMatches == 3){
            if(shouldPrint){
              println("X: ", i, "Y: ", j - 2, "\nLEFT 3");
            }
            return true;
          } else if(leftMatches == 2){
            //check top neighbor (if piece is not on first row (of playfield))
            if(oddOneOutPos[1] > 2){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] - 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nLEFT, neighbor on Up");
                }
                return true;
              }
            }
            //check bottom neighbor (if piece is not on last row)
            if(oddOneOutPos[1] < rowLen - 1){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] + 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nLEFT, neighbor on Bottom");
                }
                return true;
              }
            }
            //check left neighbor if odd one out is the edge (not the center) and edge is not on first column
            if(oddOneOutPos[0] == i - 2 && oddOneOutPos[0] > 0){
              if(board[oddOneOutPos[0] - 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nLEFT, neighbor on Left");
                }
                return true;
              }
            }
          }
        }
      }
      if (i <= colLen - 3){ //check rightwards
        //checks if both pieces right of the current one are not disabled and are in playfield
        if(board[i + 1][j].isSwappableOnPlayField() && board[i + 2][j].isSwappableOnPlayField()){
          int rightMatches = 1;
          if(board[i + 1][j].currPiece.pieceID == currID){
            rightMatches++;
            oddOneOutPos[0] = i + 2;
            oddOneOutPos[1] = j;
          }
          if(board[i + 2][j].currPiece.pieceID == currID){
            rightMatches++;
            oddOneOutPos[0] = i + 1;
            oddOneOutPos[1] = j;
          }
          if (rightMatches == 3){
            if(shouldPrint){
              println("X: ", i, "Y: ", j - 2, "\nRIGHT 3");
            }
            return true;
          } else if(rightMatches == 2){
            //check top neighbor (if piece is not on first row (of playfield))
            if(oddOneOutPos[1] > 2){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] - 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nRIGHT, neighbor on Up");
                }
                return true;
              }
            }
            //check bottom neighbor (if piece is not on last row)
            if(oddOneOutPos[1] < rowLen - 1){
              if(board[oddOneOutPos[0]][oddOneOutPos[1] + 1].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nRIGHT, neighbor on Bottom");
                }
                return true;
              }
            }
            //check right neighbor if odd one out is the edge (not the center) and edge is not on last column
            if(oddOneOutPos[0] == i + 2 && oddOneOutPos[0] < colLen - 1){
              if(board[oddOneOutPos[0] + 1][oddOneOutPos[1]].currPiece.pieceID == currID){
                if(shouldPrint){
                  println("X: ", i, "Y: ", j - 2, "\nRIGHT, neighbor on Right");
                }
                return true;
              }
            }
          }
        }
      }
    }
  }
  if(shouldPrint){
    println("Nope, no valid swaps");
  }
  return false;
}

Piece[][] checkSpecialMatches(Piece[][] result, boolean useRecentVals){
  /*
  checks if any element in result is longer than 3. If it's 4, check the recent value. if true, use the recent values 
  currX1 Y1 X2 and Y2.
  
  else, randomly pick the center left or center right.
  
  If it's 5, check if either the column or row stays the same throughout the entire sub-array. 
  if yes, always choose the center.
  if not, use the majority voting algorithm to find the intersection.
  
  if the result is longer than 3, remove the piece chosen from the result array (to prevent clearing it).
  */
  int regular = 0;
  int fireworks = 0;
  int cross = 0;
  int special = 0;
  
  //loops through all elements in result
  for(int i = 0; i < result.length; i++){
    boolean hasSpecialMatch = false;
    //checks if any piece within result[i] is special
    for(int j = 0; j < result[i].length; j++){
      if (result[i][j].hasFirework){
        updateSpecialClears(result[i][j], "FIREWORK");
        hasSpecialMatch = true;
        fireworks++;
        regular--;
      }
      if(result[i][j].hasCross){
        updateSpecialClears(result[i][j], "CROSS");
        hasSpecialMatch = true;
        cross++;
        regular--;
      }
      if(result[i][j].isSpecialPiece){
        updateSpecialClears(result[i][(j + 1) % 2], "SPECIAL");
        result[i][j].isSpecialPiece = false;
        //appends the special piece to specialClears
        specialClears[specialClears.length - 1] = Arrays.copyOf(specialClears[specialClears.length - 1], specialClears[specialClears.length - 1].length + 1);
        specialClears[specialClears.length - 1][specialClears[specialClears.length - 1].length - 1] = result[i][j];
        hasSpecialMatch = true;
        special++;
        regular--;
      }
    }
    regular += result[i].length;
    //case where a special match has been made (ignores special cases)
    if(hasSpecialMatch){
      continue;
    }
    if(result[i].length == 4){
      //checks the most recent swapped pieces
      if(useRecentVals){
        //checks if currX1Y1 and currX2Y2 are in result[i]
        for(int j = 0; j < result[i].length; j++){
          if (result[i][j].x == currX1 && result[i][j].y == currY1){
            result[i][j].hasFirework = true;
          }
          if (result[i][j].x == currX2 && result[i][j].y == currY2){
            result[i][j].hasFirework = true;
          }
          if(result[i][j].hasFirework){
            //removes the current piece from the result[i] array (to prevent it from getting cleared) and exits loop early
            for(int k = j; k < result[i].length - 1; k++){
              result[i][k] = result[i][k + 1];
            }
            result[i] = Arrays.copyOf(result[i], result[i].length - 1);
            break;
          }
        }
      } else{
        //picks a random central value within result[i]
        int r = int(random(1, 3));
        result[i][r].hasFirework = true;
        //removes the current piece from the result[i] array (to prevent it from getting cleared)
        for(int k = r; k < result[i].length - 1; k++){
          result[i][k] = result[i][k + 1];
        }
        result[i] = Arrays.copyOf(result[i], result[i].length - 1);
      }
    } else if(result[i].length >= 5){
      int currRow = result[i][0].x;
      int currRowOccurences = 1;
      int currCol = result[i][0].y;
      int currColOccurences = 1;
      boolean changedRows = false;
      boolean changedCols = false;
      for(int j = 0; j < result[i].length; j++){
        //check whether the row has changed within result[i]
        if (currRow != result[i][j].x){
          changedRows = true;
          currRowOccurences--;
          if (currRowOccurences <= 0){
            currRow = result[i][j].x;
            currRowOccurences = 1;
          }
        } else{
          currRowOccurences++;
        }
        //check whether the column has changed within result[i]
        if (currCol != result[i][j].y){
          changedCols = true;
          currColOccurences--;
          if (currColOccurences <= 0){
            currCol = result[i][j].y;
            currColOccurences = 1;
          }
        } else{
          currColOccurences++;
        }
      }
      //case where both rows and cols changed (has an intersection), make a cross behind piece
      if(changedCols && changedRows){
        for(int k = 0; k < result[i].length; k++){
          if(result[i][k].x == currRow && result[i][k].y == currCol){
            result[i][k].hasCross = true;
            //removes the current piece from the result[i] array (to prevent it from getting cleared) and exits loop early
            for(int l = k; l < result[i].length - 1; l++){
              result[i][l] = result[i][l + 1];
            }
            result[i] = Arrays.copyOf(result[i], result[i].length - 1);
            break;
          }
        }
        break;
      } else{
        //case where 5 in a row (or longer) is found, making a special piece
        int rowToPick = 0;
        int colToPick = 0;
        //finds the column and row needed to make the special piece (always the center)
        //the reason being the results from checkSwappedPieces and checkBoardState return different array configurations, 
        //forcing the program to find it manually everytime
        for(int m = 0; m < result[i].length; m++){
          rowToPick += result[i][m].x;
          colToPick += result[i][m].y;
        }
        //finds the average of the rows and columns
        rowToPick /= result[i].length;
        colToPick /= result[i].length;
        for(int m = 0; m < result[i].length; m++){
          if(result[i][m].x == rowToPick && result[i][m].y == colToPick){
            result[i][m].isSpecialPiece = true;
            result[i][m].pieceID = 7;
            //removes the current piece from the result[i] array (to prevent it from getting cleared) and exits loop early
            for(int k = m; k < result[i].length - 1; k++){
              result[i][k] = result[i][k + 1];
            }
            result[i] = Arrays.copyOf(result[i], result[i].length - 1);
            break;
          }
        }
      }
    }
  }
  //keeps going through specialClears until it's empty
  while(specialClears.length > 0){
    //checks the first element of specialClears if there are any special pieces within those pieces
    for(int i = 0; i < specialClears[0].length; i++){
      //if any of the three are triggered, reduce the regular pieces by one and add special piece by one
      if(specialClears[0][i].hasFirework){
        updateSpecialClears(specialClears[0][i], "FIREWORK");
        fireworks++;
        regular--;
      }
      if(specialClears[0][i].hasCross){
        updateSpecialClears(specialClears[0][i], "CROSS");
        cross++;
        regular--;
      }
      if(specialClears[0][i].isSpecialPiece){
        updateSpecialClears(specialClears[0][i], "SPECIAL");
        special++;
        regular--;
      }
    }
    //counts the pieces in specialClears[0]
    regular += specialClears[0].length;
    
    //appends the first element of specialClears into result
    result = Arrays.copyOf(result, result.length + 1);
    result[result.length - 1] = new Piece[specialClears[0].length];
    for(int i = 0; i < specialClears[0].length; i++){
      result[result.length - 1][i] = specialClears[0][i];
    }
    
    //deletes the first element of speciaClears and specialClearTypes so that eventually specialClears becomes empty
    for(int i = 0; i < specialClears.length - 1; i++){
      specialClears[i] = specialClears[i + 1];
      specialClearTypes[i] = specialClearTypes[i + 1];
    }
    specialClears = Arrays.copyOf(specialClears, specialClears.length - 1);
    specialClearTypes = Arrays.copyOf(specialClearTypes, specialClearTypes.length - 1);
  }
  //tallies up the scores
  addScores(regular, fireworks, cross, special);
  return result;
}
