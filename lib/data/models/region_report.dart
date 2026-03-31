enum IssueKind { access, density, competition, teacherLoad }

enum SupportKind { online, center, afterSchool, mentoring }

enum RecommendationCategory {
  all,
  freeClass,
  publicProgram,
  support,
  selfDriven,
}

class GapIssue {
  const GapIssue({
    required this.kind,
    required this.title,
    required this.description,
    required this.severity,
  });

  final IssueKind kind;
  final String title;
  final String description;
  final double severity;
}

class SupportDirection {
  const SupportDirection({
    required this.kind,
    required this.title,
    required this.description,
  });

  final SupportKind kind;
  final String title;
  final String description;
}

class RecommendationItem {
  const RecommendationItem({
    required this.category,
    required this.title,
    required this.description,
    required this.reason,
    required this.ctaLabel,
    required this.provider,
    required this.resourceLabel,
    required this.resourceUrl,
    required this.tags,
  });

  final RecommendationCategory category;
  final String title;
  final String description;
  final String reason;
  final String ctaLabel;
  final String provider;
  final String resourceLabel;
  final String resourceUrl;
  final List<String> tags;
}

class RegionReport {
  const RegionReport({
    required this.score,
    required this.opportunityLabel,
    required this.summary,
    required this.highlight,
    required this.gapIssues,
    required this.supportDirections,
    required this.strengthSummary,
    required this.weaknessSummary,
    required this.expertAdvice,
    required this.recommendations,
  });

  final int score;
  final String opportunityLabel;
  final String summary;
  final String highlight;
  final List<GapIssue> gapIssues;
  final List<SupportDirection> supportDirections;
  final String strengthSummary;
  final String weaknessSummary;
  final String expertAdvice;
  final List<RecommendationItem> recommendations;
}
