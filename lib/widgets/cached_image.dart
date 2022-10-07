import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rglauncher/data/configs.dart';

class CachedImage extends StatelessWidget {
  const CachedImage(this.link, {Key? key}) : super(key: key);

  final String link;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fadeInDuration: defaultAnimationDuration,
      imageUrl: link,
    );
  }
}
