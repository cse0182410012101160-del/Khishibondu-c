import 'package:flutter/material.dart';
import '../../../core/plugins/plugin_registry.dart';
import '../../../core/theme/app_theme.dart';

class PluginsCatalogScreen extends StatefulWidget {
  final String currentUserRole;
  const PluginsCatalogScreen({super.key, required this.currentUserRole});

  @override
  State<PluginsCatalogScreen> createState() => _PluginsCatalogScreenState();
}

class _PluginsCatalogScreenState extends State<PluginsCatalogScreen> {
  final PluginRegistry _registry = PluginRegistry();

  @override
  Widget build(BuildContext context) {
    final plugins = _registry.getAllPlugins();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extensible Plugin Registry'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plugins.length,
        itemBuilder: (context, index) {
          final plugin = plugins[index];
          final isActive = _registry.isPluginActive(plugin.id);
          final isSupportedRole = plugin.enabledRoles.contains(widget.currentUserRole) || widget.currentUserRole == 'admin';

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(plugin.icon, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plugin.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'v${plugin.version} • ${plugin.enabledRoles.join(", ")}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: widget.currentUserRole == 'admin'
                            ? (val) {
                                setState(() {
                                  _registry.setPluginActive(plugin.id, val);
                                });
                              }
                            : null, // Only admin can toggle system-wide flags
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plugin.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  if (isActive && isSupportedRole)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => plugin.buildScreen(ctx)),
                          );
                        },
                        icon: const Icon(Icons.launch, size: 16),
                        label: const Text('Open Feature'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

