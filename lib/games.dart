// games.dart - FULL VERSION
// TIC TAC TOE + CATUR + SLOT GAME

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  int _selectedIndex = 0;
  final List<Widget> _gameWidgets = [
    const TicTacToeGame(),
    const ChessGame(),
    const SlotGame(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0505),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🎮 MINI GAME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            letterSpacing: 1,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.blueGrey.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
      body: _gameWidgets[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E3A8A).withOpacity(0.9),
              const Color(0xFF0F0505),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFEF5350),
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_3x3),
              label: 'Tic Tac Toe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.casino),
              label: 'Catur',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.casino_rounded),
              label: 'Slot',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TIC TAC TOE GAME ─────────────────────────────────────────────────────────
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  String _currentPlayer = 'X';
  List<String> _board = List.filled(9, '');
  String? _winner;
  bool _gameOver = false;
  bool _isPlayingVsBot = false;
  String _botLevel = 'medium';
  
  int _playerScore = 0;
  int _botScore = 0;
  int _draws = 0;
  
  int _playerTime = 300;
  int _botTime = 300;
  Timer? _timer;
  bool _isPlayerTurn = true;
  
  final Map<String, double> _botDifficulty = {
    'low': 0.3,
    'medium': 0.6,
    'hard': 0.9,
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver || !_isPlayingVsBot) return;
      
      setState(() {
        if (_isPlayerTurn) {
          if (_playerTime > 0) {
            _playerTime--;
          } else {
            _gameOver = true;
            _winner = 'O';
            _botScore++;
            _timer?.cancel();
            _showGameOverDialog();
          }
        } else {
          if (_botTime > 0) {
            _botTime--;
          }
        }
      });
    });
  }

  void _makeMove(int index) {
    if (_gameOver || _board[index] != '' || !_isPlayerTurn) return;
    
    setState(() {
      _board[index] = _currentPlayer;
      final winner = _checkWinner(_board);
      final isDraw = !_board.contains('') && winner == null;
      
      if (winner != null || isDraw) {
        _gameOver = true;
        _winner = winner ?? 'Draw';
        _timer?.cancel();
        
        if (winner == 'X') _playerScore++;
        else if (winner == 'O') _botScore++;
        else _draws++;
        
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameOverDialog();
        });
      } else {
        _currentPlayer = 'O';
        _isPlayerTurn = false;
        
        if (_isPlayingVsBot) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _makeBotMove();
          });
        }
      }
    });
  }

  void _makeBotMove() {
    if (_gameOver) return;
    
    final emptyIndices = _board.asMap().entries
        .where((entry) => entry.value == '')
        .map((entry) => entry.key)
        .toList();
    
    if (emptyIndices.isEmpty) return;
    
    int botMoveIndex;
    
    if (_botLevel == 'hard' && Random().nextDouble() < _botDifficulty['hard']!) {
      botMoveIndex = _findBestMove();
    } else if (_botLevel == 'medium' && Random().nextDouble() < _botDifficulty['medium']!) {
      if (Random().nextBool()) {
        botMoveIndex = _findBestMove();
      } else {
        botMoveIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      }
    } else {
      botMoveIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
    }
    
    setState(() {
      _board[botMoveIndex] = 'O';
      final winner = _checkWinner(_board);
      final isDraw = !_board.contains('') && winner == null;
      
      if (winner != null || isDraw) {
        _gameOver = true;
        _winner = winner ?? 'Draw';
        _timer?.cancel();
        
        if (winner == 'O') _botScore++;
        else if (winner == 'X') _playerScore++;
        else _draws++;
        
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameOverDialog();
        });
      } else {
        _currentPlayer = 'X';
        _isPlayerTurn = true;
      }
    });
  }

  int _findBestMove() {
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        List<String> tempBoard = List.from(_board);
        tempBoard[i] = 'O';
        if (_checkWinner(tempBoard) == 'O') return i;
      }
    }
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        List<String> tempBoard = List.from(_board);
        tempBoard[i] = 'X';
        if (_checkWinner(tempBoard) == 'X') return i;
      }
    }
    if (_board[4] == '') return 4;
    List<int> corners = [0, 2, 6, 8];
    corners.shuffle();
    for (int corner in corners) {
      if (_board[corner] == '') return corner;
    }
    final emptyIndices = _board.asMap().entries
        .where((entry) => entry.value == '')
        .map((entry) => entry.key)
        .toList();
    return emptyIndices[Random().nextInt(emptyIndices.length)];
  }

  String? _checkWinner(List<String> board) {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final combo in winningCombinations) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[0]] == board[combo[2]]) {
        return board[combo[0]];
      }
    }
    return null;
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
      _gameOver = false;
      _playerTime = 300;
      _botTime = 300;
      _isPlayerTurn = true;
    });
    _startTimer();
  }

  void _startVsBot(String level) {
    setState(() {
      _isPlayingVsBot = true;
      _botLevel = level;
      _playerScore = 0;
      _botScore = 0;
      _draws = 0;
      _resetGame();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        title: Center(
          child: Text(
            _winner == 'Draw' ? 'SERI!' : 'MENANG!',
            style: TextStyle(
              color: _winner == 'X' ? const Color(0xFFEF5350) : 
                     _winner == 'O' ? const Color(0xFFEF4444) : 
                     const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Text(
            _winner == 'Draw' 
              ? 'Permainan berakhir seri!' 
              : _winner == 'X'
                ? 'Anda menang!'
                : 'Bot menang!',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame();
                },
                child: const Text('MAIN LAGI', style: TextStyle(color: Color(0xFFEF5350))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isPlayingVsBot = false;
                  });
                },
                child: const Text('KELUAR', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D0A0A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('ANDA', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF5350),
              )),
              const SizedBox(height: 4),
              Text('$_playerScore', style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
              Text(
                _formatTime(_playerTime),
                style: TextStyle(
                  color: _isPlayerTurn ? const Color(0xFFEF4444) : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text('SERI', style: TextStyle(
                fontSize: 14,
                color: Color(0xFFEF4444),
              )),
              const SizedBox(height: 4),
              Text('$_draws', style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              )),
            ],
          ),
          Column(
            children: [
              Text(
                _isPlayingVsBot ? 'BOT' : 'LAWAN',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 4),
              Text('$_botScore', style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
              Text(
                _formatTime(_botTime),
                style: TextStyle(
                  color: !_isPlayerTurn ? const Color(0xFFEF4444) : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _makeMove(index),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _board[index] == 'X' 
                  ? const Color(0xFFEF5350)
                  : _board[index] == 'O'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF3D0A0A),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _board[index].isNotEmpty
                    ? (_board[index] == 'X' 
                        ? const Color(0xFFEF5350).withOpacity(0.3)
                        : const Color(0xFFEF4444).withOpacity(0.3))
                    : Colors.transparent,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _board[index],
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _board[index] == 'X' 
                    ? const Color(0xFFEF5350)
                    : const Color(0xFFEF4444),
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: _board[index] == 'X'
                        ? const Color(0xFFEF5350).withOpacity(0.5)
                        : const Color(0xFFEF4444).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainMenu() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF0F0505),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.grid_3x3,
                    size: 64,
                    color: const Color(0xFFEF5350),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TIC TAC TOE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih mode permainan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'VS BOT',
                    style: TextStyle(
                      color: const Color(0xFFEF5350),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDifficultyButton('MUDAH', 'low', const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildDifficultyButton('SEDANG', 'medium', const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildDifficultyButton('SULIT', 'hard', const Color(0xFFEF4444)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String text, String level, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _startVsBot(level),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              level == 'low' ? Icons.arrow_circle_down :
              level == 'medium' ? Icons.arrow_circle_right :
              Icons.arrow_circle_up,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3D0A0A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL: ${_botLevel.toUpperCase()}',
                      style: TextStyle(
                        color: _botLevel == 'low' ? const Color(0xFFEF4444) :
                               _botLevel == 'medium' ? const Color(0xFFEF4444) :
                               const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlayerTurn ? 'Giliran Anda' : 'Giliran Bot',
                      style: TextStyle(
                        color: _isPlayerTurn ? const Color(0xFFEF4444) : const Color(0xFFEF4444),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  'GILIRAN: $_currentPlayer',
                  style: TextStyle(
                    color: _currentPlayer == 'X' 
                      ? const Color(0xFFEF5350)
                      : const Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isPlayingVsBot = false;
                      _resetGame();
                    });
                  },
                  icon: const Icon(Icons.exit_to_app, color: Color(0xFFEF4444)),
                  tooltip: 'Kembali ke Menu',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildScoreBoard(),
          const SizedBox(height: 20),
          
          Expanded(
            child: _buildGameBoard(),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh),
              label: const Text('ULANGI PERMAINAN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0505),
      body: !_isPlayingVsBot ? _buildMainMenu() : _buildGameScreen(),
    );
  }
}

// ─── CHESS GAME ───────────────────────────────────────────────────────────────
class ChessGame extends StatefulWidget {
  const ChessGame({super.key});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  String _botLevel = 'medium';
  bool _isPlayingVsBot = false;
  bool _isWhite = true;
  bool _isPlayerTurn = true;
  bool _gameOver = false;
  String _winner = '';
  
  int _playerScore = 0;
  int _botScore = 0;
  int _draws = 0;
  
  int _playerTime = 600;
  int _botTime = 600;
  Timer? _timer;
  
  List<List<String>> _board = [
    ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
    ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['', '', '', '', '', '', '', ''],
    ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
    ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
  ];
  
  List<List<bool>> _possibleMoves = List.generate(8, (_) => List.filled(8, false));
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver || !_isPlayingVsBot) return;
      
      setState(() {
        if (_isPlayerTurn) {
          if (_playerTime > 0) {
            _playerTime--;
          } else {
            _gameOver = true;
            _winner = 'Bot';
            _botScore++;
            _timer?.cancel();
            _showGameOverDialog();
          }
        } else {
          if (_botTime > 0) {
            _botTime--;
          } else {
            _gameOver = true;
            _winner = 'Player';
            _playerScore++;
            _timer?.cancel();
            _showGameOverDialog();
          }
        }
      });
    });
  }

  void _selectPiece(int row, int col) {
    if (_gameOver || !_isPlayerTurn) return;
    
    final piece = _board[row][col];
    if (piece.isEmpty) return;
    
    final isWhitePiece = piece == piece.toUpperCase();
    if ((_isWhite && !isWhitePiece) || (!_isWhite && isWhitePiece)) {
      _showMessage('Ini bukan bidakmu!');
      return;
    }

    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _calculatePossibleMoves(row, col);
    });
  }

  void _calculatePossibleMoves(int row, int col) {
    _possibleMoves = List.generate(8, (_) => List.filled(8, false));
    final piece = _board[row][col].toLowerCase();
    
    switch (piece) {
      case 'p':
        final direction = _board[row][col] == 'P' ? -1 : 1;
        if (_isInBoard(row + direction, col) && _board[row + direction][col].isEmpty) {
          _possibleMoves[row + direction][col] = true;
        }
        if (_isInBoard(row + direction, col - 1) && _board[row + direction][col - 1].isNotEmpty) {
          _possibleMoves[row + direction][col - 1] = true;
        }
        if (_isInBoard(row + direction, col + 1) && _board[row + direction][col + 1].isNotEmpty) {
          _possibleMoves[row + direction][col + 1] = true;
        }
        break;
      case 'r':
        _calculateRookMoves(row, col);
        break;
      case 'n':
        _calculateKnightMoves(row, col);
        break;
      case 'b':
        _calculateBishopMoves(row, col);
        break;
      case 'q':
        _calculateRookMoves(row, col);
        _calculateBishopMoves(row, col);
        break;
      case 'k':
        _calculateKingMoves(row, col);
        break;
    }
  }

  void _calculateRookMoves(int row, int col) {
    const directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (final dir in directions) {
      var r = row + dir[0];
      var c = col + dir[1];
      while (_isInBoard(r, c)) {
        if (_board[r][c].isEmpty) {
          _possibleMoves[r][c] = true;
        } else {
          if (_isOpponentPiece(row, col, r, c)) {
            _possibleMoves[r][c] = true;
          }
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }
  }

  void _calculateBishopMoves(int row, int col) {
    const directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    for (final dir in directions) {
      var r = row + dir[0];
      var c = col + dir[1];
      while (_isInBoard(r, c)) {
        if (_board[r][c].isEmpty) {
          _possibleMoves[r][c] = true;
        } else {
          if (_isOpponentPiece(row, col, r, c)) {
            _possibleMoves[r][c] = true;
          }
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }
  }

  void _calculateKnightMoves(int row, int col) {
    const moves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    for (final move in moves) {
      final r = row + move[0];
      final c = col + move[1];
      if (_isInBoard(r, c) && 
          (_board[r][c].isEmpty || _isOpponentPiece(row, col, r, c))) {
        _possibleMoves[r][c] = true;
      }
    }
  }

  void _calculateKingMoves(int row, int col) {
    const moves = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1]
    ];
    for (final move in moves) {
      final r = row + move[0];
      final c = col + move[1];
      if (_isInBoard(r, c) && 
          (_board[r][c].isEmpty || _isOpponentPiece(row, col, r, c))) {
        _possibleMoves[r][c] = true;
      }
    }
  }

  bool _isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool _isOpponentPiece(int fromRow, int fromCol, int toRow, int toCol) {
    final fromPiece = _board[fromRow][fromCol];
    final toPiece = _board[toRow][toCol];
    if (toPiece.isEmpty) return false;
    
    final fromIsWhite = fromPiece == fromPiece.toUpperCase();
    final toIsWhite = toPiece == toPiece.toUpperCase();
    return fromIsWhite != toIsWhite;
  }

  void _makeMove(int toRow, int toCol) {
    if (_selectedRow == null || _selectedCol == null || !_possibleMoves[toRow][toCol]) {
      return;
    }

    if (_gameOver || !_isPlayerTurn) return;

    setState(() {
      final capturedPiece = _board[toRow][toCol];
      
      if (capturedPiece.toLowerCase() == 'k') {
        _gameOver = true;
        _winner = _board[_selectedRow!][_selectedCol!] == _board[_selectedRow!][_selectedCol!].toUpperCase() 
            ? 'Player' 
            : 'Bot';
        
        if (_winner == 'Player') {
          _playerScore++;
        } else {
          _botScore++;
        }
        
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameOverDialog();
        });
      }

      _board[toRow][toCol] = _board[_selectedRow!][_selectedCol!];
      _board[_selectedRow!][_selectedCol!] = '';

      _selectedRow = null;
      _selectedCol = null;
      _possibleMoves = List.generate(8, (_) => List.filled(8, false));
      
      if (_isPlayingVsBot) {
        _isPlayerTurn = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          _makeBotMove();
        });
      }
    });
  }

  void _makeBotMove() {
    if (_gameOver) return;
    
    List<Map<String, dynamic>> allMoves = [];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece.isNotEmpty && piece != piece.toUpperCase()) {
          _calculatePossibleMoves(row, col);
          for (int toRow = 0; toRow < 8; toRow++) {
            for (int toCol = 0; toCol < 8; toCol++) {
              if (_possibleMoves[toRow][toCol]) {
                allMoves.add({
                  'fromRow': row,
                  'fromCol': col,
                  'toRow': toRow,
                  'toCol': toCol,
                  'piece': piece,
                  'capture': _board[toRow][toCol].isNotEmpty,
                  'isKing': _board[toRow][toCol].toLowerCase() == 'k',
                });
              }
            }
          }
        }
      }
    }
    
    if (allMoves.isEmpty) return;
    
    Map<String, dynamic> selectedMove;
    
    if (_botLevel == 'hard') {
      final captures = allMoves.where((move) => move['capture']).toList();
      if (captures.isNotEmpty) {
        captures.shuffle();
        selectedMove = captures.first;
      } else {
        allMoves.shuffle();
        selectedMove = allMoves.first;
      }
    } else if (_botLevel == 'medium') {
      final captures = allMoves.where((move) => move['capture']).toList();
      if (captures.isNotEmpty && Random().nextBool()) {
        captures.shuffle();
        selectedMove = captures.first;
      } else {
        allMoves.shuffle();
        selectedMove = allMoves.first;
      }
    } else {
      allMoves.shuffle();
      selectedMove = allMoves.first;
    }
    
    setState(() {
      final capturedPiece = _board[selectedMove['toRow']][selectedMove['toCol']];
      
      if (capturedPiece.toLowerCase() == 'k') {
        _gameOver = true;
        _winner = 'Bot';
        _botScore++;
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameOverDialog();
        });
      }
      
      _board[selectedMove['toRow']][selectedMove['toCol']] = _board[selectedMove['fromRow']][selectedMove['fromCol']];
      _board[selectedMove['fromRow']][selectedMove['fromCol']] = '';
      
      _isPlayerTurn = true;
    });
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _board = [
        ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
        ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
        ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
      ];
      _playerTime = 600;
      _botTime = 600;
      _gameOver = false;
      _winner = '';
      _selectedRow = null;
      _selectedCol = null;
      _possibleMoves = List.generate(8, (_) => List.filled(8, false));
      _isPlayerTurn = true;
    });
    _startTimer();
  }

  void _startVsBot(String level) {
    setState(() {
      _isPlayingVsBot = true;
      _botLevel = level;
      _playerScore = 0;
      _botScore = 0;
      _draws = 0;
      _resetGame();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        title: Center(
          child: Text(
            _winner == 'Draw' ? 'SERI!' : 'CHECKMATE!',
            style: TextStyle(
              color: _winner == 'Player' ? const Color(0xFFEF5350) : 
                     _winner == 'Bot' ? const Color(0xFFEF4444) : 
                     const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Text(
            _winner == 'Draw' 
              ? 'Permainan berakhir seri!' 
              : '${_winner == 'Player' ? 'Anda' : 'Bot'} memenangkan permainan!',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame();
                },
                child: const Text('MAIN LAGI', style: TextStyle(color: Color(0xFFEF5350))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isPlayingVsBot = false;
                  });
                },
                child: const Text('KELUAR', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildChessBoard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final col = index % 8;
          final isWhite = (row + col) % 2 == 0;
          final piece = _board[row][col];
          final isSelected = row == _selectedRow && col == _selectedCol;
          final isPossibleMove = _possibleMoves[row][col];

          return GestureDetector(
            onTap: () {
              if (_possibleMoves[row][col]) {
                _makeMove(row, col);
              } else {
                _selectPiece(row, col);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                  ? const Color(0xFFEF4444).withOpacity(0.5)
                  : isPossibleMove
                  ? const Color(0xFFEF4444).withOpacity(0.3)
                  : isWhite
                  ? const Color(0xFFF0D9B5)
                  : const Color(0xFFB58863),
                border: Border.all(
                  color: isSelected
                    ? const Color(0xFFEF4444)
                    : Colors.transparent,
                  width: 2,
                ),
              ),
              child: piece.isNotEmpty
                ? Center(
                    child: Text(
                      _getPieceSymbol(piece),
                      style: TextStyle(
                        fontSize: 30,
                        color: piece == piece.toUpperCase()
                          ? const Color(0xFFF0F0F0)
                          : const Color(0xFF1A0A0A),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
            ),
          );
        },
      ),
    );
  }

  String _getPieceSymbol(String piece) {
    switch (piece.toLowerCase()) {
      case 'k': return '♔';
      case 'q': return '♕';
      case 'r': return '♖';
      case 'b': return '♗';
      case 'n': return '♘';
      case 'p': return '♙';
      default: return '';
    }
  }

  Widget _buildMainMenu() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F0505),
                    const Color(0xFF1A0A0A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.casino,
                    size: 64,
                    color: const Color(0xFFF0D9B5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CATUR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih mode permainan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'VS BOT',
                    style: TextStyle(
                      color: const Color(0xFFF0D9B5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDifficultyButton('MUDAH', 'low', const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildDifficultyButton('SEDANG', 'medium', const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildDifficultyButton('SULIT', 'hard', const Color(0xFFEF4444)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String text, String level, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _startVsBot(level),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              level == 'low' ? Icons.arrow_circle_down :
              level == 'medium' ? Icons.arrow_circle_right :
              Icons.arrow_circle_up,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D0A0A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                _isWhite ? 'PUTIH' : 'HITAM',
                style: const TextStyle(
                  color: Color(0xFFF0D9B5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('$_playerScore', style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
              Text(
                _formatTime(_playerTime),
                style: TextStyle(
                  color: _isPlayerTurn ? const Color(0xFFEF4444) : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text('SERI', style: TextStyle(
                color: Color(0xFFEF4444),
              )),
              const SizedBox(height: 4),
              Text('$_draws', style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              )),
            ],
          ),
          Column(
            children: [
              Text(
                'BOT',
                style: const TextStyle(
                  color: Color(0xFFB58863),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('$_botScore', style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
              Text(
                _formatTime(_botTime),
                style: TextStyle(
                  color: !_isPlayerTurn ? const Color(0xFFEF4444) : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3D0A0A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL: ${_botLevel.toUpperCase()}',
                      style: TextStyle(
                        color: _botLevel == 'low' ? const Color(0xFFEF4444) :
                               _botLevel == 'medium' ? const Color(0xFFEF4444) :
                               const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isPlayerTurn ? 'Giliran Anda' : 'Giliran Bot',
                      style: TextStyle(
                        color: _isPlayerTurn ? const Color(0xFFEF4444) : const Color(0xFFEF4444),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isPlayingVsBot = false;
                          _resetGame();
                        });
                      },
                      icon: const Icon(Icons.exit_to_app, color: Color(0xFFEF4444)),
                      tooltip: 'Kembali ke Menu',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildScoreBoard(),
          
          const SizedBox(height: 20),
          
          Expanded(child: _buildChessBoard()),
          
          const SizedBox(height: 20),
          
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ULANGI PERMAINAN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0505),
      body: !_isPlayingVsBot ? _buildMainMenu() : _buildGameScreen(),
    );
  }
}

// ─── SLOT GAME ───────────────────────────────────────────────────────────────
class SlotGame extends StatefulWidget {
  const SlotGame({super.key});

  @override
  State<SlotGame> createState() => _SlotGameState();
}

class _SlotGameState extends State<SlotGame> {
  final List<String> _symbols = ['🍒', '🍋', '🍊', '🍇', '🔔', '💎', '7️⃣'];
  final List<Color> _symbolColors = [
    Colors.red, Colors.yellow, Colors.orange, Colors.purple,
    Colors.amber, Colors.cyan, Colors.redAccent,
  ];
  
  List<String> _reels = ['🍒', '🍋', '🍊'];
  List<Color> _reelColors = [Colors.red, Colors.yellow, Colors.orange];
  
  int _balance = 1000;
  int _bet = 50;
  int _lastWin = 0;
  bool _isSpinning = false;
  String _resultMessage = '';
  Color _resultColor = Colors.white;
  
  int _totalSpins = 0;
  int _totalWins = 0;
  int _jackpotCount = 0;
  
  final Random _random = Random();

  void _spin() {
    if (_isSpinning) return;
    if (_bet > _balance) {
      _showMessage('Saldo tidak cukup!');
      return;
    }
    
    setState(() {
      _isSpinning = true;
      _resultMessage = '';
      _lastWin = 0;
      _balance -= _bet;
    });
    
    int spinCount = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < 3; i++) {
          final idx = _random.nextInt(_symbols.length);
          _reels[i] = _symbols[idx];
          _reelColors[i] = _symbolColors[idx];
        }
      });
      
      spinCount++;
      if (spinCount >= 15) {
        timer.cancel();
        _checkResult();
      }
    });
  }

  void _checkResult() {
    setState(() {
      _isSpinning = false;
      _totalSpins++;
      
      final isJackpot = _reels[0] == _reels[1] && _reels[1] == _reels[2];
      final isTwoSame = _reels[0] == _reels[1] || _reels[1] == _reels[2] || _reels[0] == _reels[2];
      final hasSeven = _reels.contains('7️⃣');
      final hasDiamond = _reels.contains('💎');
      
      int winMultiplier = 0;
      
      if (isJackpot) {
        if (_reels[0] == '7️⃣') {
          winMultiplier = 50;
          _jackpotCount++;
          _resultMessage = '🎰 JACKPOT 777! 🎰';
          _resultColor = Colors.amber;
        } else {
          winMultiplier = 10;
          _resultMessage = '🎉 JACKPOT! 🎉';
          _resultColor = Colors.amber;
        }
      } else if (hasSeven && hasDiamond) {
        winMultiplier = 8;
        _resultMessage = '💎 Lucky Spin! 💎';
        _resultColor = Colors.cyan;
      } else if (isTwoSame && hasSeven) {
        winMultiplier = 5;
        _resultMessage = '🌟 Almost Jackpot! 🌟';
        _resultColor = Colors.amber;
      } else if (isTwoSame && hasDiamond) {
        winMultiplier = 4;
        _resultMessage = '💎 Nice! 💎';
        _resultColor = Colors.cyan;
      } else if (isTwoSame) {
        winMultiplier = 2;
        _resultMessage = '✅ You Win! ✅';
        _resultColor = Colors.green;
      } else {
        _resultMessage = '❌ Try Again ❌';
        _resultColor = Colors.red;
      }
      
      if (winMultiplier > 0) {
        _lastWin = _bet * winMultiplier;
        _balance += _lastWin;
        _totalWins++;
      }
    });
  }

  void _setBet(int amount) {
    setState(() {
      _bet = amount;
    });
  }

  void _resetGame() {
    setState(() {
      _balance = 1000;
      _reels = ['🍒', '🍋', '🍊'];
      _reelColors = [Colors.red, Colors.yellow, Colors.orange];
      _bet = 50;
      _lastWin = 0;
      _resultMessage = '';
      _totalSpins = 0;
      _totalWins = 0;
      _jackpotCount = 0;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0505),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── SALDO & BET ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0A0A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3D0A0A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('💰 SALDO', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('$_balance', style: const TextStyle(
                        color: Color(0xFFEF5350),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                      )),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('🎯 TARUHAN', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Color(0xFFEF4444)),
                            onPressed: _isSpinning ? null : () => _setBet(max(10, _bet - 10)),
                          ),
                          Text('$_bet', style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFEF5350)),
                            onPressed: _isSpinning ? null : () => _setBet(min(500, _bet + 10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ─── REELS ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A0A0A),
                    const Color(0xFF2A0A0A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return Container(
                    width: 70,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0505),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _reelColors[index].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _reels[index],
                        style: TextStyle(
                          fontSize: 48,
                          color: _reelColors[index],
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: _reelColors[index].withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ─── RESULT MESSAGE ────────────────────────────────────────────
            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _resultColor.withOpacity(0.3)),
                ),
                child: Text(
                  _resultMessage,
                  style: TextStyle(
                    color: _resultColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            if (_lastWin > 0)
              Text(
                '+$_lastWin',
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // ─── SPIN BUTTON ───────────────────────────────────────────────
            GestureDetector(
              onTap: _spin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: _isSpinning
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFFF5252)],
                      ),
                  color: _isSpinning ? const Color(0xFF1A1A1A) : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSpinning ? Colors.white24 : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: _isSpinning
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                ),
                child: Center(
                  child: _isSpinning
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '🎰 SPIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ─── STATISTICS ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3D0A0A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('SPIN', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text('$_totalSpins', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('MENANG', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text('$_totalWins', style: const TextStyle(color: Colors.green, fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('JACKPOT', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text('$_jackpotCount', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('RTP', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(
                        '${_totalSpins > 0 ? ((_totalWins / _totalSpins) * 100).toStringAsFixed(0) : 0}%',
                        style: const TextStyle(color: Colors.amber, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ─── RESET ──────────────────────────────────────────────────────
            GestureDetector(
              onTap: _resetGame,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Text(
                    '🔄 Reset Game',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}