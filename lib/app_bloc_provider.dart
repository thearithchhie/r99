import 'package:r99/export.dart';

class AppBlocsProvider extends StatelessWidget {
  final Widget child;

  const AppBlocsProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
    // return MultiBlocProvider(
    //   providers: [
    //     // BlocProvider<AnnouncementCubit>(create: (context) => AnnouncementCubit(DependencyHelper.dependency)),
    //   ],
    //   child: child,
    // );
  }
}
