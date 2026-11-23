part of '../view.dart';

class _Loading extends StatelessWidget {
  const _Loading({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      child: _ProductDetailsSection(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title, style: context.textTheme.headlineSmall),
                        SizedBox(height: 8.h),
                        Text(product.brand, style: context.textTheme.labelLarge),
                        SizedBox(height: 18.h),
                        Bone.text(width: 120.w, style: context.textTheme.titleLarge),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _DetailsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(width: 140.w, style: context.textTheme.titleLarge),
                        SizedBox(height: 16.h),
                        Bone.text(words: 14, style: context.textTheme.bodyLarge),
                        SizedBox(height: 8.h),
                        Bone.text(words: 10, style: context.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
