# Ruby Chess Game

This game is the [capstone project](https://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project?ref=lnav) for The Odin Project's Ruby Programming curriculum.

## Demo

![demo gif of classic 1858 game of Paul Morphy vs Duke Karl](demo/demo.gif)


*A short demonstration of* [The Opera Game](https://www.chess.com/terms/opera-game-chess), *a famous 1858 match between Paul Morphy and Duke Karl.*

***

## How to Play

For best visual results, install locally and play around with fonts that look good with the chess board. The demo above uses `Noto Mono Regular` in 14pt font.
To just get a sense of the gameplay, play online using link below.

### Play Online

Play quickly and easily on this [replit.com page](https://replit.com/@JoeMcCannDev/chess). After page loads, click the green "run" button. After a few seconds of loading, you should be on the welcome screen.

### Install Locally

#### Requirements

- ruby >= 2.7.0
- bundler >= 2.1.2

### Installation

- clone this repo
- cd into cloned directory `cd chess`
- run `bundle install`

### Running the Tests

#### To run the tests

- `rspec spec/` from the `chess` directory.

### How to Play

- run `ruby lib/main.rb`
- make a selection on the welcome screen

## Gameplay

At the welcome screen, you'll be prompted to select a game mode. Your choices are

1. play a friend
2. play the computer (computer makes a random move or capture)
3. play a saved game

During any player move, you have commands available to you.

**commands**: `flip` | `save` | `load` | `help` | `quit` | `resign` | `draw`
- **flip** - switches the view to the opposite board perspective
- **save** - saves game with filename of your choice. resumes progress after saving
- **load** - exits current game and loads a selected saved game
- **help** - shows the help screen
- **resign** - current player forfeits the match
- **draw** - current player can offer a draw. CPU will always decline (It's easy to beat!)
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

#### TODO

- ~~Learn more about OOP and design patterns~~.
