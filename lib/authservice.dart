import 'package:supabase_flutter/supabase_flutter.dart';

class Authservice {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    final response = await _supabaseClient.auth.signUp(
      password: password,
      email: email,
      data: {'display_name': displayName},
    );
    return response;
  }

  Future<void> updateUser(String displayName) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(data: {'display_name': displayName}),
    );
  }

  Future<void> updatePassword(String password) async {
    await _supabaseClient.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> setShopID(String shopID) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(data: {'shop_id': shopID}),
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  String? getCurrentUserName() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.userMetadata?['display_name'] as String?;
  }

  //insert fake data to the database for testing purposes
  void addFakeData(String context) async {
    var user = _supabaseClient.auth.currentUser;
    await _supabaseClient.from('datas').insert([
      {
        'context': context,
        'shop_id': user?.userMetadata?['shop_id'] as String?,
        'user_id': user?.id,
        // Add more columns and values as needed
      },
    ]);
  }

  //select all data from the database for testing purposes
  Future<List<Map<String, dynamic>>> getAllData() async {
    final response = await _supabaseClient.from('datas').select();
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<List<Map<String, dynamic>>> getAllDataWithRange(int from,int to) async {
    final response = await _supabaseClient.from('datas').select().range(from, to).order('context',ascending: true);
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<int> getTotalDataCount() async {
    final response = await _supabaseClient.from('datas').select();
    return response.length;
  }

  /// Send a login OTP to an existing user's email.
  Future<void> sendEmailOtp(String email) async {
    await _supabaseClient.auth.signInWithOtp(email: email.trim());
    // await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  /// Verify the OTP sent to the email.
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return await _supabaseClient.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.email,
    );
  }
}
