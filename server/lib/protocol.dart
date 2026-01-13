import 'dart:convert';
import 'game.dart';
import 'player.dart';

void handleMessage(Game game, Player sender, List<int> data) {
  final msg = jsonDecode(utf8.decode(data));
  print('Messaggio ricevuto dal server: $msg');

  if (msg['type'] == 'move') {
    final index = msg['index'];
    final playerIndex = game.players.indexOf(sender);

    // Controllo turno
    if (playerIndex != game.turn) {
      print('Fuori turno, mossa ignorata');
      return;
    }

    // Controllo cella libera
    if (game.board[index] != '') {
      print('Cella occupata, mossa ignorata');
      return;
    }

    // Aggiorna board e turno
    game.board[index] = sender.symbol;
    game.turn = 1 - playerIndex;

    // Controlla vittoria o pareggio
    game.winner = game.checkWinner(game.board);
    game.gameOver = game.winner != null || game.isBoardFull(game.board);

    // Invia aggiornamento a tutti i client
    broadcastGameState(game);
  }
}

void broadcastGameState(Game game) {
  for (final player in game.players) {
    player.socket.writeln(jsonEncode({
      'type': 'update',
      'board': game.board,
      'turn': game.turn,
      'winner': game.winner,
      'gameOver': game.gameOver,
    }));
  }
}

void sendInit(Player player) {
  player.socket.writeln(jsonEncode({
    'type': 'init',
    'symbol': player.symbol,
  }));
}
