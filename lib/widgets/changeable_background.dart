import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:transparent_image/transparent_image.dart';

import '../data/providers.dart';

class ChangeableBackground extends ConsumerWidget {
  const ChangeableBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(currentBackgroundImageProvider);

    return Container(
      color: Colors.grey.shade900,
      child: AnimatedSwitcher(
        duration: defaultAnimationDuration,
        child: SizedBox.expand(
          key: ValueKey(image),
          child: image != null
              ? Opacity(
                  opacity: 0.3,
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    fadeInDuration: defaultAnimationDuration,
                    fadeOutDuration: defaultAnimationDuration,
                    image: image,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class BackgroundWrapper extends ConsumerStatefulWidget {
  const BackgroundWrapper({
    Key? key,
    required this.child,
    this.image,
  }) : super(key: key);

  final ImageProvider? image;
  final Widget child;

  @override
  ConsumerState<BackgroundWrapper> createState() => _BackgroundWrapperState();
}

class _BackgroundWrapperState extends ConsumerState<BackgroundWrapper>
    with RouteAware {
  bool allowedToUpdate = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .watch(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didUpdateWidget(covariant BackgroundWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image && allowedToUpdate) {
      _updateImage(widget.image);
    }
  }

  @override
  void dispose() {
    ref.watch(routeObserverProvider).unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _updateImage(widget.image);
    allowedToUpdate = true;
  }

  @override
  void didPushNext() {
    allowedToUpdate = false;
  }

  @override
  void didPop() {
    allowedToUpdate = false;
  }

  @override
  void didPopNext() {
    _updateImage(widget.image);
    allowedToUpdate = true;
  }

  void _updateImage(ImageProvider? newImage) {
    Future.microtask(() {
      ref.read(currentBackgroundImageProvider.state).state = widget.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
