import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';

// Custom authenticated HTTP client
class _CustomAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner;

  _CustomAuthClient(this._headers, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class CalendarService {
  final GoogleAuthService _authService;

  CalendarService({required GoogleAuthService authService})
      : _authService = authService;

  Future<List<Event>> fetchEvents() async {
    // 1. Get authentication headers
    final authHeaders = await _authService.authHeaders;

    // 2. Create base HTTP client
    final baseClient = http.Client();

    // 3. Create authenticated client using custom wrapper
    final authClient = _CustomAuthClient(authHeaders, baseClient);

    try {
      // 4. Make API call to Google Calendar
      final calendar = CalendarApi(authClient);
      final response = await calendar.events.list(
        'primary',
        timeMin: DateTime.now().toUtc(),
        maxResults: 10,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return response.items ?? [];
    } finally {
      // 5. Close base client
      baseClient.close();
    }
  }
}
