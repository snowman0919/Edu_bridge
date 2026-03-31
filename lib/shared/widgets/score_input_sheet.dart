import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/student_scores.dart';

class ScoreInputSheet extends StatefulWidget {
  const ScoreInputSheet({super.key, this.initialScores});

  final StudentScores? initialScores;

  @override
  State<ScoreInputSheet> createState() => _ScoreInputSheetState();
}

class _ScoreInputSheetState extends State<ScoreInputSheet> {
  late final TextEditingController _koreanController;
  late final TextEditingController _englishController;
  late final TextEditingController _mathController;

  @override
  void initState() {
    super.initState();
    _koreanController = TextEditingController(
      text: widget.initialScores?.korean.toStringAsFixed(0) ?? '',
    );
    _englishController = TextEditingController(
      text: widget.initialScores?.english.toStringAsFixed(0) ?? '',
    );
    _mathController = TextEditingController(
      text: widget.initialScores?.math.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _koreanController.dispose();
    _englishController.dispose();
    _mathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('국영수 평균 입력', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '최근 모의고사나 학교 평균 점수를 입력하면 추천과 리포트를 더 구체화합니다.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            _ScoreField(label: '국어', controller: _koreanController),
            const SizedBox(height: 12),
            _ScoreField(label: '영어', controller: _englishController),
            const SizedBox(height: 12),
            _ScoreField(label: '수학', controller: _mathController),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                final scores = _buildScores();
                if (scores == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.fixed,
                        content: Text('0부터 100 사이 점수를 모두 입력해 주세요.'),
                      ),
                    );
                  return;
                }
                Navigator.of(context).pop(scores);
              },
              child: const Text('성적 반영하기'),
            ),
          ],
        ),
      ),
    );
  }

  StudentScores? _buildScores() {
    final korean = double.tryParse(_koreanController.text.trim());
    final english = double.tryParse(_englishController.text.trim());
    final math = double.tryParse(_mathController.text.trim());
    final values = <double?>[korean, english, math];
    if (values.any((value) => value == null || value < 0 || value > 100)) {
      return null;
    }
    return StudentScores(korean: korean!, english: english!, math: math!);
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: '$label 평균',
        hintText: '예: 78',
        filled: true,
        fillColor: AppColors.surfaceLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
