import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ProfilMenuItem extends StatelessWidget {
  const ProfilMenuItem({
    super.key,
    this.title,
    this.label,
    required this.icon,
    this.onTap,
  });
  final String? title;
  final String? label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title ?? label ?? ''),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
