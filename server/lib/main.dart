import 'dart:io';
import 'dart:convert';

import 'game.dart';
import 'player.dart';
import 'protocol.dart';

void main() async {
  const port = 4040;
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
  print('Server Tris avviato sulla porta $port');

  final game = Game();

  server.listen((socket) async {
    if (game.isFull) {
      print('Giocatore rifiutato: partita piena');
      socket.writeln(jsonEncode({'type': 'full'}));
      socket.close();
      return;
    }

    // Assegna simbolo X o O
    final symbol = game.players.isEmpty ? 'X' : 'O';
    final player = Player(socket, symbol);
    game.addPlayer(player);

    print('Giocatore $symbol connesso');

    // Invia messaggio di inizializzazione
    sendInit(player);

    // Se due giocatori sono connessi, invia stato iniziale
    if (game.isFull) {
      broadcastGameState(game);
    }

    // Gestione messaggi dal client
    socket.listen((data) {
      handleMessage(game, player, data);
    }, onDone: () {
      print('Giocatore $symbol disconnesso');
      game.players.remove(player);
      // Reset partita se un giocatore se ne va
      game.board = List.filled(9, '');
      game.turn = 0;
      game.winner = null;
      game.gameOver = false;
      // Avvisa gli altri
      broadcastGameState(game);
    }, onError: (error) {
      print('Errore socket: $error');
    });
  });
}
