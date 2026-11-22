part of '../view.dart';

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with TickerProviderStateMixin {
  static const Duration _navigationDelay = Duration(milliseconds: 2600);

  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _taglineOpacity;

  Timer? _navigationTimer;
  bool _animationsStarted = false;

  @override
  void initState() {
    super.initState();
    _initSlidingAnimation();
    _navigateToNextScreen();
  }

  void _initSlidingAnimation() {
    _entranceController = AnimationController(duration: const Duration(milliseconds: 1400), vsync: this);

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

  void _navigateToNextScreen() {
    _navigationTimer = Timer(_navigationDelay, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(categoriesRoute);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_animationsStarted) return;
    _animationsStarted = true;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entranceController.value = 1;
      return;
    }

    _entranceController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorScheme.surface, colorScheme.surfaceContainer, context.theme.scaffoldBackgroundColor]),
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
