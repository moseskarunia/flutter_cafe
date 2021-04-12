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

  const WaffleTopping({
    required this.title,
    Key? key,
    this.width,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [title];

    if (content != null) {
      children.add(content!);
    }

    Widget main = children.length > 1 ? Column(children: children) : title;

    if (width == null) return main;

    return Container(width: width, child: main);
  }
}
