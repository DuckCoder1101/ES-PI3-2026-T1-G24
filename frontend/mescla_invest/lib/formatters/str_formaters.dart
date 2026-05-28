/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

String formatCurrency(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

String formatDate(DateTime? dt) {
  if (dt == null) return '—';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  if (diff.inDays == 1) return 'ontem';
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}
