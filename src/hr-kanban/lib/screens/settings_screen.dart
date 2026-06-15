import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/state_views.dart';

class SettingsScreen extends StatefulWidget {
  final ApiService api;
  const SettingsScreen({super.key, required this.api});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _testing = false;
  String? _error;
  Map<String, dynamic>? _config;

  final _serverUrlCtl = TextEditingController();
  final _providerCtl = TextEditingController();
  final _modelCtl = TextEditingController();
  final _apiKeyCtl = TextEditingController();
  final _apiUrlCtl = TextEditingController();
  final _promptTemplateCtl = TextEditingController();
  final _temperatureCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _serverUrlCtl.dispose();
    _providerCtl.dispose();
    _modelCtl.dispose();
    _apiKeyCtl.dispose();
    _apiUrlCtl.dispose();
    _promptTemplateCtl.dispose();
    _temperatureCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _serverUrlCtl.text = widget.api.baseUrl;
    try {
      _config = await widget.api.getAIConfig();
      _providerCtl.text = _config?['provider'] ?? '';
      _modelCtl.text = _config?['model'] ?? '';
      _apiKeyCtl.text = _config?['api_key'] ?? '';
      _apiUrlCtl.text = _config?['api_url'] ?? '';
      _promptTemplateCtl.text = _config?['prompt_template'] ?? '';
      _temperatureCtl.text = _config?['temperature']?.toString() ?? '0.7';
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.updateAIConfig({
        'provider': _providerCtl.text,
        'model': _modelCtl.text,
        'api_key': _apiKeyCtl.text,
        'api_url': _apiUrlCtl.text,
        'prompt_template': _promptTemplateCtl.text,
        'temperature': double.tryParse(_temperatureCtl.text) ?? 0.7,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('配置已保存'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      final result = await widget.api.testAIConnection();
      if (mounted) {
        final ok = result['ok'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? '连接成功' : '连接失败: ${result['error'] ?? '未知错误'}'),
            backgroundColor: ok
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 设置'),
        actions: [
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _testing ? null : _test,
                  icon: _testing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onSecondary,
                          ),
                        )
                      : const Icon(Icons.wifi_find, size: 14),
                  label: Text(
                    _testing ? '测试中' : '测试连接',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(theme, onSurface),
    );
  }

  Widget _buildBody(ThemeData theme, Color onSurface) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(error: _error!, onRetry: _load);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务端连接',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provider API 地址',
            style: TextStyle(fontSize: 13, color: onSurface.withAlpha(150)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _field('服务器地址', _serverUrlCtl, 'http://127.0.0.1:8080'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.save, size: 20),
                tooltip: '保存服务器地址',
                onPressed: () {
                  final url = _serverUrlCtl.text.trim();
                  if (url.isNotEmpty) {
                    widget.api.baseUrl = url;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('服务器地址已更新: $url'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: onSurface.withAlpha(20)),
          const SizedBox(height: 16),
          Text(
            'AI 分类配置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '配置 AI 模型用于简历自动分类',
            style: TextStyle(fontSize: 13, color: onSurface.withAlpha(150)),
          ),
          const SizedBox(height: 20),

          _field('供应商', _providerCtl, '例如: openai, azure, ollama'),
          _field('模型', _modelCtl, '例如: gpt-4o, deepseek-chat'),
          _field('API Key', _apiKeyCtl, 'API 密钥', obscure: true),
          _field('API URL', _apiUrlCtl, 'API 地址（可选）'),
          _field(
            '温度参数',
            _temperatureCtl,
            '0.0 - 2.0，默认 0.7',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),
          Text(
            '提示词模板',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promptTemplateCtl,
            style: TextStyle(fontSize: 13, color: onSurface),
            maxLines: 10,
            decoration: InputDecoration(
              hintText: '自定义分类提示词（可选）',
              hintStyle: TextStyle(
                color: onSurface.withAlpha(80),
                fontSize: 13,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: onSurface.withAlpha(30)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onSecondary,
                      ),
                    )
                  : const Text('保存配置', style: TextStyle(fontSize: 15)),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctl,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctl,
        style: TextStyle(fontSize: 14, color: onSurface),
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: onSurface.withAlpha(150), fontSize: 14),
          hintText: hint,
          hintStyle: TextStyle(color: onSurface.withAlpha(80), fontSize: 13),
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: onSurface.withAlpha(30)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
