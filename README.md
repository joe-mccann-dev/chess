# Ruby Chess Game

This game is the [capstone project](https://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project?ref=lnav) for the The Odin Project's Ruby Programming curriculum.

## Demo

![demo gif of classic 1858 game of Paul Morphy vs Duke Karl](demo/demo.gif)


*A short demonstration of* [The Opera Game](https://www.chess.com/terms/opera-game-chess), *a famous 1858 match between Paul Morphy and Duke Karl.*

***

## Gameplay

At the welcome screen, you'll be prompted to select a game mode. Your choices are

1. play a friend
2. play the computer (computer makes a random move or capture)
3. play a saved game

During any player move, you have commands available to you.
- commands: flip | save | load | help | quit | resign | draw
- **flip** - switches the view to the opposite board perspective
- **save** - saves game with filename of your choice. resumes progress after saving
- **load** - exits current game and loads a selected saved game
- **help** - shows the help screen
- **resign** - current player forfeits the match
- **draw
- **quit** - terminates the program

### How to move pieces

This game uses traditional [algebraic notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess)) to enter moves.
Attack moves must preface destination square with an "x".

Every piece except the pawn is assigned a piece prefix:

  King, Queen, Rook, Knight, Bishop == K, Q, R, N, B

  - pawns      =>   e5, exd6, a5, axb6 . . .
  - others     =>   Ke7, Kxe7, Nc3, Nxc6 . . .
  - castling   =>   0-0 (king-side). 0-0-0 (queen-side)
  - en passant =>   exd6 (attack as if enemy has just moved one square)
      

Moves are case sensitive.

##### Move Disambiguation

- If disambiguation is required (two or more pieces of the same type can go to the same square), you'll be prompted to choose which piece you'd like to move.

##### Pawn Promotion

- If one of your pawns reaches its final rank, you will be prompted to promote it to either a Queen, Rook, Knight, or Bishop

##### En Passant Attacks

- Follows en passant rules. Only possible if most recent enemy move was a two-square pawn move

##### Castling

Castling is only possible if the following are true:

- Your King is not currently in check
- Neither your King nor your relevant Rook has moved previously
- No opponent pieces can attack your King's castling path.

##### Checkmate and Stalemate

- Checkmate => A player has no legal moves and their king is in check.
- Stalemate => A player has no legal moves and their king is not in check.
- Game will conclude upon either stalemate or checkmate

### Reflection

This project was very challenging. If I am honest, I think I struggled with organization and a lack of planning. I think those two things slowed me down and added unnecessary difficulty to an already difficult task. Lesson learned though. Going forward, I will pay more attention to these things.

I remember when I was doing Web Dev 101. I had finished the Rock Paper Scissors assignment and thought, "How will I ever do chess?" And then I did it. There is definite room for improvement. I didn't write enough tests, and the code is kind of messy in places. But I finished it, a functional chess game. And I couldn't have done it without the fantastic support of The Odin Project community.

#### TODO

- Learn more about OOP and design patterns.
