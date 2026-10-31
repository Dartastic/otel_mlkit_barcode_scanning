// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_mlkit_barcode_scanning_suppression.dart';

const _tracerName = 'dartastic_otel_libs_mlkit_barcode_scanning';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class MlkitBarcodeScanningResult {
  /// Creates a result.
  const MlkitBarcodeScanningResult({
    this.formatsRequested,
    this.barcodeCount,
    this.primaryFormat,
    this.primaryValueType,
    this.rawValueLength,
    this.inputImageWidth,
    this.inputImageHeight,
    this.inputImageSource,
    this.processingMs,
    this.modelDownloaded,
  });

  /// Formats requested by `BarcodeScannerOptions` —
  /// `qr_code`, `code_128`, `code_39`, `ean_13`, `ean_8`, `upc_a`,
  /// `upc_e`, `data_matrix`, `pdf417`, `itf`, `aztec`, `codabar`, `all`.
  final List<String>? formatsRequested;

  final int? barcodeCount;

  /// Primary barcode format detected on the first result.
  final String? primaryFormat;

  /// `text`, `url`, `email`, `phone`, `sms`, `wifi`, `geo`,
  /// `calendar_event`, `contact_info`, `driver_license`, `isbn`, `product`.
  final String? primaryValueType;

  final int? rawValueLength;

  final int? inputImageWidth;
  final int? inputImageHeight;
  final String? inputImageSource;

  final int? processingMs;

  final bool? modelDownloaded;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class MlkitBarcodeScanningCallResult<T> {
  /// Creates a call result.
  const MlkitBarcodeScanningCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final MlkitBarcodeScanningResult? result;
}

/// Wraps an ML Kit Barcode Scanning call in a CLIENT span. [operation] is
/// one of `processImage`, `close`.
Future<T> tracedMlkitBarcodeScanning<T>({
  required String operation,
  required Future<MlkitBarcodeScanningCallResult<T>> Function() invoke,
}) async {
  if (mlkitBarcodeScanningInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'mlkit_barcode_scanning',
    'rpc.method': operation,
    'mlkit_barcode_scanning.operation': operation,
  };

  final span = _tracer().startSpan(
    'mlkit_barcode_scanning $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.formatsRequested != null) {
        extras.add(OTelAPI.attributeStringList(
          'mlkit_barcode_scanning.formats.requested',
          res.formatsRequested!,
        ));
      }
      if (res.barcodeCount != null) {
        extras.add(OTelAPI.attributeInt(
          'mlkit_barcode_scanning.barcode.count',
          res.barcodeCount!,
        ));
      }
      if (res.primaryFormat != null) {
        extras.add(OTelAPI.attributeString(
          'mlkit_barcode_scanning.primary.format',
          res.primaryFormat!,
        ));
      }
      if (res.primaryValueType != null) {
        extras.add(OTelAPI.attributeString(
          'mlkit_barcode_scanning.primary.value_type',
          res.primaryValueType!,
        ));
      }
      if (res.rawValueLength != null) {
        extras.add(OTelAPI.attributeInt(
          'mlkit_barcode_scanning.raw_value.length',
          res.rawValueLength!,
        ));
      }
      if (res.inputImageWidth != null) {
        extras.add(OTelAPI.attributeInt(
          'mlkit_barcode_scanning.input.width',
          res.inputImageWidth!,
        ));
      }
      if (res.inputImageHeight != null) {
        extras.add(OTelAPI.attributeInt(
          'mlkit_barcode_scanning.input.height',
          res.inputImageHeight!,
        ));
      }
      if (res.inputImageSource != null) {
        extras.add(OTelAPI.attributeString(
          'mlkit_barcode_scanning.input.source',
          res.inputImageSource!,
        ));
      }
      if (res.processingMs != null) {
        extras.add(OTelAPI.attributeInt(
          'mlkit_barcode_scanning.processing_ms',
          res.processingMs!,
        ));
      }
      if (res.modelDownloaded != null) {
        extras.add(OTelAPI.attributeBool(
          'mlkit_barcode_scanning.model.downloaded',
          res.modelDownloaded!,
        ));
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
