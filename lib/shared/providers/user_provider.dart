import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/api_service.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Watch the authTokenProvider so that whenever the login token changes,
    // it automatically schedules a profile fetch from the backend database.
    final token = ref.watch(authTokenProvider);
    if (token != null) {
      Future.microtask(() => fetchProfile());
    }

    return UserProfile(
      name: 'Juan Dela Cruz',
      email: 'juan.delacruz@email.com',
      phone: '+63 912 345 6789',
    );
  }

  Future<void> fetchProfile() async {
    final token = ref.read(authTokenProvider);
    if (token == null) return;
    try {
      final profileData = await ref.read(apiServiceProvider).getMe();
      final name = profileData['name'] as String? ?? state.name;
      final email = profileData['email'] as String? ?? state.email;
      state = state.copyWith(name: name, email: email);
    } catch (e) {
      print('Error fetching profile from database: $e');
    }
  }

  void updateProfile({String? name, String? email, String? phone}) {
    state = state.copyWith(name: name, email: email, phone: phone);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);
