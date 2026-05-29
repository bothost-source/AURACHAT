import 'package:flutter/foundation.dart';

enum ViolationType { spam, harassment, hateSpeech, violence, explicit, illegal, misinformation, copyright, phishing, impersonation }
enum ActionTaken { none, warning, messageDeleted, temporaryMute, permanentBan, accountSuspended, contentRestricted }

class ModerationReport {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedMessageId;
  final String? reportedContent;
  final ViolationType violationType;
  final String description;
  final List<String> evidence;
  final DateTime reportedAt;
  final ActionTaken actionTaken;
  final String? actionReason;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final bool isResolved;

  ModerationReport({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedMessageId,
    this.reportedContent,
    required this.violationType,
    required this.description,
    this.evidence = const [],
    required this.reportedAt,
    this.actionTaken = ActionTaken.none,
    this.actionReason,
    this.resolvedAt,
    this.resolvedBy,
    this.isResolved = false,
  });
}

class AIAnalysisResult {
  final double safetyScore;
  final Map<ViolationType, double> violationScores;
  final List<String> flaggedKeywords;
  final String? explanation;
  final bool requiresHumanReview;
  final DateTime analyzedAt;

  AIAnalysisResult({
    required this.safetyScore,
    required this.violationScores,
    required this.flaggedKeywords,
    this.explanation,
    required this.requiresHumanReview,
    required this.analyzedAt,
  });
}

class ModerationProvider extends ChangeNotifier {
  List<ModerationReport> _reports = [];
  List<AIAnalysisResult> _analysisHistory = [];
  bool _isAnalyzing = false;
  bool _autoModEnabled = true;
  double _safetyThreshold = 0.7;

  List<ModerationReport> get reports => _reports;
  List<AIAnalysisResult> get analysisHistory => _analysisHistory;
  bool get isAnalyzing => _isAnalyzing;
  bool get autoModEnabled => _autoModEnabled;
  double get safetyThreshold => _safetyThreshold;

  // AI Moderation keywords and patterns
  static final Map<ViolationType, List<String>> _violationPatterns = {
    ViolationType.spam: ['click here', 'free money', 'get rich', 'limited time', 'act now', '100% guaranteed'],
    ViolationType.harassment: ['kill yourself', 'die', 'worthless', 'stupid', 'idiot', 'loser'],
    ViolationType.hateSpeech: ['hate', 'inferior', 'superior race', 'ethnic cleansing', 'genocide'],
    ViolationType.violence: ['bomb', 'attack', 'shoot', 'stab', 'murder', 'terrorist', 'weapon'],
    ViolationType.explicit: ['explicit', 'adult content', 'nsfw', 'porn', 'sexual'],
    ViolationType.illegal: ['drugs', 'weapons', 'hacking', 'fraud', 'scam', 'illegal'],
    ViolationType.misinformation: ['fake news', 'conspiracy', 'hoax', 'misleading'],
    ViolationType.phishing: ['verify account', 'suspended', 'click link', 'password', 'login'],
    ViolationType.impersonation: ['official support', 'admin', 'verify identity', 'security team'],
  };

  Future<AIAnalysisResult> analyzeContent(String content, {String? userId, String? chatId}) async {
    _isAnalyzing = true;
    notifyListeners();

    // Simulate AI analysis delay
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerContent = content.toLowerCase();
    Map<ViolationType, double> scores = {};
    List<String> flagged = [];
    double totalScore = 1.0;

    for (final entry in _violationPatterns.entries) {
      double score = 0.0;
      for (final pattern in entry.value) {
        if (lowerContent.contains(pattern.toLowerCase())) {
          score += 0.3;
          if (!flagged.contains(pattern)) flagged.add(pattern);
        }
      }
      if (score > 0) {
        score = score.clamp(0.0, 1.0);
        scores[entry.key] = score;
        totalScore -= score * 0.1;
      }
    }

    totalScore = totalScore.clamp(0.0, 1.0);
    final requiresReview = totalScore < _safetyThreshold || scores.values.any((s) => s > 0.5);

    final result = AIAnalysisResult(
      safetyScore: totalScore,
      violationScores: scores,
      flaggedKeywords: flagged,
      explanation: scores.isNotEmpty 
          ? 'Content flagged for: ${scores.entries.where((e) => e.value > 0).map((e) => e.key.name).join(', ')}'
          : 'Content appears safe',
      requiresHumanReview: requiresReview,
      analyzedAt: DateTime.now(),
    );

    _analysisHistory.add(result);
    _isAnalyzing = false;
    notifyListeners();

    // Auto-action if enabled and score is low
    if (_autoModEnabled && totalScore < 0.3) {
      _autoRestrict(content, result);
    }

    return result;
  }

  void _autoRestrict(String content, AIAnalysisResult result) {
    // In real implementation, this would call backend to restrict
    print('AUTO-MOD: Content restricted - Safety score: ${result.safetyScore}');
  }

  Future<void> submitReport({
    required String reporterId,
    String? reportedUserId,
    String? reportedMessageId,
    String? reportedContent,
    required ViolationType violationType,
    required String description,
    List<String> evidence = const [],
  }) async {
    final report = ModerationReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reportedMessageId: reportedMessageId,
      reportedContent: reportedContent,
      violationType: violationType,
      description: description,
      evidence: evidence,
      reportedAt: DateTime.now(),
    );

    _reports.add(report);
    notifyListeners();

    // Auto-analyze reported content
    if (reportedContent != null) {
      await analyzeContent(reportedContent);
    }
  }

  void setAutoMod(bool enabled) {
    _autoModEnabled = enabled;
    notifyListeners();
  }

  void setSafetyThreshold(double threshold) {
    _safetyThreshold = threshold.clamp(0.0, 1.0);
    notifyListeners();
  }

  void resolveReport(String reportId, ActionTaken action, String reason, String resolverId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = ModerationReport(
        id: _reports[index].id,
        reporterId: _reports[index].reporterId,
        reportedUserId: _reports[index].reportedUserId,
        reportedMessageId: _reports[index].reportedMessageId,
        reportedContent: _reports[index].reportedContent,
        violationType: _reports[index].violationType,
        description: _reports[index].description,
        evidence: _reports[index].evidence,
        reportedAt: _reports[index].reportedAt,
        actionTaken: action,
        actionReason: reason,
        resolvedAt: DateTime.now(),
        resolvedBy: resolverId,
        isResolved: true,
      );
      notifyListeners();
    }
  }

  List<ModerationReport> getPendingReports() {
    return _reports.where((r) => !r.isResolved).toList();
  }

  List<ModerationReport> getReportsByUser(String userId) {
    return _reports.where((r) => r.reportedUserId == userId).toList();
  }
}
