import 'package:flutter/material.dart';
import '../utils/themes.dart';

// Custom Text Field
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
        ),
      ),
    );
  }
}

// Custom Button
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// Loading Indicator
class CustomLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const CustomLoadingIndicator({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: AppTheme.spacing16),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

// Empty State
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: AppTheme.spacing8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: AppTheme.spacing24),
            CustomButton(text: 'Retry', onPressed: onRetry!, width: 120),
          ],
        ],
      ),
    );
  }
}

// Provider Card
class ProviderCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final String experience;
  final String? imageUrl;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.experience,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 80);
                        },
                      )
                    : Icon(Icons.person, size: 80),
              ),
              SizedBox(height: AppTheme.spacing12),
              // Name
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTheme.spacing4),
              // Category
              Text(category, style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: AppTheme.spacing8),
              // Rating
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    '$rating ($reviews reviews)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing8),
              // Experience
              Text(
                '$experience years experience',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Dropdown (replaces broken DropdownButtonFormField)
class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const CustomDropdown({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.cast<DropdownMenuItem<T>?>().firstWhere(
          (item) => item?.value == value,
          orElse: () => null,
        );

    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<T>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          label ?? 'Select',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(height: 1),
                      ...items.map((item) => ListTile(
                            title: Text(item.child is Text ? (item.child as Text).data ?? '' : ''),
                            onTap: () => Navigator.pop(ctx, item.value),
                            selected: item.value == field.value,
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            );
            if (result != null) {
              field.didChange(result);
              onChanged?.call(result);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
              ),
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              selectedItem?.child is Text
                  ? (selectedItem!.child as Text).data ?? ''
                  : '',
            ),
          ),
        );
      },
    );
  }
}

// Star Rating (interactive - replaces flutter_rating_bar)
class StarRating extends StatelessWidget {
  final double initialRating;
  final int itemCount;
  final ValueChanged<double>? onRatingUpdate;
  final double size;

  const StarRating({
    super.key,
    this.initialRating = 0,
    this.itemCount = 5,
    this.onRatingUpdate,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return _StarRatingState(
      initialRating: initialRating,
      itemCount: itemCount,
      onRatingUpdate: onRatingUpdate,
      size: size,
    );
  }
}

class _StarRatingState extends StatefulWidget {
  final double initialRating;
  final int itemCount;
  final ValueChanged<double>? onRatingUpdate;
  final double size;

  const _StarRatingState({
    required this.initialRating,
    required this.itemCount,
    this.onRatingUpdate,
    required this.size,
  });

  @override
  State<_StarRatingState> createState() => _StarRatingStateImpl();
}

class _StarRatingStateImpl extends State<_StarRatingState> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () {
            setState(() => _rating = starValue);
            widget.onRatingUpdate?.call(starValue);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              starValue <= _rating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: Colors.orange,
            ),
          ),
        );
      }),
    );
  }
}

// Star Rating Display (read-only)
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int itemCount;
  final double size;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.itemCount = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final starValue = index + 1.0;
        if (starValue <= rating) {
          return Icon(Icons.star, size: size, color: Colors.orange);
        } else if (starValue - 0.5 <= rating) {
          return Icon(Icons.star_half, size: size, color: Colors.orange);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.orange);
        }
      }),
    );
  }
}
