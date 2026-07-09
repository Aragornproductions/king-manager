import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_themes.dart';
import '../theme/theme_provider.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Theme')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: kAppThemes.length,
        itemBuilder: (context, i) {
          final t = kAppThemes[i];
          final selected = provider.selectedIndex == i;
          return GestureDetector(
            onTap: () => provider.setTheme(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: selected ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.background, t.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? t.accent : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: t.accent.withOpacity(0.5), blurRadius: 16, spreadRadius: 1)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.icon, size: 40, color: t.accent),
                  const SizedBox(height: 10),
                  Text(
                    t.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(t.primary),
                      _dot(t.secondary),
                      _dot(t.accent),
                    ],
                  ),
                  if (selected) ...[
                    const SizedBox(height: 8),
                    Icon(Icons.check_circle, color: t.accent, size: 20),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dot(Color c) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
