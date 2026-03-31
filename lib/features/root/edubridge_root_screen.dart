import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/ai_report_client.dart';
import '../../core/services/browser_bridge.dart';
import '../../core/utils/report_export_formatter.dart';
import '../../data/models/region_report.dart';
import '../../data/models/student_scores.dart';
import '../../data/repositories/education_repository.dart';
import '../../features/analysis/analysis_screen.dart';
import '../../features/analysis/detailed_analysis_screen.dart';
import '../../features/comparison/comparison_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/intro/intro_screen.dart';
import '../../features/recommendation/recommendation_screen.dart';
import '../../features/selection/region_selection_screen.dart';
import '../../features/sources/sources_screen.dart';
import '../../shared/widgets/glass_bottom_nav.dart';
import '../../shared/widgets/score_input_sheet.dart';

class EduBridgeRootScreen extends StatefulWidget {
  const EduBridgeRootScreen({super.key});

  @override
  State<EduBridgeRootScreen> createState() => _EduBridgeRootScreenState();
}

class _EduBridgeRootScreenState extends State<EduBridgeRootScreen> {
  late final Future<EducationRepository> _repositoryFuture;
  String? _selectedRegionName;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = EducationRepository.load();
  }

  Future<void> _startFlow(EducationRepository repository) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RegionSelectionScreen(
          repository: repository,
          initialRegionName:
              _selectedRegionName ?? repository.defaultRegionName,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() => _selectedRegionName = selected);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EducationRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.regions.isEmpty) {
          return const Scaffold(body: Center(child: Text('데이터를 불러오지 못했습니다.')));
        }

        final repository = snapshot.data!;
        if (_selectedRegionName == null) {
          return IntroScreen(onStart: () => _startFlow(repository));
        }

        return _EduBridgeShell(
          repository: repository,
          initialRegionName: _selectedRegionName!,
        );
      },
    );
  }
}

class _EduBridgeShell extends StatefulWidget {
  const _EduBridgeShell({
    required this.repository,
    required this.initialRegionName,
  });

  final EducationRepository repository;
  final String initialRegionName;

  @override
  State<_EduBridgeShell> createState() => _EduBridgeShellState();
}

class _EduBridgeShellState extends State<_EduBridgeShell> {
  final AiReportClient _aiReportClient = const AiReportClient();
  final BrowserBridge _browserBridge = createBrowserBridge();
  late String _selectedRegionName;
  late String _compareRegionName;
  final Set<String> _bookmarkedRecommendations = <String>{};
  StudentScores? _studentScores;
  int _currentIndex = 0;
  bool _isGeneratingReport = false;

  @override
  void initState() {
    super.initState();
    _selectedRegionName = widget.initialRegionName;
    _compareRegionName = widget.repository.defaultComparisonFor(
      _selectedRegionName,
    );
  }

