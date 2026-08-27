import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_status.dart';
import '../l10n/app_localizations.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionStatus = context.watch<ConnectionStatus>();
    final l10n = AppLocalizations.of(context);
    final isConnected = connectionStatus.isConnected;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isConnected ? Icons.circle : Icons.circle_outlined,
          size: 12,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          isConnected ? l10n.connected : l10n.disconnected,
          style: TextStyle(
            fontSize: 12,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
