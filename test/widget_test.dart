import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/main.dart';
import 'package:ayodex/core/constants/app_strings.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';

class FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  FakeAuthController() : super(const AuthState());

  @override
  Future<void> initialize() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  Future<bool> login(String username, String password) async => true;

  @override
  Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool agree,
    String? reference,
  }) async => true;

  @override
  Future<bool> completeProfile({
    required String countryCode,
    required String country,
    required String mobileCode,
    required String username,
    required String mobile,
    String? address,
    String? city,
    String? stateName,
    String? zip,
  }) async => true;

  @override
  Future<void> logout() async {}

  @override
  void clearError() {}

  @override
  void setUser(UserModel user) {}
}

void main() {
  testWidgets('AyodexApp smoke test boots router and renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => FakeAuthController()),
        ],
        child: const AyodexApp(),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
  });
}
