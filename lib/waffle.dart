import 'dart:io';

import 'package:flutter/material.dart';

/// Card widget to be display a complex row of a table.
/// A waffle is divided into several columns, each column has
/// [WaffleTopping] as children.
///
/// When a waffle is long tapped, it switches into flavor editing mode.
/// Flavor is a local marker to make complex filtering easier.
///
/// You can attach both [onTap] and [onLongPress] to the waffle.
class Waffle extends StatelessWidget {
  /// Widget to display at the top most of the [Waffle].
  /// Usually a row of flavors
  final Widget? header;

  /// Columns of the Waffle, usually uses [WaffleTopping].
  /// Will be placed as a row children.
  final List<Widget> columns;

  /// Widget to display at the bottom-most of the [Waffle]
  final Widget? footer;

  final void Function(BuildContext)? onTap, onLongPress;

  const Waffle({
    Key? key,
    required this.columns,
    this.footer,
    this.header,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (header != null) {
      children.add(header!);
    }

    children.add(Row(children: columns));

    if (footer != null) {
      children.add(footer!);
    }

    Widget card = Card(
      child: children.length == 1
          ? Row(children: columns)
          : Column(children: children),
    );

    if (onTap == null && onLongPress == null) {
      return card;
    }

    return InkWell(
      onTap: onTap != null ? () => onTap!(context) : null,
      onLongPress: onLongPress != null ? () => onLongPress!(context) : null,
      child: card,
    );
  }
}

/// Topping is the preferred widget for [Waffle] columns
class WaffleTopping extends StatelessWidget {
  /// Width of the topping. Will have unbounded width if null
  final double? width;

  /// The main information of the column. Usually a bodyText2 styled text.
  final Widget title;

  /// The supporting informations of the column. Usually a column.
  /// If using text as one of column children, it's recommended to have smaller
  /// text size than [title]. (e.g. caption / overline)
  final Widget? content;

  final EdgeInsetsGeometry? margin, padding;

  const WaffleTopping({
    required this.title,
    Key? key,
    this.width,
    this.content,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [title];

    if (content != null) {
      children.add(content!);
    }

    Widget main = children.length > 1
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        : title;

    if (width == null && padding == null && margin == null) return main;

    return Container(
      margin: margin,
      padding: padding,
      width: width,
      child: main,
    );
  }

  /// A waffle topping with title and icons and content texts.
  /// Each [contentTexts] will be styled with caption, wrapped with Expanded,
  /// and spaced 16 wide with the icon.
  ///
  /// * [titleText] - Will be styled with bodyText2
  /// * [icons] will be paired with [contentText] based on their index. Both must
  /// have identical length, otherwise will throw an AssertionError.
  factory WaffleTopping.asTitleAndColumnOfIconAndCaptions({
    required BuildContext context,
    required String titleText,
    required List<Widget> icons,
    required List<String> contentTexts,
    Key? key,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
  }) {
    if (icons.length != contentTexts.length) {
      throw AssertionError(
          'icons and contentTexts should have identical length');
    }

    Widget title = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titleText,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );

    Widget content = Column(
      children: List<int>.generate(icons.length, (i) => i)
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  icons[i],
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      contentTexts[i],
                      style: Theme.of(context).textTheme.caption,
                    ),
                  )
                ],
              ),
            ),
          )
          .toList(),
    );

    return WaffleTopping(
      key: key,
      title: title,
      content: content,
      margin: margin,
      padding: padding,
      width: width,
    );
  }
}
