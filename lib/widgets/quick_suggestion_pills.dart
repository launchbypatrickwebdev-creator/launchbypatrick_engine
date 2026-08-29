// lib/widgets/quick_suggestion_pills.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/suggestion_pill.dart';
import '../models/ai_buddy_config.dart';

/// Scrollable horizontal suggestion pills with submenu support
class QuickSuggestionPills extends StatefulWidget {
  final AIBuddyConfig config;
  final Function(String) onSuggestionSelected;

  const QuickSuggestionPills({
    super.key,
    required this.config,
    required this.onSuggestionSelected,
  });

  @override
  State<QuickSuggestionPills> createState() => _QuickSuggestionPillsState();
}

class _QuickSuggestionPillsState extends State<QuickSuggestionPills> {
  late List<SuggestionPill> suggestions;
  int? _selectedPillIndex;

  @override
  void initState() {
    super.initState();
    suggestions = SuggestionProfiles.getSuggestions(widget.config.assistantName);
  }

  /// Handle pill click - auto-fill or show submenu
  void _handlePillTap(SuggestionPill pill, int index) {
    if (_selectedPillIndex == index) {
      // Second tap or already selected - send the message
      widget.onSuggestionSelected(pill.mainAction);
      setState(() => _selectedPillIndex = null);
    } else {
      // First tap - select and show submenu
      setState(() => _selectedPillIndex = index);

      // Auto-fill text input
      widget.onSuggestionSelected(pill.mainAction);

      // Show submenu if available
      if (pill.submenuOptions.isNotEmpty) {
        _showSubmenu(pill);
      }
    }
  }

  /// Show submenu dialog with related options
  void _showSubmenu(SuggestionPill pill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${pill.icon} ${pill.title} Options',
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...pill.submenuOptions.asMap().entries.map((entry) {
                final option = entry.value;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onSuggestionSelected(option);
                    setState(() => _selectedPillIndex = null);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.config.accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.robotoMono(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            ...suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final pill = entry.value;
              final isSelected = _selectedPillIndex == index;

              return GestureDetector(
                onTap: () => _handlePillTap(pill, index),
                onLongPress: () {
                  setState(() => _selectedPillIndex = index);
                  _showSubmenu(pill);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.config.accentColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isSelected
                          ? widget.config.accentColor
                          : widget.config.accentColor.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pill.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        pill.title,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}