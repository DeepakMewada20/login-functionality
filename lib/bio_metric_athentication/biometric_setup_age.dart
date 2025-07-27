import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  _BiometricSetupPageState createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _canCheckBiometrics = false;
  bool _isBiometricSupported = false;
  List<BiometricType> _availableBiometrics = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _isBiometricSupported = isDeviceSupported;
        _availableBiometrics = availableBiometrics;
      });
    } catch (e) {
      print('Error checking biometric support: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              // Header
              Text(
                'Secure Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Enable biometric authentication for quick and secure access',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              // Biometric Options
              if (_isBiometricSupported && _availableBiometrics.isNotEmpty)
                ..._buildBiometricOptions()
              else
                _buildUnsupportedMessage(),

              Spacer(),

              // Action Buttons
              if (_isBiometricSupported && _availableBiometrics.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: _setupBiometric,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Enable Biometric Authentication',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
              ],

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/biometric-login');
                },
                child: Text(
                  'Skip for Now',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBiometricOptions() {
    List<Widget> options = [];

    for (BiometricType type in _availableBiometrics) {
      IconData icon;
      String title;
      String description;
      Color color;

      switch (type) {
        case BiometricType.fingerprint:
          icon = Icons.fingerprint;
          title = 'Fingerprint';
          description = 'Use your fingerprint to unlock';
          color = Colors.blue;
          break;
        case BiometricType.face:
          icon = Icons.face;
          title = 'Face ID';
          description = 'Use your face to unlock';
          color = Colors.green;
          break;
        case BiometricType.iris:
          icon = Icons.visibility;
          title = 'Iris Scanner';
          description = 'Use your iris to unlock';
          color = Colors.purple;
          break;
        default:
          icon = Icons.security;
          title = 'Biometric';
          description = 'Use biometric authentication';
          color = Colors.orange;
      }

      options.add(
        Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
        ),
      );
    }

    return options;
  }

  Widget _buildUnsupportedMessage() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.security_outlined, size: 50, color: Colors.grey),
        ),
        SizedBox(height: 30),
        Text(
          'Biometric Not Available',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Your device doesn\'t support biometric authentication or no biometrics are enrolled.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _setupBiometric() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication enabled successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to biometric login page
        Navigator.pushReplacementNamed(context, '/biometric-login');
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
