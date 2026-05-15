import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/dio_client.dart';
import '../data/reviews_api.dart';

class ReviewsPage extends StatefulWidget {
  final Color primary;

  const ReviewsPage({super.key, required this.primary});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  bool loading = true;
  String? error;

  List<ReviewDto> items = [];

  final df = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final dio = DioClient.create();
      final api = ReviewsApi(dio);

      final list = await api.list();

      if (!mounted) return;
      setState(() => items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double get average {
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, x) => sum + x.rating);
    return total / items.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              )
              : items.isEmpty
              ? const Center(child: Text('Henüz yorum yok.'))
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return _SummaryCard(
                        primary: widget.primary,
                        average: average,
                        count: items.length,
                      );
                    }

                    final item = items[i - 1];

                    final dateText =
                        item.createdAt == null
                            ? '-'
                            : df.format(item.createdAt!);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withOpacity(.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: widget.primary.withOpacity(
                                  .10,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: widget.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      dateText,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _Stars(rating: item.rating),
                            ],
                          ),
                          if (item.comment.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              item.comment.trim(),
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Color primary;
  final double average;
  final int count;

  const _SummaryCard({
    required this.primary,
    required this.average,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: TextStyle(
                    color: primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$count yorum görüntüleniyor',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;

  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;

        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 18,
          color: Colors.amber.shade700,
        );
      }),
    );
  }
}
