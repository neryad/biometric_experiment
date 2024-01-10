import 'package:biometric_experiment/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = ' No autoauthorized';
  bool _isAuthoticating = false;
  _SupportedState _supportedState = _SupportedState.unknown;
  bool? _canCheckBiometrics;

  List<BiometricType>? _avaibleBiometricType;

  @override
  void initState() {
    super.initState();

    auth.isDeviceSupported().then((bool IsSupported) => setState(() =>
        _supportedState = IsSupported
            ? _SupportedState.supported
            : _SupportedState.unsupported));
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometric;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometric = false;
      print(e);
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometric;
    });
  }

  Future<void> _getAvaibleByometric() async {
    late List<BiometricType> avaibleByometricTypes;

    try {
      avaibleByometricTypes = await auth.getAvailableBiometrics();
    } catch (e) {
      avaibleByometricTypes = <BiometricType>[];
      print(e);
    }
    setState(() {
      _avaibleBiometricType = avaibleByometricTypes;
    });
  }

  Future<void> _authenticate() async {
    bool authenticate = false;
    try {
      setState(() {
        _isAuthoticating = true;
        _authorized = ' Is authenticating';
      });

      authenticate = await auth.authenticate(
          localizedReason: 'Let system pick the method',
          options: const AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true));

      setState(() {
        _isAuthoticating = false;
      });
    } catch (e) {
      _isAuthoticating = false;
      _authorized = 'Error: $e';
      print(e);
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Welcome()));
  }

  Future<void> _authenticatedWithByometrics() async {
    bool aunthenticated = false;

    try {
      setState(() {
        _isAuthoticating = true;
        _authorized = ' Is authenticating';
      });

      aunthenticated = await auth.authenticate(
          localizedReason: 'Scan your finger o face',
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: true));

      setState(() {
        _isAuthoticating = false;
        _authorized = 'authenticating';
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Welcome()));
    } catch (e) {
      _isAuthoticating = false;
      _authorized = 'Error: $e';
      print(e);
    }
    final String message = aunthenticated ? 'Authorized' : 'not authorized';

    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelByometric() async {
    await auth.stopAuthentication();

    setState(() {
      _isAuthoticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            if (_supportedState == _SupportedState.unknown)
              const CircularProgressIndicator()
            else if (_supportedState == _SupportedState.supported)
              const Text('Lo aguanta')
            else
              const Text('No Lo aguanta'),
            const Divider(),
            ElevatedButton(
                onPressed: _checkBiometrics, child: Text('Valdiar biometrycs')),
            ElevatedButton(
                onPressed: _getAvaibleByometric,
                child: Text(
                    'lista de tipos byometricos : $_avaibleBiometricType')),
            Text('Estado actual: $_authorized'),
            ElevatedButton(onPressed: _authenticate, child: Text('Autenticar')),
            ElevatedButton(
                onPressed: () {
                  _authenticatedWithByometrics();
                },
                child: Text('Autenticar Byometrics')),
          ],
        ),
      ),
    );
  }
}

enum _SupportedState { unknown, supported, unsupported }
