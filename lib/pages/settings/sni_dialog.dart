import 'package:flutter/material.dart';
import 'package:venera/foundation/appdata.dart'; // 引入 venera 的存储

class SniDialog extends StatefulWidget {
  const SniDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const SniDialog());
  }

  @override
  State<SniDialog> createState() => _SniDialogState();
}

class _SniDialogState extends State<SniDialog> {
  List<String> _domains = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 页面加载时，读取数据
    _domains = List<String>.from(appdata.settings['customSniDomains'] ?? []);
  }

  void _saveData() {
    // 存入 venera 的全局字典
    appdata.settings['customSniDomains'] = _domains;
    // Venera 内部通常会自动监听字典变化，如果有专门的 write() 方法可以写在下面
  }

  void _add() {
    String val = _controller.text.trim();
    if (val.isNotEmpty && !_domains.contains(val)) {
      setState(() => _domains.add(val));
      _saveData();
      _controller.clear();
    }
  }

  void _remove(String val) {
    setState(() => _domains.remove(val));
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('免 SNI 域名 (用于直连)'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '如: api.pica.com'),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _add),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _domains.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_domains[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _remove(_domains[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
