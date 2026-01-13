import 'player.dart';

class Game {
  List<String> board = List.filled(9, ''); // 3x3
  int turn = 0; // 0 = X, 1 = O
  final List<Player> players = [];

  String? winner;   // simbolo del vincitore
  bool gameOver = false;

  void addPlayer(Player player) {
    if (!isFull) players.add(player);
  }

  bool get isFull => players.length == 2;

  /// Aggiorna la board se la mossa è valida
  bool makeMove(int index, Player player) {
    final playerIndex = players.indexOf(player);

    if (gameOver) return false;
    if (playerIndex != turn) return false;
    if (board[index] != '') return false;

    board[index] = player.symbol;

    // Aggiorna turno per il prossimo giocatore
    turn = 1 - playerIndex;

    winner = checkWinner(board);
    gameOver = winner != null || isBoardFull(board);

    return true;
  }

  String? checkWinner(List<String> board) {
    const wins = [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6]
    ];

    for (var w in wins) {
      if (board[w[0]] != '' &&
          board[w[0]] == board[w[1]] &&
          board[w[1]] == board[w[2]]) {
        return board[w[0]];
      }
    }
    return null;
  }

  bool isBoardFull(List<String> board) => !board.contains('');
}
