// import '../../utils/extensions/context_extensions.dart';
// import 'package:material_ui/material_ui.dart';
// import 'package:lottie/lottie.dart';
//
// import '../../resources/asset_manager.dart';
//
// class LottieLoader extends StatelessWidget {
//   const LottieLoader({super.key, this.lottieName, this.height, this.width});
//
//   final String? lottieName;
//   final double? height;
//   final double? width;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Lottie.asset(
//         lottieName ?? JsonAssets.logout,
//         width: width ?? context.width * .7,
//         height: height,
//         // height: height??context.height*.5,
//         repeat: true,
//         animate: true,
//
//         onLoaded: (composition) {},
//         fit: BoxFit.fill,
//       ),
//     );
//   }
// }
