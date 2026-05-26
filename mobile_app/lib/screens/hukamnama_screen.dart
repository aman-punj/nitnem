import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design_system/tokens/colors.dart';
import '../core/design_system/tokens/typography.dart';
import '../core/design_system/widgets/sacred_app_bar.dart';
import '../models/hukamnama_model.dart';

class HukamnamaScreen extends StatefulWidget {
  const HukamnamaScreen({super.key, required this.data});

  final HukamnamaModel data;

  @override
  State<HukamnamaScreen> createState() => _HukamnamaScreenState();
}

class _HukamnamaScreenState extends State<HukamnamaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final tabCount = _tabCount;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _tabCount {
    int count = 1; // Gurmukhi always present
    if (widget.data.translationPunjabi.isNotEmpty) count++;
    if (widget.data.translationEnglish.isNotEmpty) count++;
    return count;
  }

  List<({String label, String content})> get _tabs {
    final tabs = <({String label, String content})>[];
    tabs.add((label: 'ਗੁਰਬਾਣੀ', content: widget.data.gurmukhi));
    if (widget.data.translationPunjabi.isNotEmpty) {
      tabs.add((
        label: 'ਵਿਆਖਿਆ',
        content: widget.data.translationPunjabi,
      ));
    }
    if (widget.data.translationEnglish.isNotEmpty) {
      tabs.add((label: 'English', content: widget.data.translationEnglish));
    }
    return tabs;
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _openSgpc() async {
    final now = DateTime.now();
    final monthNames = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december',
    ];
    final url = Uri.parse(
        'https://sgpc.net/${now.day}-${monthNames[now.month - 1]}-${now.year}/');
    if (await canLaunchUrl(url)) launchUrl(url);
  }

  Future<void> _shareHukamnama() async {
    final d = widget.data;
    final buf = StringBuffer();

    buf.writeln('ੴ ਸਤਿ ਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ ॥');
    buf.writeln();
    buf.writeln('🙏 ਹੁਕਮਨਾਮਾ ਸਾਹਿਬ');
    buf.writeln('📅 ${_formatDate(d.date)}');
    if (d.source.isNotEmpty) buf.writeln('📍 ${d.source}');
    buf.writeln();
    buf.writeln('━━━━━━━━━━━━━━━━━━━━');
    buf.writeln();
    buf.writeln(d.gurmukhi.trim());

    if (d.translationPunjabi.isNotEmpty) {
      buf.writeln();
      buf.writeln('━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('ਵਿਆਖਿਆ');
      buf.writeln('━━━━━━━━━━━━━━━━━━━━');
      buf.writeln();
      buf.writeln(d.translationPunjabi.trim());
    }

    if (d.translationEnglish.isNotEmpty) {
      buf.writeln();
      buf.writeln('━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('English Translation');
      buf.writeln('━━━━━━━━━━━━━━━━━━━━');
      buf.writeln();
      buf.writeln(d.translationEnglish.trim());
    }

    buf.writeln();
    buf.writeln('─────────────────────');
    buf.writeln('Shared via Bani Sagar 🙏');

    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    await SharePlus.instance.share(
      ShareParams(
        text: buf.toString(),
        subject: 'ਹੁਕਮਨਾਮਾ ਸਾਹਿਬ — ${_formatDate(d.date)}',
        sharePositionOrigin: rect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final tabs = _tabs;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: SacredDsAppBar(
        title: 'ਹੁਕਮਨਾਮਾ ਸਾਹਿਬ',
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: c.primary),
            tooltip: 'Share Hukamnama',
            onPressed: _shareHukamnama,
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser_rounded, color: c.primary),
            tooltip: 'Open on SGPC.net',
            onPressed: _openSgpc,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + source header
          Container(
            color: c.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.data.source.isNotEmpty)
                  Text(
                    widget.data.source,
                    style: SacredTypography.bodySm
                        .copyWith(color: c.primary, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(widget.data.date),
                  style: SacredTypography.bodySm
                      .copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: c.primary,
            unselectedLabelColor: c.textSecondary,
            indicatorColor: c.primary,
            indicatorWeight: 2.5,
            labelStyle: SacredTypography.bodySm
                .copyWith(fontWeight: FontWeight.w600),
            tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((t) => _ContentTab(
                    content: t.content,
                    largeFontGurmukhi: t.label == 'ਗੁਰਬਾਣੀ',
                  )).toList(),
            ),
          ),

          // SGPC attribution footer
          GestureDetector(
            onTap: _openSgpc,
            child: Container(
              color: c.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_rounded,
                      size: 14, color: c.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Source: Sachkhand Sri Harmandir Sahib, SGPC',
                    style: SacredTypography.bodySm.copyWith(
                      color: c.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  const _ContentTab({required this.content, required this.largeFontGurmukhi});

  final String content;
  final bool largeFontGurmukhi;

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Text(
        content,
        style: largeFontGurmukhi
            ? TextStyle(
                fontSize: 19,
                height: 2.1,
                color: c.textPrimary,
                fontWeight: FontWeight.w400,
              )
            : SacredTypography.bodySm.copyWith(
                color: c.textPrimary,
                height: 1.8,
                fontSize: 15,
              ),
      ),
    );
  }
}
