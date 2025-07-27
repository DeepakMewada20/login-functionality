import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BiometricSetupPage(),
      routes: {
        '/biometric-setup': (context) => BiometricSetupPage(),
        '/biometric-login': (context) => BiometricLoginPage(),
      },
    );
  }
}

// Biometric Setup Page
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

// Biometric Login Page
class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  _BiometricLoginPageState createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  bool _isAuthenticating = false;
  List<BiometricType> _availableBiometrics = [];

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

    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _getAvailableBiometrics();
    _startPulseAnimation();
  }

  Future<void> _getAvailableBiometrics() async {
    try {
      List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      setState(() {
        _availableBiometrics = availableBiometrics;
      });
    } catch (e) {
      print('Error getting available biometrics: $e');
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
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
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Use your biometric to access your account',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              Spacer(),

              // Biometric Icon with Animation
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: GestureDetector(
                              onTap: _authenticate,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue, Colors.blue.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getBiometricIcon(),
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 40),

              // Status Text
              Text(
                _isAuthenticating ? 'Authenticating...' : 'Tap to authenticate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              Spacer(),

              // Alternative Login Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAlternativeOption(
                    icon: Icons.password,
                    label: 'Use Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password login not implemented'),
                        ),
                      );
                    },
                  ),
                  _buildAlternativeOption(
                    icon: Icons.pattern,
                    label: 'Use Pattern',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pattern login not implemented'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Try Again Button
              OutlinedButton(
                onPressed: _authenticate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.blue),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(icon, size: 24, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility;
    } else {
      return Icons.security;
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );

      if (didAuthenticate) {
        _pulseController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _triggerShakeAnimation();
      }
    } on PlatformException catch (e) {
      _triggerShakeAnimation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
