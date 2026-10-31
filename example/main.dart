// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_mlkit_barcode_scanning/otel_mlkit_barcode_scanning.dart';

/// Traces ML Kit Barcode Scanning calls with OpenTelemetry.
///
/// `otel_mlkit_barcode_scanning` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each ML Kit Barcode Scanning call in
/// [tracedMlkitBarcodeScanning]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'mlkit-barcode-scanning-example');

  // Wraps an ML Kit Barcode Scanning call in a CLIENT span.
  final mlkitBarcodeScanningId = await tracedMlkitBarcodeScanning<String>(
    operation: 'create',
    invoke: () async {
      // Make the ML Kit Barcode Scanning call here, then report what it returned.
      const id = 'mlkit_barcode_scanning_8f3a2c';
      return const MlkitBarcodeScanningCallResult(
          value: id,
          result: MlkitBarcodeScanningResult(
              formatsRequested: ['BarcodeScannerOptions'],
              barcodeCount: 3,
              primaryFormat: 'example',
              primaryValueType: 'text',
              rawValueLength: 1,
              inputImageWidth: 1,
              inputImageHeight: 1,
              inputImageSource: 'example',
              processingMs: 120,
              modelDownloaded: true));
    },
  );
  OTelLog.info(
      'tracedMlkitBarcodeScanning create returned $mlkitBarcodeScanningId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutMlkitBarcodeScanningInstrumentationAsync.
  await runWithoutMlkitBarcodeScanningInstrumentationAsync(
    () => tracedMlkitBarcodeScanning<String>(
      operation: 'create',
      invoke: () async {
        const id = 'mlkit_barcode_scanning_8f3a2c';
        return const MlkitBarcodeScanningCallResult(
            value: id,
            result: MlkitBarcodeScanningResult(
                formatsRequested: ['BarcodeScannerOptions'],
                barcodeCount: 3,
                primaryFormat: 'example',
                primaryValueType: 'text',
                rawValueLength: 1,
                inputImageWidth: 1,
                inputImageHeight: 1,
                inputImageSource: 'example',
                processingMs: 120,
                modelDownloaded: true));
      },
    ),
  );

  await OTel.shutdown();
}
