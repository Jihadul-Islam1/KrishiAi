import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states.dart';
import '../../../data/models/ai_chat.dart';
import '../../providers/app_providers.dart';

const _uuid = Uuid();

const _kAiHeader = ScreenHeader(
  eyebrow: 'AI',
  title: 'AI সহকারী',
  subtitle: 'ফসল, সার, রোগ — সব প্রশ্নের উত্তর',
  leadingIcon: Icons.smart_toy_rounded,
);

/// Conversational AI helper. Displays the persisted conversation, lets the
/// farmer send new questions and triggers a stub-style reply from the repo.
/// All copy is Bangla — the farmer audience is Bangla-first.
///
/// Rewritten on the home_dashboard minimalist pattern: gradient `_Header`,
/// `AppCard`-based composer + disclaimer, `IconBadge` for chat avatars,
/// `SectionHeader` for "Suggested questions", `AppTextStyles` throughout.
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  AIConversation? _local;
  final List<String> _suggested = const [
    'ধানের বাদামী রোগ কীভাবে চিনব?',
    'টমেটোতে কোন সার ভালো?',
    'সেচ দেওয়ার সঠিক সময় কখন?',
    'আমার ফসলে পোকা এসেছে — কী করব?',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    final conv = _local;
    if (conv == null) return;
    setState(() => _sending = true);
    final userMsg = AIMessage(
      id: _uuid.v4(),
      role: AIMessageRole.user,
      content: text,
      createdAt: DateTime.now(),
    );
    final repo = await ref.read(aiRepoProvider.future);
    final appended = await repo.appendMessage(conv, userMsg);
    final reply = await repo.generateReply(text);
    final withReply = await repo.appendMessage(appended, reply);
    if (!mounted) return;
    setState(() {
      _local = withReply;
      _sending = false;
      _inputController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final convAsync = ref.watch(aiConversationProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: convAsync.when(
        loading: () => const _LoadingShell(),
        error: (e, _) => ErrorStateView(
          message: 'কথোপকথন লোড করা যায়নি।',
          onRetry: () => ref.invalidate(aiConversationProvider),
        ),
        data: (conv) {
          _local = conv;
          final messages = conv.messages;
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _EmptyState(
                        suggestions: _suggested,
                        onTap: (s) {
                          _inputController.text = s;
                          _send();
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        itemCount: messages.length + (_sending ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i >= messages.length) {
                            return const _TypingBubble();
                          }
                          return _MessageBubble(message: messages[i]);
                        },
                      ),
              ),
              const _Disclaimer(),
              _Composer(
                controller: _inputController,
                sending: _sending,
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _kAiHeader,
        Expanded(
          child: LoadingState(message: 'কথোপকথন লোড হচ্ছে...'),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AIMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AIMessageRole.user;
    final bg = isUser ? AppColors.primary : AppColors.surface;
    final fg = isUser ? Colors.white : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            IconBadge(
              icon: Icons.smart_toy_outlined,
              tint: AppColors.primaryContainer,
              color: AppColors.primary,
              size: 32,
              iconSize: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isUser ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppRadius.lg),
                ),
                border: Border.all(
                  color: isUser ? Colors.transparent : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(color: fg, height: 1.45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDate.time(message.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.78)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            IconBadge(
              icon: Icons.person_rounded,
              tint: AppColors.primaryContainer,
              color: AppColors.primary,
              size: 32,
              iconSize: 18,
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconBadge(
            icon: Icons.smart_toy_outlined,
            tint: AppColors.primaryContainer,
            color: AppColors.primary,
            size: 32,
            iconSize: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                    final size = 6 + 4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: size.toDouble(),
                        height: size.toDouble(),
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppCard(
        bordered: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'আপনার প্রশ্ন লিখুন...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 52,
              height: 52,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: sending ? null : onSend,
                  child: Center(
                    child: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disclaimer strip — mirrors the `_Disclaimer` in `weather_screen.dart` and
/// the `_SafetyNote` in `crop_doctor_screen.dart`. Now an `AppCard`
/// (surfaceVariant, bordered) sitting just above the composer.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryContainer,
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.info_outline,
            tint: AppColors.tintGreen,
            color: AppColors.primary,
            size: 28,
            iconSize: 14,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.aiDisclaimer,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryOnContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.suggestions, required this.onTap});
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'নতুন কথোপকথন',
            title: 'নমস্কার! আমি আপনার কৃষি সহকারী',
            subtitle: 'ফসল, সার, সেচ, রোগ — যেকোনো প্রশ্ন লিখুন',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            color: AppColors.primaryContainer,
            elevation: AppElevation.card,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(
                  icon: Icons.tips_and_updates_outlined,
                  tint: AppColors.tintGreen,
                  color: AppColors.primary,
                  size: 44,
                  iconSize: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'আমি সাধারণ কৃষি পরামর্শ দিতে পারি। নির্দিষ্ট রোগ নির্ণয়ের জন্য '
                    'AI ফসল ডাক্তার ব্যবহার করুন।',
                    style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            eyebrow: 'প্রস্তাবিত',
            title: 'জনপ্রিয় প্রশ্ন',
            subtitle: 'যেকোনোটিতে চাপ দিলে প্রশ্ন পাঠানো হবে',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: suggestions
                .map(
                  (s) => AppChip(
                    label: s,
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => onTap(s),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

