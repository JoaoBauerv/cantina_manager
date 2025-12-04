import 'package:flutter/material.dart';
import 'package:flutter_application_1/global.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/login/login_response.dart';

// BLoC imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Login Events
abstract class LoginEvent {}
class LoginSubmitted extends LoginEvent {
  final String user;
  final String pass;
  LoginSubmitted(this.user, this.pass);
}

// Login States
abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final LoginResponse data;
  LoginSuccess(this.data);
}
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

// Login BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final url = Uri.parse('http://10.0.2.2:8000/api');
        final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': event.user,
          'senha': event.pass,
        }),
      );

        if (response.statusCode == 200) {
          final jsonBody = jsonDecode(response.body);

          final loginData = LoginResponse.fromJson(jsonBody);

          emit(LoginSuccess(loginData));

        } else if (response.statusCode == 404) {
          emit(LoginError('Usuário não encontrado.')); 
        } else {
          emit(LoginError('Erro inesperado. Código: \${response.statusCode}'));
        }
      } catch (e) {
        emit(LoginError('Falha na requisição: \${e.toString()}'));
      }
    });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocProvider(
        create: (_) => LoginBloc(),
            child: BlocConsumer<LoginBloc, LoginState>( listener: (context, state){ 
              if (state is LoginSuccess) { 
                Global.token = state.data.token;
                Global.id_usuario = state.data.id_usuario;
                
                final usuario = state.data.nomeUsuario;
                final token = state.data.token;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(usuarioLogado: usuario, token: token),
                  ),
              );
              } 
              else if (state is LoginError) { 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); 
              } 
              }, 
            builder: (context, state) { 
              return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    TextField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { 
                          context.read<LoginBloc>().add(
                            LoginSubmitted(
                              _userController.text,
                              _passController.text,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: (state is LoginLoading ? const CircularProgressIndicator() : const Text('Login')),
                      ),
                    ),
                  ],
                ),
              ),
              
            );
          },
          ),
        ),
      );
    }
  }