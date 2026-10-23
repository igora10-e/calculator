import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _rows = [
    ['C', '⌫', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', ',', '='],
  ];

  String _display = '0';
  String _expression = '';
  double? _firstNumber;
  String? _operation;
  bool _startNewNumber = true;
  bool _hasError = false;

  String _format(double value) {
    final rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded == 0) return '0';

    return rounded.toString().replaceFirst(RegExp(r'\.0$'), '');
  }

  void _clear() {
    _display = '0';
    _expression = '';
    _firstNumber = null;
    _operation = null;
    _startNewNumber = true;
    _hasError = false;
  }

  void _showError(String message) {
    _clear();
    _display = 'Erro';
    _expression = message;
    _hasError = true;
  }

  void _input(String label) {
    final digit = label == ',' ? '.' : label;

    if (_startNewNumber) {
      if (_operation == null) _expression = '';

      _display = digit == '.' ? '0.' : digit;
      _startNewNumber = false;
      return;
    }

    if (digit == '.') {
      if (!_display.contains('.')) _display += '.';
      return;
    }

    final digits = _display.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 15) return;

    _display = _display == '0' ? digit : '$_display$digit';
  }

  void _backspace() {
    if (_startNewNumber) return;

    if (_display.length <= 1 ||
        (_display.startsWith('-') && _display.length == 2)) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  bool _calculate() {
    final first = _firstNumber;
    final operation = _operation;

    if (first == null || operation == null) return false;

    final second = double.parse(_display);

    if (operation == '÷' && second == 0) {
      _showError('Não é possível dividir por zero');
      return false;
    }

    final result = switch (operation) {
      '+' => first + second,
      '−' => first - second,
      '×' => first * second,
      '÷' => first / second,
      _ => double.nan,
    };

    if (!result.isFinite) {
      _showError('Resultado fora do limite');
      return false;
    }

    _expression = '${_format(first)} $operation ${_format(second)} =';
    _display = _format(result);
    return true;
  }

  void _selectOperation(String operation) {
    if (_operation != null && !_startNewNumber) {
      if (!_calculate()) return;
    }

    _firstNumber = double.parse(_display);
    _operation = operation;
    _expression = '$_display $operation';
    _startNewNumber = true;
  }

  void _equals() {
    if (_operation == null || _startNewNumber) return;
    if (!_calculate()) return;

    _firstNumber = null;
    _operation = null;
    _startNewNumber = true;
  }

  void _press(String label) {
    setState(() {
      if (label == 'C') {
        _clear();
        return;
      }

      final isInput = RegExp(r'^[0-9,]$').hasMatch(label);

      if (_hasError) {
        if (!isInput) return;
        _clear();
      }

      if (isInput) {
        _input(label);
      } else if (label == '⌫') {
        _backspace();
      } else if (label == '=') {
        _equals();
      } else if (['+', '−', '×', '÷'].contains(label)) {
        _selectOperation(label);
      }
    });
  }

  Widget _buildButton(String label) {
    final isOperation = ['÷', '×', '−', '+'].contains(label);

    final background = switch (label) {
      'C' => const Color(0xFFFF4141),
      '⌫' => const Color(0xFFFF9D28),
      '=' => const Color(0xFF32AF58),
      _ => isOperation ? const Color(0xFF039BE5) : const Color(0xFFE0E0E0),
    };

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox.expand(
          child: FilledButton(
            onPressed: () => _press(label),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: background,
              foregroundColor: isOperation ? Colors.white : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: label == '⌫'
                ? const Icon(Icons.backspace_outlined, size: 24)
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        title: const Text(
          'Calculadora',
          style: TextStyle(fontSize: 22, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFA8C4FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: const [
          IconButton(
            onPressed: null,
            tooltip: 'Histórico',
            disabledColor: Colors.black54,
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
                    color: const Color(0xFFDADADD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression.replaceAll('.', ','),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _display.replaceAll('.', ','),
                                key: const Key('calculator-display'),
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    child: Column(
                      children: [
                        for (final row in _rows)
                          Expanded(
                            child: Row(
                              children: [
                                for (final label in row) _buildButton(label),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
