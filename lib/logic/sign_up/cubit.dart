import 'package:flutter_bloc/flutter_bloc.dart'; // Uncomment when flutter_bloc is added to pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import 'state.dart';

class SignUpCubit extends Cubit<SignUpStates> {
  SignUpCubit() : super(SignUpInitialState());

  Future<void> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Show confirmation or stay on screen
    } catch (e) {
      // Show error
    }
  }
}
