import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../helpers/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  var _googleSsoLoading = false;
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
    _formKey.currentState.reset();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              height: _authMode == AuthMode.Signup ? 340 : 280,
              constraints: BoxConstraints(
                minHeight: _authMode == AuthMode.Signup ? 340 : 260,
              ),
              width: deviceSize.width * 0.75,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'E-Mail'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['email'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: _authMode == AuthMode.Signup
                            ? TextInputAction.next
                            : TextInputAction.done,
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Password is too short';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                      ),
                      if (_authMode == AuthMode.Signup)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          constraints: BoxConstraints(
                            minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                            maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                          ),
                          curve: Curves.easeIn,
                          child: FadeTransition(
                            opacity: _opacityAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: TextFormField(
                                enabled: _authMode == AuthMode.Signup,
                                decoration: InputDecoration(
                                    labelText: 'Confirm Password'),
                                textInputAction: TextInputAction.done,
                                obscureText: true,
                                validator: _authMode == AuthMode.Signup
                                    ? (value) {
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Theme.of(context)
                                    .primaryTextTheme
                                    .button
                                    .color,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? 'LOGIN'
                                    : 'SIGNUP',
                              ),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 4,
                          ),
                          primary: Colors.white.withOpacity(0.6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _switchAuthMode,
                        child: Text(
                          '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _googleSsoLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.only(top: 52),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _googleSsoLoading = true;
                    });
                    try {
                      await Provider.of<Auth>(context, listen: false)
                          .signInWithGoogle();
                    } on HttpException catch (error) {
                      var errorMessage = 'Authentication failed';
                      if (error.toString().contains('EMAIL_EXISTS')) {
                        errorMessage = 'This email address is already in use.';
                      } else if (error.toString().contains('INVALID_EMAIL')) {
                        errorMessage = 'This is not a valid email address';
                      } else if (error.toString().contains('WEAK_PASSWORD')) {
                        errorMessage = 'This password is too weak.';
                      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
                        errorMessage = 'Could not find a user with that email.';
                      } else if (error
                          .toString()
                          .contains('INVALID_PASSWORD')) {
                        errorMessage = 'Invalid password.';
                      }
                      _showErrorDialog(errorMessage);
                    } catch (error) {
                      const errorMessage =
                          'Could not authenticate you. Please try again later.';
                      _showErrorDialog(errorMessage);
                    }
                    setState(() {
                      _googleSsoLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // primary: Theme.of(context).primaryColor,
                    onPrimary: Theme.of(context).primaryTextTheme.button.color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    '${_authMode == AuthMode.Signup ? 'Sign Up' : 'Login'} with Google',
                  ),
                ),
              ),
      ],
    );
  }
}
