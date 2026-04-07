import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_cubit.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('RETAIL INTELLIGENCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.dangerRose),
            onPressed: () => context.read<AIAssistantCubit>().clearChat(),
            tooltip: 'PURGE MEMORY',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomLeft,
            radius: 1.5,
            colors: [
              AppColors.accentTeal.withOpacity(0.03),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<AIAssistantCubit, AIAssistantState>(
                builder: (context, state) {
                  if (state is AIAssistantMessageReceived) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryIndigo.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, size: 64, color: AppColors.primaryIndigo),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "UNITS ONLINE • READY TO ASSIST", 
                              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Ask about inventory trends or sales optimization", 
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isUser = message['role'] == 'user';
                        
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.85,
                            ),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              borderOpacity: isUser ? 0.2 : 0.05,
                              child: Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  color: isUser ? AppColors.accentTeal : AppColors.textWhite,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: isUser ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryIndigo));
                },
              ),
            ),
            
            if (context.watch<AIAssistantCubit>().state is AIAssistantLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentTeal),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "SYNCHRONIZING TERMINAL DATA...",
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.accentTeal.withOpacity(0.7), fontSize: 10, letterSpacing: 1),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: AppColors.darkBackgroundLayer.withOpacity(0.9),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'QUERY SYSTEM...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                            filled: true,
                            fillColor: AppColors.darkBackgroundMain.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.primaryIndigo.withOpacity(0.5), width: 1.5)),
                          ),
                          onSubmitted: (val) {
                            if (val.isNotEmpty) {
                              context.read<AIAssistantCubit>().sendMessage(val);
                              controller.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          context.read<AIAssistantCubit>().sendMessage(controller.text);
                          controller.clear();
                        }
                      },
                      child: Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primaryIndigo, AppColors.accentTeal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryIndigo.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
