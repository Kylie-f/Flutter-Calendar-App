import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';

// HTTP client
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
    // authentication headers
    final authHeaders = await _authService.authHeaders;

    // HTTP client
    final baseClient = http.Client();

    // authenticated client
    final authClient = _CustomAuthClient(authHeaders, baseClient);

    try {
      // call to Google Calendar
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
      // Close base client
      baseClient.close();
    }
  }
}
