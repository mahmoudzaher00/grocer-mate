import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

class BaseTextField extends StatefulWidget {
  const BaseTextField({
    super.key,
    this.controller,
    this.password = false,
    this.readOnly = false,
    this.closeKeyboardOnTapOutside = true,
    this.fillColorTextFiled,
    this.inputFormatters,
    this.filledColorTextFiled,
    this.textType,
    this.hintStyle,
    this.hintText,
    this.onChangedFunction,
    this.validatorFunction,
    this.onEditingCompleteFunction,
    this.focusNode,
    this.textInputAction,
    this.prefixIconWidget,
    this.suffixIcon,
    this.height,
    this.width,
    this.contentVerticalPadding,
    this.labelText,
    this.labelStyle,
    this.cursorColor,
    this.onFieldSubmitted,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.widthBorder,
    this.maxLines,
    this.errorTextStyle,
    this.enabledBorderRadius,
    this.focusedBorderRadius,
    this.inputTextStyle,
    this.focusedErrorBorderRadius,
    this.errorBorderRadius,
    this.errorMaxLines,
    this.isShadow = false,
    this.hintTextSize,
    this.suffix,
    this.inputTextColor,
    this.inputTextSize,
    this.suffixText,
    this.suffixTextSize,
    this.borderFromBottom = false,
    this.contentHorizontalPadding,
    this.onSaved,
    this.initialValue,
    this.textCapitalization,
    this.autoValidateMode,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final bool password;
  final Color? fillColorTextFiled;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool closeKeyboardOnTapOutside;
  final bool? filledColorTextFiled;
  final TextInputType? textType;
  final TextStyle? hintStyle;
  final TextStyle? inputTextStyle;
  final String? hintText;
  final ValueChanged<String>? onChangedFunction;
  final FormFieldValidator<String>? validatorFunction;
  final VoidCallback? onEditingCompleteFunction;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Widget? prefixIconWidget;
  final Widget? suffixIcon;
  final bool? isShadow;
  final double? height;
  final double? width;
  final double? contentVerticalPadding;
  final double? contentHorizontalPadding;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextStyle? errorTextStyle;
  final Color? cursorColor;
  final ValueChanged<String>? onFieldSubmitted;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final double? enabledBorderRadius;
  final double? errorBorderRadius;
  final double? focusedBorderRadius;
  final double? focusedErrorBorderRadius;
  final double? hintTextSize;
  final double? widthBorder;
  final int? maxLines;
  final int? errorMaxLines;
  final Widget? suffix;
  final Color? inputTextColor;
  final double? inputTextSize;
  final String? suffixText;
  final double? suffixTextSize;
  final bool? borderFromBottom;
  final void Function(String?)? onSaved;
  final TextCapitalization? textCapitalization;
  final AutovalidateMode? autoValidateMode;
  final Iterable<String>? autofillHints;

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width ?? MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: widget.isShadow! ? ShadowManager.shadow : ShadowManager.noShadow,
        borderRadius: widget.isShadow! ? BorderRadius.circular(widget.enabledBorderRadius!) : BorderRadius.zero,
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        autovalidateMode: widget.autoValidateMode,
        autofillHints: widget.autofillHints,
        onTapOutside: widget.closeKeyboardOnTapOutside ? (_) => FocusManager.instance.primaryFocus?.unfocus() : null,
        enableSuggestions: true,
        readOnly: widget.readOnly,
        style:
            widget.inputTextStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: widget.inputTextSize ?? 14, fontWeight: FontWeight.w500, color: widget.inputTextColor ?? kTextPrimary),
        cursorColor: widget.cursorColor ?? kPrimary,
        keyboardType: widget.textType ?? TextInputType.text,
        inputFormatters: widget.inputFormatters,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? '',
          floatingLabelStyle: widget.labelStyle ?? Theme.of(context).textTheme.bodySmall!.copyWith(color: kGrey50, fontSize: 14),
          errorMaxLines: widget.errorMaxLines ?? 1,
          errorStyle: widget.errorTextStyle ?? Theme.of(context).textTheme.bodySmall!.copyWith(color: kDarkRed, height: 1.8),
          labelText: widget.labelText,
          labelStyle: widget.labelStyle ?? Theme.of(context).textTheme.labelSmall!.copyWith(color: kGrey50, fontSize: 12),
          hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.labelSmall!.copyWith(color: kGrey98, fontSize: widget.hintTextSize ?? 14),
          fillColor: widget.fillColorTextFiled ?? kWhite,
          filled: widget.filledColorTextFiled ?? true,
          prefixIcon: widget.prefixIconWidget,
          prefixIconConstraints: const BoxConstraints(minWidth: 40, maxWidth: 40.0, maxHeight: 50.0),
          suffixIcon: widget.suffixIcon ?? _suffixIcon(),
          suffix: widget.suffix,
          suffixText: widget.suffixText,
          suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(color: kGrey50, fontSize: widget.suffixTextSize ?? 14),
          enabledBorder: widget.borderFromBottom!
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor ?? kBorder, width: widget.widthBorder ?? 1),
                )
              : OutlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor ?? kBorder, width: widget.widthBorder ?? 1),
                  borderRadius: BorderRadius.circular(widget.enabledBorderRadius ?? 8),
                ),
          focusedBorder: widget.borderFromBottom!
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor ?? kBorder, width: widget.widthBorder ?? 1),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.focusedBorderRadius ?? 8),
                  borderSide: BorderSide(color: widget.focusedBorderColor ?? kBorder, width: widget.widthBorder ?? 1),
                ),
          errorBorder: widget.borderFromBottom!
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor ?? kErrorLight, width: widget.widthBorder ?? 1),
                )
              : OutlineInputBorder(
                  borderSide: const BorderSide(color: kErrorLight, width: 1),
                  borderRadius: BorderRadius.circular(widget.errorBorderRadius ?? 8),
                ),
          focusedErrorBorder: widget.borderFromBottom!
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor ?? kErrorLight, width: widget.widthBorder ?? 1),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.focusedErrorBorderRadius ?? 8),
                  borderSide: const BorderSide(color: kErrorLight, width: 1),
                ),
          contentPadding: EdgeInsets.symmetric(horizontal: widget.contentHorizontalPadding ?? 8, vertical: widget.contentVerticalPadding ?? 12),
        ),
        onChanged: widget.onChangedFunction,
        onSaved: widget.onSaved,
        focusNode: widget.focusNode,
        maxLines: widget.maxLines ?? 1,
        onEditingComplete: widget.onEditingCompleteFunction,
        validator: widget.validatorFunction,
        textInputAction: widget.textInputAction,
        obscureText: _obscureText,
      ),
    );
  }

  Widget? _suffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    return widget.password
        ? IconButton(
            color: kTextInverse,
            onPressed: () {
              setState(() => _obscureText = !_obscureText);
            },
            icon: Icon(_obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: kTextInverse, size: 18),
          )
        : null;
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.dispose();
    }
    super.dispose();
  }
}
