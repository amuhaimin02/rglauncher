import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class TwoLineGridView extends ConsumerStatefulWidget {
  const TwoLineGridView({
    Key? key,
    required this.items,
    this.childPadding,
    this.padding,
  }) : super(key: key);

  final List<TwoLineItem> items;
  final EdgeInsets? childPadding;
  final EdgeInsets? padding;

  @override
  ConsumerState<TwoLineGridView> createState() => TwoLineGridViewState();
}

class TwoLineGridViewState extends ConsumerState<TwoLineGridView> {
  late List<Widget> _arrangedChildren;

  Widget? _tempWidget;
  late List<VoidCallback?> _itemCommands;

  late final _scrollController = AutoScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _arrangeChildren();
  }

  void _arrangeChildren() {
    int itemIndex = 0;
    _arrangedChildren = [];

    for (final item in widget.items) {
      if (item is TwoLineGridItem) {
        if (item.large) {
          // Large item that span two rows
          _placeTempWidgetAlone();
          _arrangedChildren.add(_itemToWidget(item, itemIndex++));
        } else {
          if (_tempWidget != null) {
            // Item at the bottom row (we merge two items in a single column)
            _arrangedChildren.add(
                _mergeChildren(_tempWidget!, _itemToWidget(item, itemIndex++)));
            _tempWidget = null;
          } else {
            // Item at the top row (will be used at next iteration)
            _tempWidget = _itemToWidget(item, itemIndex++);
          }
        }
      } else if (item is TwoLineDivider) {
        _placeTempWidgetAlone();
        _arrangedChildren.add(item);
      }
    }
    if (_tempWidget != null) {
      _placeTempWidgetAlone();
    }

    _itemCommands = widget.items
        .whereType<TwoLineGridItem>()
        .map((e) => (e).onTap)
        .toList();
  }

  Widget _mergeChildren(Widget child1, Widget child2) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: widget.childPadding ?? EdgeInsets.zero,
              child: child1,
            ),
          ),
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: widget.childPadding ?? EdgeInsets.zero,
              child: child2,
            ),
          ),
        ),
      ],
    );
  }

  void _placeTempWidgetAlone() {
    if (_tempWidget != null) {
      _arrangedChildren.add(_mergeChildren(_tempWidget!, const SizedBox()));
      _tempWidget = null;
    }
  }

  Widget _itemToWidget(TwoLineGridItem item, int index) {
    return AutoScrollTag(
      index: index,
      key: ValueKey(index),
      controller: _scrollController,
      child: Padding(
        padding: widget.childPadding ?? EdgeInsets.zero,
        child: TwoLineHighlight(
          index: index,
          child: InkWell(
            onTap: () {
              ref.read(selectedMenuIndexProvider.state).state = index;
              item.onTap?.call();
            },
            child: item.aspectRatio != 1
                ? AspectRatio(
                    aspectRatio: item.aspectRatio,
                    child: item.child,
                  )
                : item.child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedMenuIndexProvider, (previousIndex, newIndex) {
      _scrollController.scrollToIndex(newIndex,
          preferPosition: AutoScrollPosition.middle);
    });
    return ListView(
      padding: widget.padding,
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      children: _arrangedChildren,
    );
  }

  void launchItemAtIndex(int index) {
    if (index < 0 || index > _itemCommands.length) {
      throw RangeError.range(index, 0, _itemCommands.length);
    }
    _itemCommands[index]?.call();
  }
}

class TwoLineItem {}

class TwoLineGridItem extends StatelessWidget implements TwoLineItem {
  const TwoLineGridItem({
    Key? key,
    required this.child,
    this.onTap,
    this.aspectRatio = 1,
    this.large = false,
  }) : super(key: key);

  final Widget child;
  final double aspectRatio;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class TwoLineDivider extends StatelessWidget implements TwoLineItem {
  const TwoLineDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: Colors.white38,
      ),
    );
  }
}

class TwoLineHighlight extends ConsumerWidget {
  const TwoLineHighlight({
    Key? key,
    required this.child,
    required this.index,
  }) : super(key: key);

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedMenuIndexProvider);
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedContainer(
              duration: defaultAnimationDuration,
              curve: defaultAnimationCurve,
              decoration: BoxDecoration(
                border: selectedIndex == index
                    ? Border.all(color: Colors.white, width: 4)
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
