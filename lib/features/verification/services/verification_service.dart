import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../crypto/cross_signing_service.dart';
import '../../../matrix/matrix_client.dart';

/// Service for handling device verification flows
class VerificationService {
  static final VerificationService _instance = VerificationService._internal();

  final Logger _logger = Logger('VerificationService');
  final Map<String, matrix.VerificationRequest> _pendingRequests = {};
  final StreamController<matrix.VerificationRequest> _requestController =
      StreamController<matrix.VerificationRequest>.broadcast();

  /// Stream of incoming verification requests
  Stream<matrix.VerificationRequest> get onVerificationRequest => _requestController.stream;

  /// Get the singleton instance
  factory VerificationService() => _instance;

  VerificationService._internal();

  /// Initialize the verification service
  void initialize(matrix.Client client) {
    // Listen for incoming verification requests
    client.onVerificationRequest.stream.listen(_handleIncomingRequest);
  }

  /// Start a new verification request
  Future<matrix.VerificationRequest> startVerification({
    required String userId,
    String? deviceId,
    List<matrix.VerificationMethod> methods = const [
      matrix.VerificationMethod.emoji,
      matrix.VerificationMethod.decimal,
      matrix.VerificationMethod.qrCode,
    ],
  }) async {
    _logger.info('Starting verification with $userId${deviceId != null ? ' ($deviceId)' : ''}');

    final request = matrix.VerificationRequest(
      client: client,
      userId: userId,
      deviceId: deviceId,
      methods: methods,
    );

    _pendingRequests[request.transactionId] = request;

    // Start the verification process
    await request.start();

    return request;
  }

  /// Accept an incoming verification request
  Future<void> acceptVerification(
    String transactionId, {
    required matrix.VerificationMethod method,
  }) async {
    final request = _pendingRequests[transactionId];
    if (request == null) {
      throw Exception('Verification request not found');
    }

    _logger.info('Accepting verification request with method: ${method.toString().split('.').last}');
    await request.accept(method);
  }

  /// Cancel a verification request
  Future<void> cancelVerification(
    String transactionId, {
    matrix.VerificationCancelCode code = matrix.VerificationCancelCode.user,
    String? reason,
  }) async {
    final request = _pendingRequests[transactionId];
    if (request == null) return;

    _logger.info('Cancelling verification request');
    await request.cancel(
      code: code,
      reason: reason,
    );

    _pendingRequests.remove(transactionId);
  }

  /// Generate a QR code for verification
  Future<QrImage> generateQrCode(matrix.VerificationRequest request) async {
    // TODO: Implement QR code generation for verification
    // This would typically encode the transaction ID and other verification details
    throw UnimplementedError('QR code generation not implemented');
  }

  /// Handle an incoming verification request
  void _handleIncomingRequest(matrix.VerificationRequest request) {
    _logger.info('Received verification request from ${request.otherUser}');

    _pendingRequests[request.transactionId] = request;
    _requestController.add(request);

    // Set up request cleanup when completed
    request.onUpdate.listen((update) {
      if (update is matrix.VerificationDone || update is matrix.VerificationCancelled) {
        _pendingRequests.remove(request.transactionId);
      }
    });
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _requestController.close();

    // Cancel all pending requests
    for (final request in _pendingRequests.values) {
      await request.cancel(
        code: matrix.VerificationCancelCode.timeout,
        reason: 'Client shutting down',
      );
    }

    _pendingRequests.clear();
  }
}

/// Extension on VerificationRequest to add SAS verification methods
extension VerificationRequestExtension on matrix.VerificationRequest {
  /// Confirm that the SAS values match
  Future<void> confirmSasMatch() async {
    if (this is! matrix.SasVerificationRequest) {
      throw Exception('Not an SAS verification request');
    }

    await (this as matrix.SasVerificationRequest).confirmSasMatch();
  }

  /// Report that the SAS values do not match
  Future<void> mismatchSas() async {
    if (this is! matrix.SasVerificationRequest) {
      throw Exception('Not an SAS verification request');
    }

    await (this as matrix.SasVerificationRequest).mismatchSas();
  }

  /// Get the other user's ID
  String get otherUser => userId;

  /// Get the transaction ID
  String get transactionId => requestId;
}
