import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Future<void> showMenuOptions({
  required BuildContext context,
  required List<MenuOption> options,
  String? title,
}) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionBuilder: (context, anim1, anim2, child) {
      return SharedAxisTransition(
        animation: anim1,
        secondaryAnimation: anim2,
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent,
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      final textTheme = Theme.of(context).textTheme;
      return Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1, color: Colors.white30),
              ],
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        title: Text(option.title),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        trailing: option.icon,
                        onTap: () {
                          Navigator.pop(context);
                          option.onTap();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MenuOption {
  final String title;
  final String? description;
  final Icon icon;
  final VoidCallback onTap;

  const MenuOption({
    required this.title,
    this.description,
    required this.icon,
    required this.onTap,
  });
}
