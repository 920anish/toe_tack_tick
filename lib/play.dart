import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class PlayScreen extends StatefulWidget {
  final String userMark;

  PlayScreen({required this.userMark});

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  List<List<String?>> _board = List.generate(
      3, (_) => List.generate(3, (_) => null));
  bool _isUserTurn = true;
  bool _isGameOver = false;
  String? _winner;


  bool _isBotMoving = false; // Flag to check if the bot is currently making a move
  // late String _botMark; // Add this line

  @override
  void initState() {
    super.initState();
    // Randomly decide whether the user or the bot plays first
    bool userPlaysFirst = Random().nextBool();
    if (!userPlaysFirst) {
      // If the bot plays first, call _botMove to make its first move
      _isUserTurn = false;
      _botMove();
    }

    // Assign bot mark as 'X'
    // _botMark = 'X';
  }


  Widget _buildResultWidget() {
    if (_winner == widget.userMark) {
      return _buildResultOverlay('Congratulations! You Win!', Colors.green);
    } else if (_winner == getBotMark(widget.userMark)) {
      return _buildResultOverlay(
          'Bot Wins! Better luck next time.', Colors.red);
    } else {
      return _buildResultOverlay("It's a Draw!", Colors.blue);
    }
  }

  Widget _buildResultOverlay(String message, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withOpacity(0.8),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'Hello Graduation',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedText(),
                SizedBox(height: 50),
                _buildBoard(),
                SizedBox(height: 20),
                if (_isGameOver) _buildResultWidget(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _restartGame,
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade900, Colors.blue.shade300],
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return Text(
      _isUserTurn ? 'Your Turn (${widget.userMark})' : "Bot's Turn",
      style: TextStyle(
        fontFamily: 'Hello Graduation',
        fontSize: 32,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (row) => _buildRow(row)),
      ),
    );
  }

  Widget _buildRow(int row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (col) => _buildCell(row, col)),
    );
  }

  Widget _buildCell(int row, int col) {
    final cellValue = _board[row][col];
    return GestureDetector(
      onTap: () => _handleCellTap(row, col),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          cellValue ?? '',
          style: TextStyle(
            fontFamily: 'Hello Graduation',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleCellTap(int row, int col) {
    if (!_isGameOver && _board[row][col] == null && _isUserTurn) {
      setState(() {
        _board[row][col] = widget.userMark;
        _isUserTurn = false;
        _checkGameStatus();
        if (!_isGameOver) {
          _botMove();
        }
      });
      FlameAudio.play('zapsplat_multimedia_button_click_bright_003_92100.mp3');
    }
  }

  void _botMove() {
    if (!_isGameOver && !_isUserTurn && !_isBotMoving) {
      _isBotMoving =
      true; // Set the flag to indicate the bot is currently moving

      Timer(Duration(milliseconds: 800), () {
        final emptyCells = [];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (_board[i][j] == null) {
              emptyCells.add([i, j]);
            }
          }
        }

        if (emptyCells.isNotEmpty) {
          // Call the Minimax algorithm with Alpha-Beta pruning to get the best move for the AI
          final bestMove = _findBestMoveWithAlphaBeta();

          setState(() {
            _board[bestMove[0]][bestMove[1]] = getBotMark(widget.userMark);
            _isUserTurn = true;
            _checkGameStatus();
          });
        }

        // After the bot's move, set the flag to false
        _isBotMoving = false;
      });
    }
  }


  List<int> _findBestMoveWithAlphaBeta() {
    int bestScore = -1000;
    List<int> bestMove = [-1, -1];
    int alpha = -1000;
    int beta = 1000;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == null) {
          _board[i][j] = 'X'; // Set the mark to 'X'
          int score = _minimaxWithAlphaBeta(_board, 0, false, alpha, beta);
          _board[i][j] = null;

          if (score > bestScore) {
            bestScore = score;
            bestMove = [i, j];
          }
        }
      }
    }

    return bestMove;
  }

  int _minimaxWithAlphaBeta(List<List<String?>> board, int depth,
      bool isMaximizer, int alpha, int beta) {
    String? winner = _getWinner();
    if (winner == 'X') {
      return 10 - depth;
    } else if (winner == 'O') {
      return depth - 10;
    }

    if (_isBoardFull()) {
      return 0;
    }

    if (isMaximizer) {
      int maxScore = -1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == null) {
            board[i][j] = 'X'; // Set the mark to 'X'
            int score = _minimaxWithAlphaBeta(
                board, depth + 1, false, alpha, beta);
            board[i][j] = null;
            maxScore = max(maxScore, score);
            alpha = max(alpha, score);
            if (beta <= alpha) {
              return maxScore;
            }
          }
        }
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == null) {
            board[i][j] = widget.userMark; // Use the user's mark
            int score = _minimaxWithAlphaBeta(
                board, depth + 1, true, alpha, beta);
            board[i][j] = null;
            minScore = min(minScore, score);
            beta = min(beta, score);
            if (beta <= alpha) {
              return minScore;
            }
          }
        }
      }
      return minScore;
    }
  }



  String getBotMark(String userMark) {
    return userMark == 'O' ? 'X' : 'O';
  }

  void _checkGameStatus() {
    _winner = _getWinner();
    if (_winner != null || _isBoardFull()) {
      setState(() {
        _isGameOver = true;
      });
      _showGameOverDialog(_winner);
    }
  }

  String? _getWinner() {
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] != null &&
          _board[i][0] == _board[i][1] &&
          _board[i][0] == _board[i][2]) {
        return _board[i][0];
      }

      if (_board[0][i] != null &&
          _board[0][i] == _board[1][i] &&
          _board[0][i] == _board[2][i]) {
        return _board[0][i];
      }
    }

    if (_board[0][0] != null &&
        _board[0][0] == _board[1][1] &&
        _board[0][0] == _board[2][2]) {
      return _board[0][0];
    }

    if (_board[0][2] != null &&
        _board[0][2] == _board[1][1] &&
        _board[0][2] == _board[2][0]) {
      return _board[0][2];
    }

    return null;
  }

  bool _isBoardFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == null) {
          return false;
        }
      }
    }
    return true;
  }

  void _showGameOverDialog(String? winner) {
    String message;
    IconData iconData;
    Color iconColor;
    Color backgroundColor;
    Color buttonColor;
    if (winner == widget.userMark) {
      message = 'Congratulations! You Win!';
      iconData = Icons.sentiment_very_satisfied;
      iconColor = Colors.green;
      backgroundColor = Colors.green[50]!;
      buttonColor = Colors.green;
    } else if (winner == getBotMark(widget.userMark)) {
      message = 'Bot Wins! Better luck next time.';
      iconData = Icons.sentiment_dissatisfied;
      iconColor = Colors.red;
      backgroundColor = Colors.red[50]!;
      buttonColor = Colors.red;
    } else {
      message = "It's a Draw!";
      iconData = Icons.sentiment_neutral;
      iconColor = Colors.blue;
      backgroundColor = Colors.blue[50]!;
      buttonColor = Colors.blue;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Icon(
            iconData,
            size: 48,
            color: iconColor,
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: backgroundColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(buttonColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      FlameAudio.play('zapsplat_multimedia_button_click_bright_003_92100.mp3');
      _board = List.generate(3, (_) => List.generate(3, (_) => null));
      _isGameOver = false;
      _winner = null;

      // Randomly decide whether the user or the bot plays first
      bool userPlaysFirst = Random().nextBool();
      _isUserTurn = userPlaysFirst;

      // If the bot plays first, call _botMove to make its first move
      if (!_isUserTurn) {
        _botMove();
      }
    });
  }
}
