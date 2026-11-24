part of '../view.dart';

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _taglineOpacity;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scheduleEntranceAnimation();
    _scheduleNavigation();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(duration: AppConstants.splashAnimationDuration, vsync: this);

    _logoScale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.58, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.28, curve: Curves.easeOut),
    );

    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 0.72, curve: Curves.easeOut),
    );

    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.32, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.62, 1, curve: Curves.easeOut),
    );
  }

  void _scheduleEntranceAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final reduceMotion = MediaQuery.disableAnimationsOf(context);

      if (reduceMotion) {
        _entranceController.value = 1;
      } else {
        _entranceController.forward();
      }
    });
  }

  void _scheduleNavigation() {
    _navigationTimer = Timer(AppConstants.splashNavigationDelay, () {
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(categoriesRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorScheme.surface, colorScheme.surfaceContainer, theme.scaffoldBackgroundColor]),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BackgroundAccent(alignment: const Alignment(-1.35, -1.15), size: 260.r, color: kPrimaryLight),
          _BackgroundAccent(alignment: const Alignment(1.4, 1.2), size: 300.r, color: kPrimary),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SlidingLogo(opacity: _logoOpacity, scale: _logoScale),
                    SizedBox(height: 28.h),
                    _SlidingTextGroup(opacity: _titleOpacity, offset: _titleOffset),
                    SizedBox(height: 14.h),
                    _FadeText(opacity: _taglineOpacity),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }
}
