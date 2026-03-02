import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:example/screens/scheduler_screen.dart';
import 'package:example/repositories/dummy_scheduler_item_repository.dart';
import 'package:example/repositories/google_calendar_repository.dart';

class LoginScreen extends StatefulWidget {
  final bool debugView;

  const LoginScreen({super.key, this.debugView = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scope = ['https://www.googleapis.com/auth/calendar.readonly'];

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = true;
  bool _showDummyEvents = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();

      // Listen to authentication events
      GoogleSignIn.instance.authenticationEvents.listen(
        (event) {
          setState(() {
            if (event is GoogleSignInAuthenticationEventSignIn) {
              _currentUser = event.user;
            } else if (event is GoogleSignInAuthenticationEventSignOut) {
              _currentUser = null;
            }
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = '認証エラー: $error';
            _isSigningIn = false;
          });
        },
      );

      // Attempt lightweight authentication (silent sign-in)
      await GoogleSignIn.instance.attemptLightweightAuthentication();

      // サイレント認証完了後、ログイン状態に関わらず_isSigningInをfalseに
      setState(() {
        _isSigningIn = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = '初期化に失敗しました: $error';
        _isSigningIn = false;
      });
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      await GoogleSignIn.instance.authenticate();

      if (_currentUser != null) {
        try {
          await _currentUser!.authorizationClient.authorizeScopes(_scope);
        } catch (scopeError) {
          debugPrint('スコープの取得に失敗: $scopeError');
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'ログインに失敗しました: $error';
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ダミーイベント表示
    if (_showDummyEvents) {
      return SchedulerScreen(
        debugView: widget.debugView,
        repository: DummySchedulerItemRepository(),
        onLogoutTapped: () {
          setState(() => _showDummyEvents = false);
        },
      );
    }
    // ログイン済み
    if (_currentUser != null) {
      return SchedulerScreen(
        debugView: widget.debugView,
        repository: GoogleCalendarRepository(_currentUser!, _scope),
        onLogoutTapped: () async {
          await GoogleSignIn.instance.signOut();
        },
      );
    }

    // ログイン画面
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSigningIn)
              const CircularProgressIndicator()
            else ...[
              TextButton(
                onPressed: () {
                  setState(() => _showDummyEvents = true);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('ダミーイベント表示'),
              ),
              TextButton(
                onPressed: _handleSignIn,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Googleカレンダーと連携'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
