import 'package:flutter/material.dart';

enum AdTextType { display, headline, title, body, label, monospace }

class AdText extends StatelessWidget {
  final String text;
  final AdTextType type;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdText(
    this.text, {
    super.key,
    this.type = AdTextType.body,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AdText.display(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.display,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  factory AdText.headline(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.headline,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  factory AdText.title(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.title,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  factory AdText.body(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.body,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  factory AdText.label(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.label,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  factory AdText.monospace(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AdText(
    text,
    type: AdTextType.monospace,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    TextStyle? style;

    switch (type) {
      case AdTextType.display:
        style = textTheme.displayMedium;
        break;
      case AdTextType.headline:
        style = textTheme.headlineMedium;
        break;
      case AdTextType.title:
        style = textTheme.titleMedium;
        break;
      case AdTextType.body:
        style = textTheme.bodyMedium;
        break;
      case AdTextType.label:
        style = textTheme.labelMedium;
        break;
      case AdTextType.monospace:
        style = textTheme.bodyMedium?.copyWith(fontFamily: 'monospace');
        break;
    }

    if (color != null || fontWeight != null) {
      style = style?.copyWith(color: color, fontWeight: fontWeight);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
