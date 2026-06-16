import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/queue_item.dart';
import '../models/pool_item.dart';
import '../models/application_materials.dart';
import '../models/mail_message.dart';

class ApiService {
  String baseUrl;

  ApiService({this.baseUrl = 'http://127.0.0.1:8080'});

  Future<Map<String, dynamic>> getPipeline() async {
    final r = await http.get(Uri.parse('$baseUrl/pipeline'));
    if (r.statusCode != 200) throw Exception('Failed to load pipeline');
    return json.decode(r.body);
  }

  Future<List<Map<String, dynamic>>> getRecruitments() async {
    final r = await http.get(Uri.parse('$baseUrl/recruitments'));
    if (r.statusCode != 200) throw Exception('Failed to load recruitments');
    return List<Map<String, dynamic>>.from(json.decode(r.body));
  }

  Future<List<Map<String, dynamic>>> getTalents(
    int recruitmentId, {
    String? status,
  }) async {
    final url = status != null
        ? '$baseUrl/recruitments/$recruitmentId/talents?status=$status'
        : '$baseUrl/recruitments/$recruitmentId/talents';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('Failed to load talents');
    return List<Map<String, dynamic>>.from(json.decode(r.body));
  }

  Future<Map<String, dynamic>> transitionApplication(
    int applicationId,
    String status,
  ) async {
    final r = await http.post(
      Uri.parse('$baseUrl/applications/$applicationId/transition'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (r.statusCode != 200) throw Exception('Failed to transition');
    return json.decode(r.body);
  }

  Future<List<QueueItem>> getQueueItems({String? hrStatus}) async {
    final url = hrStatus != null
        ? '$baseUrl/queue?hr_status=$hrStatus'
        : '$baseUrl/queue';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('Failed to load queue');
    final data = json.decode(r.body);
    return (data['items'] as List).map((e) => QueueItem.fromJson(e)).toList();
  }

  Future<void> confirmQueueItem(
    int queueId, {
    String action = 'confirmed',
    String status = '',
    String realName = '',
    String email = '',
    String recruitmentTitle = '',
  }) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/queue/$queueId/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': action,
        'status': status,
        'real_name': realName,
        'email': email,
        'recruitment_title': recruitmentTitle,
      }),
    );
    if (r.statusCode != 200) throw Exception('Failed to confirm');
  }

  Future<void> ignoreQueueItem(int queueId) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/queue/$queueId/ignore'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'ignored'}),
    );
    if (r.statusCode != 200) throw Exception('Failed to ignore');
  }

  Future<Map<String, dynamic>?> getQueueByEmail(String email) async {
    final r = await http.get(
      Uri.parse('$baseUrl/queue/by-email?email=${Uri.encodeComponent(email)}'),
    );
    if (r.statusCode != 200) return null;
    final data = json.decode(r.body);
    if (data['found'] == true) return data['item'];
    return null;
  }

  Future<Map<String, int>> getQueueStats() async {
    final r = await http.get(Uri.parse('$baseUrl/queue/stats'));
    if (r.statusCode != 200) throw Exception('Failed to load queue stats');
    return Map<String, int>.from(json.decode(r.body));
  }

  Future<List<PoolItem>> getPool() async {
    final r = await http.get(Uri.parse('$baseUrl/pool'));
    if (r.statusCode != 200) throw Exception('Failed to load pool');
    final data = json.decode(r.body) as List;
    return data.map((e) => PoolItem.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> poolApplication(int applicationId) async {
    final r = await http.post(
      Uri.parse('$baseUrl/applications/$applicationId/pool'),
      headers: {'Content-Type': 'application/json'},
    );
    if (r.statusCode != 200) throw Exception('Failed to pool application');
    return json.decode(r.body);
  }

  Future<Map<String, dynamic>> unpoolApplication(
    int applicationId,
    int recruitmentId,
  ) async {
    final r = await http.post(
      Uri.parse('$baseUrl/applications/$applicationId/unpool'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'recruitment_id': recruitmentId}),
    );
    if (r.statusCode != 201) throw Exception('Failed to unpool application');
    return json.decode(r.body);
  }

  Future<Headcount> getHeadcount(int recruitmentId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/recruitments/$recruitmentId/headcount'),
    );
    if (r.statusCode != 200) throw Exception('Failed to load headcount');
    return Headcount.fromJson(json.decode(r.body));
  }

  Future<ApplicationMaterials> getApplicationMaterials(
    int applicationId,
  ) async {
    final r = await http.get(
      Uri.parse('$baseUrl/applications/$applicationId/materials'),
    );
    if (r.statusCode != 200) throw Exception('Failed to load materials');
    return ApplicationMaterials.fromJson(json.decode(r.body));
  }

  // ── Candidate messages ──

  Future<List<MailMessage>> getCandidateMessages(int candidateId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/candidates/$candidateId/messages'),
    );
    if (r.statusCode != 200) throw Exception('Failed to load messages');
    final data = json.decode(r.body) as List;
    return data.map((e) => MailMessage.fromJson(e)).toList();
  }

  Future<List<TimelineItem>> getCandidateTimeline(int candidateId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/candidates/$candidateId/timeline'),
    );
    if (r.statusCode != 200) throw Exception('Failed to load timeline');
    final data = json.decode(r.body) as List;
    return data.map((e) => TimelineItem.fromJson(e)).toList();
  }

  Future<void> replyToCandidate(
    int candidateId,
    int applicationId,
    String subject,
    String body,
  ) async {
    final r = await http.post(
      Uri.parse('$baseUrl/candidates/$candidateId/reply'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'application_id': applicationId,
        'subject': subject,
        'body': body,
        'body_text': body,
      }),
    );
    if (r.statusCode != 201) throw Exception('Failed to create reply');
  }

  /// Build attachment URL from storage_path and open in browser.
  Future<void> openAttachmentPreview(
    String storagePath,
    String filename,
  ) async {
    final idx = storagePath.indexOf('/attachments/');
    if (idx == -1) return;
    final relPath = storagePath.substring(idx + '/attachments/'.length);
    final encoded = relPath
        .split('/')
        .map((s) => Uri.encodeComponent(s))
        .join('/');
    final url = '$baseUrl/attachments/$encoded';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── AI settings ──

  Future<Map<String, dynamic>> getAIConfig() async {
    final r = await http.get(Uri.parse('$baseUrl/ai/config'));
    if (r.statusCode != 200) throw Exception('Failed to load AI config');
    return json.decode(r.body);
  }

  Future<void> updateAIConfig(Map<String, dynamic> config) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/ai/config'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config),
    );
    if (r.statusCode != 200) throw Exception('Failed to save AI config');
  }

  Future<Map<String, dynamic>> testAIConnection() async {
    final r = await http.post(Uri.parse('$baseUrl/ai/test'));
    if (r.statusCode != 200) throw Exception('Failed to test AI connection');
    return json.decode(r.body);
  }
}
