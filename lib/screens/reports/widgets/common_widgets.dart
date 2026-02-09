import 'package:flutter/material.dart';

class ReportDateFilter extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final VoidCallback onTap;

  const ReportDateFilter({
    super.key,
    required this.selectedRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedRange != null
                          ? '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}'
                          : 'Select Range',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ReportSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final EdgeInsets? padding;

  const ReportSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isPositive;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPositive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportFilterSection extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onSearch;
  final TextEditingController searchController;

  const ReportFilterSection({
    super.key,
    required this.children,
    required this.onSearch,
    required this.searchController,
  });

  @override
  State<ReportFilterSection> createState() => _ReportFilterSectionState();
}

class _ReportFilterSectionState extends State<ReportFilterSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: widget.searchController,
                    onSubmitted: (_) => widget.onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search report data...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: _isExpanded ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      border: _isExpanded
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: _isExpanded
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth < 600 ? 2.3 : 3.5,
                  ),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) => widget.children[index],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class FilterInput extends StatelessWidget {
  final String label;
  final Widget child;

  const FilterInput({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        child,
      ],
    );
  }
}

InputDecoration modernInputDecoration(String hint, {bool isMobile = false}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: isMobile ? 11 : 13,
      color: const Color(0xFF94A3B8),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: isMobile ? 12 : 16,
      vertical: isMobile ? 10 : 12,
    ),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    ),
  );
}

class CollapsibleReportSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool initialExpanded;

  const CollapsibleReportSection({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.initialExpanded = false,
  });

  @override
  State<CollapsibleReportSection> createState() =>
      _CollapsibleReportSectionState();
}

class _CollapsibleReportSectionState extends State<CollapsibleReportSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.filter_list_off : Icons.filter_list,
                      size: 18,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  if (widget.actions != null && !_isExpanded)
                    ...widget.actions!.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: a,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.children.map((child) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width < 600
                            ? double.infinity
                            : 280,
                        child: child,
                      );
                    }).toList(),
                  ),
                  if (widget.actions != null) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.actions!
                          .map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: a,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
