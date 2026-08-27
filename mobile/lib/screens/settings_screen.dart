import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/session_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  bool _isDarkMode = false;
  bool _saving = false;
  bool _hasError = false;
  List<String> _lastUrls = [];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString('backend_url') ?? 'http://localhost:5000';
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
    final sessionService = SessionService();
    _lastUrls = await sessionService.getLastUrls();
    if (mounted) {
      setState(() {});
    }
  }

  bool _isValidUrl(String url) {
    final pattern = r'^https?://[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)*(:\d+)?$';
    return RegExp(pattern).hasMatch(url);
  }

  Future<void> _saveSettings() async {
    final url = _urlController.text.trim();
    if (!_isValidUrl(url)) {
      setState(() => _hasError = true);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidUrl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final sessionService = SessionService();
    await sessionService.saveBackendUrl(url);
    await sessionService.saveDarkMode(_isDarkMode);
    setState(() {
      _saving = false;
      _hasError = false;
    });
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSavedRestart),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: l10n.restart,
          textColor: Colors.white,
          onPressed: () => _restartApp(),
        ),
      ),
    );
  }

  void _restartApp() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restartApp),
        content: Text(l10n.restartAppContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showIpHelpDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.howToFindIp),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.ipStep1, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _codeBlock('hostname -I'),
              const SizedBox(height: 12),
              Text(l10n.ipStep2, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _codeBlock('ip addr show | grep inet'),
              const SizedBox(height: 12),
              Text(l10n.ipStep3, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.ipStep3Content),
              const SizedBox(height: 12),
              Text(l10n.ipNote, style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _codeBlock(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'monospace')),
    );
  }

  void _showUrlHistory() {
    final l10n = AppLocalizations.of(context);
    if (_lastUrls.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.urlHistory),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _lastUrls.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_lastUrls[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    _urlController.text = _lastUrls[index];
                    Navigator.pop(ctx);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL бэкенда
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.server, style: Theme.of(context).textTheme.titleMedium),
                        if (_lastUrls.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.history),
                            onPressed: _showUrlHistory,
                            tooltip: l10n.urlHistory,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: l10n.backendUrl,
                        hintText: l10n.backendUrlHint,
                        errorText: _hasError ? l10n.invalidUrl : null,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: _showIpHelpDialog,
                          tooltip: l10n.howToFindIp,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Тема
            Card(
              child: SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.darkModeSubtitle),
                value: _isDarkMode,
                onChanged: (v) => setState(() => _isDarkMode = v),
              ),
            ),
            const Spacer(),
            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveSettings,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.saveAndRestart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}