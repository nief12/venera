import 'package:flutter/material.dart';
import 'package:venera/foundation/appdata.dart'; // 依赖 Venera 的全局配置存储

class SniManagerDialog extends StatefulWidget {
  const SniManagerDialog({super.key});

  // 提供一个便捷的弹窗调用方法
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SniManagerDialog(),
    );
  }

  @override
  State<SniManagerDialog> createState() => _SniManagerDialogState();
}

class _SniManagerDialogState extends State<SniManagerDialog> {
  List<String> _domains = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化：从 venera 的 appdata 里读取已保存的列表
    _domains = List<String>.from(appdata.settings['customSniDomains'] ?? []);
  }

  void _saveData() {
    // 写入 venera 的 appdata 并触发持久化保存
    appdata.settings['customSniDomains'] = _domains;
    appdata.writeSettings(); // 注意：原版可能是 saveSettings() 或 writeSettings()，根据 appdata.dart 里的实际方法名调整
  }

  void _addDomain() {
    String newDomain = _controller.text.trim();
    if (newDomain.isNotEmpty && !_domains.contains(newDomain)) {
      setState(() => _domains.add(newDomain));
      _saveData();
      _controller.clear();
    }
  }

  void _removeDomain(String domain) {
    setState(() => _domains.remove(domain));
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('免 SNI 域名管理'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '例: api.pica.com',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addDomain(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addDomain,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _domains.isEmpty
                  ? const Center(child: Text('暂无配置'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _domains.length,
                      itemBuilder: (context, index) {
                        String domain = _domains[index];
                        return ListTile(
                          title: Text(domain),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeDomain(domain),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
