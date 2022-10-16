import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Future<void> showMenuDialog({
  required BuildContext context,
  List<MenuOption>? options,
  List<Widget>? body,
  String? title,
  EdgeInsets padding = EdgeInsets.zero,
}) async {
  assert((options != null) ^ (body != null),
      'Only either one of body or options can not be null');
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
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
              if (body != null)
                Flexible(
                  child: Scrollbar(
                    child: ListView(
                      padding: padding,
                      shrinkWrap: true,
                      children: body,
                    ),
                  ),
                )
              else if (options != null)
                Flexible(
                  child: Scrollbar(
                    child: GridView.count(
                      crossAxisCount: 3,
                      padding: padding,
                      shrinkWrap: true,
                      children: [
                        for (final option in options)
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              option.onTap();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: const IconThemeData(
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                    child: option.icon,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${option.title}\n',
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // ListTile(
                        //   title: Text(option.title),
                        //   contentPadding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 4),
                        //   trailing: option.icon,
                        //   onTap: () {
                        //     Navigator.pop(context);
                        //     option.onTap();
                        //   },
                        // ),
                      ],
                    ),
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
