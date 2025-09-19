import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextReader extends StatefulWidget {
  final String filePath;
  final String bookTitle;

  const TextReader({
    super.key,
    required this.filePath,
    required this.bookTitle,
  });

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  String _content = '';
  bool _isLoading = true;
  double _fontSize = 16.0;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      final content = await rootBundle.loadString(widget.filePath);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading book content: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showReaderSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reader Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Font Size
                  Row(
                    children: [
                      const Text('Font Size: '),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 12.0,
                          max: 24.0,
                          divisions: 12,
                          onChanged: (value) {
                            setModalState(() => _fontSize = value);
                            setState(() => _fontSize = value);
                          },
                        ),
                      ),
                      Text(_fontSize.round().toString()),
                    ],
                  ),
                  
                  // Theme
                  const Text('Theme:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption('Light', Colors.white, Colors.black87, setModalState),
                      _buildThemeOption('Sepia', const Color(0xFFF5F5DC), const Color(0xFF5D4E37), setModalState),
                      _buildThemeOption('Dark', Colors.grey[900]!, Colors.white, setModalState),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(String name, Color bgColor, Color textColor, StateSetter setModalState) {
    final isSelected = _backgroundColor == bgColor;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _backgroundColor = bgColor;
          _textColor = textColor;
        });
        setState(() {
          _backgroundColor = bgColor;
          _textColor = textColor;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.bookTitle,
            style: const TextStyle(fontSize: 18),
          ),
          backgroundColor: _backgroundColor,
          foregroundColor: _textColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: _textColor),
              onPressed: _showReaderSettings,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _textColor,
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
      ),
    );
  }
}