  Future<void> _editRegion() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RegionSelectionScreen(
          repository: widget.repository,
          initialRegionName: _selectedRegionName,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedRegionName = selected;
      _compareRegionName = widget.repository.defaultComparisonFor(selected);
    });
  }

  void _openDetail() {
    final region = widget.repository.regionByName(_selectedRegionName);
    final report = _buildCurrentReport();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailedAnalysisScreen(
          repository: widget.repository,
          region: region,
          report: report,
        ),
      ),
    );
  }

  void _openSources() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SourcesScreen()));
  }

  Future<void> _downloadReport() async {
    if (_isGeneratingReport) {
      return;
    }
    final region = widget.repository.regionByName(_selectedRegionName);
    final report = _buildCurrentReport();
    final fallbackContent = ReportExportFormatter.buildRegionReport(
      region: region,
      report: report,
    );
    var content = fallbackContent;
    var usedAi = false;
    setState(() => _isGeneratingReport = true);
    try {
      final aiContent = await _aiReportClient.generateReport(
        region: region,
        report: report,
        studentScores: _studentScores,
      );
      if (aiContent != null && aiContent.trim().isNotEmpty) {
        content = aiContent;
        usedAi = true;
      }
    } catch (_) {
      content = fallbackContent;
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }

    final safeName = region.regionName.replaceAll(' ', '_');
    final downloaded = await _browserBridge.downloadTextFile(
      filename: 'edubridge_$safeName.txt',
      content: content,
    );
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    if (downloaded) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text(
            usedAi ? 'AI 맞춤형 리포트를 파일로 내려받았습니다.' : '기본 리포트를 파일로 내려받았습니다.',
          ),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('파일 다운로드를 지원하지 않아 리포트 내용을 클립보드에 복사했습니다.'),
      ),
    );
  }

  Future<void> _openRegionPicker() async {
    await _editRegion();
  }

  Future<void> _openScoreInput() async {
    final updated = await showModalBottomSheet<StudentScores>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScoreInputSheet(initialScores: _studentScores),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _studentScores = updated);
    }
  }

  Future<void> _openExternalUrl(String url) async {
    if (url.startsWith('internal://')) {
      _showInsightsSheet();
      return;
    }
    final opened = await _browserBridge.openExternalUrl(url);
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('현재 환경에서는 외부 링크를 열 수 없습니다.'),
        ),
      );
  }

  RegionReport _buildCurrentReport() {
    return widget.repository.buildReport(
      _selectedRegionName,
      studentScores: _studentScores,
    );
  }

  void _showInsightsSheet() {
    final region = widget.repository.regionByName(_selectedRegionName);
    final report = _buildCurrentReport();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('알림 및 안내', style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '${region.regionName} 기준으로 최신 분석 상태를 요약했습니다.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                _InsightTile(
                  title: '현재 점수',
                  body:
                      '교육 기회 점수 ${report.score}/100, 상태는 ${report.opportunityLabel}입니다.',
                ),
                const SizedBox(height: 10),
                _InsightTile(
                  title: '저장한 추천',
                  body:
                      '북마크한 추천 학습 기회는 ${_bookmarkedRecommendations.length}건입니다.',
                ),
                if (_studentScores != null) ...[
                  const SizedBox(height: 10),
                  _InsightTile(
                    title: '국영수 평균',
                    body:
                        '평균 ${_studentScores!.averageLabel()}점, 보완 과목은 ${StudentScores.subjectLabel(_studentScores!.weakestSubject)}입니다.',
                  ),
                ],
                const SizedBox(height: 10),
                _InsightTile(title: '데이터 범위', body: region.sourceScope),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadReport();
                  },
                  child: const Text('리포트 바로 다운로드'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openSources();
                  },
                  child: const Text('데이터 출처 보기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleBookmark(String title) {
    setState(() {
      if (_bookmarkedRecommendations.contains(title)) {
        _bookmarkedRecommendations.remove(title);
      } else {
        _bookmarkedRecommendations.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final region = widget.repository.regionByName(_selectedRegionName);
    final report = _buildCurrentReport();
    final compareRegion = widget.repository.regionByName(_compareRegionName);

    final body = switch (_currentIndex) {
      0 => DashboardScreen(
        region: region,
        report: report,
        studentScores: _studentScores,
        onEditRegion: _editRegion,
        onEditScores: _openScoreInput,
        onOpenDetailed: _openDetail,
        onGoToAnalysis: () => setState(() => _currentIndex = 1),
        onGoToComparison: () => setState(() => _currentIndex = 2),
        onGoToRecommendations: () => setState(() => _currentIndex = 3),
        onOpenSources: _openSources,
      ),
      1 => AnalysisScreen(
        region: region,
        report: report,
        studentScores: _studentScores,
        onDownloadReport: _downloadReport,
        onEditScores: _openScoreInput,
        onOpenRegionPicker: _openRegionPicker,
        onOpenInsights: _showInsightsSheet,
        isGeneratingReport: _isGeneratingReport,
      ),
      2 => ComparisonScreen(
        repository: widget.repository,
        primaryRegion: region,
        compareRegion: compareRegion,
        onChanged: (value) => setState(() => _compareRegionName = value),
        onOpenInsights: _showInsightsSheet,
      ),
      _ => RecommendationScreen(
        region: region,
        report: report,
        studentScores: _studentScores,
        bookmarkedTitles: _bookmarkedRecommendations,
        onToggleBookmark: _toggleBookmark,
        onOpenRegionPicker: _openRegionPicker,
        onOpenInsights: _showInsightsSheet,
        onOpenExternalUrl: _openExternalUrl,
      ),
    };

    return Scaffold(
      body: body,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() => _currentIndex = value),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
