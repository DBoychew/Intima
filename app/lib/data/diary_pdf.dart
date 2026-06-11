import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'calendar_repository.dart' show decodeStringList;
import 'database.dart';

/// Цветовете на бранда в PDF пространството.
const _ink = PdfColor.fromInt(0xFF2A1F35);
const _soft = PdfColor.fromInt(0xFF8A7F9E);
const _accent = PdfColor.fromInt(0xFF7C3AED);

/// Строи PDF на дневника с вградените шрифтове (кирилица).
/// Шрифтовете се подават отвън, за да е тестваемо без asset bundle.
Future<Uint8List> buildDiaryPdf(
  List<DiaryEntryRow> entries, {
  required String title,
  required ByteData body,
  required ByteData bold,
  required ByteData display,
  required String Function(DateTime) formatDate,
}) async {
  final bodyFont = pw.Font.ttf(body);
  final boldFont = pw.Font.ttf(bold);
  final displayFont = pw.Font.ttf(display);

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: bodyFont, bold: boldFont),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      build: (context) => [
        pw.Text(title,
            style: pw.TextStyle(
                font: displayFont, fontSize: 28, color: _accent)),
        pw.SizedBox(height: 24),
        for (final entry in entries) ...[
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _accent, width: 2),
              ),
            ),
            padding: const pw.EdgeInsets.only(left: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(entry.title,
                          style: pw.TextStyle(
                              font: displayFont,
                              fontSize: 16,
                              color: _ink)),
                    ),
                    pw.Text(formatDate(entry.date),
                        style:
                            const pw.TextStyle(fontSize: 10, color: _soft)),
                  ],
                ),
                pw.SizedBox(height: 6),
                if (entry.body.isNotEmpty)
                  pw.Text(entry.body,
                      style:
                          const pw.TextStyle(fontSize: 11, color: _ink)),
                if (decodeStringList(entry.tags).isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    decodeStringList(entry.tags)
                        .map((t) => '#$t')
                        .join('  '),
                    style: const pw.TextStyle(fontSize: 10, color: _soft),
                  ),
                ],
                ..._photoWidgets(entry),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
        ],
      ],
    ),
  );

  return doc.save();
}

List<pw.Widget> _photoWidgets(DiaryEntryRow entry) {
  final widgets = <pw.Widget>[];
  for (final path in decodeStringList(entry.photos)) {
    final file = File(path);
    if (!file.existsSync()) continue;
    try {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: pw.Image(
            pw.MemoryImage(file.readAsBytesSync()),
            height: 160,
            fit: pw.BoxFit.cover,
          ),
        ),
      ));
    } catch (_) {
      // Повредена снимка — пропускаме я, записът остава.
    }
  }
  return widgets;
}

/// Зарежда вградените шрифтове и строи PDF-а (за ползване от UI-я).
Future<Uint8List> exportDiaryPdf(
  List<DiaryEntryRow> entries, {
  required String title,
  required String Function(DateTime) formatDate,
}) async {
  return buildDiaryPdf(
    entries,
    title: title,
    body: await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    bold: await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    display: await rootBundle.load('assets/fonts/PlayfairDisplay-SemiBold.ttf'),
    formatDate: formatDate,
  );
}
