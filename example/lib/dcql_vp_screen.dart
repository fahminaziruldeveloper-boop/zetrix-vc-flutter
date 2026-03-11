import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:example/json_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

final _log = Logger(printer: PrettyPrinter());

// ─── Sample data pre-filled in the text fields ───────────────────────────────

const _samplePresentationRequest = '''{
  "object": {
    "credential_query": {
      "credentials": [
        {
          "id": "did:zid:ba4f1fcf68831a5c00000000",
          "format": "ldp_vc",
          "meta": {
            "vct_values": ["VerifiableCredential", "Driving License"]
          },
          "claims": [
            {
              "path": ["credentialSubject", "drivingLicense", "name"]
            },
            {
              "path": ["credentialSubject", "drivingLicense", "age"],
              "filter": {
                "type": "number",
                "minimum": 18
              }
            }
          ]
        }
      ]
    },
    "nonce": "15e49bc18f0eaec5abe3fa6381cff76b",
    "response_uri": "http://localhost:8080/v1/presentation/submit",
    "response_mode": "direct_post",
    "state": "user_session_123"
  }
}''';

const _sampleVc = '''{
  "id": "did:zid:59dc40120fe679a85a1d5aa671f730ac3806f05ccf4f0f539c727e130a2af01c",
  "type": ["VerifiableCredential", "Driving License"],
  "issuer": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
  "validFrom": "2025-12-01T00:00:00Z",
  "validUntil": "2026-12-02T00:00:00Z",
  "credentialSubject": {
    "id": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
    "drivingLicense": {
      "age": "21",
      "class": "B2",
      "name": "Ali bin Abu"
    }
  },
  "proof": [
    {
      "type": "BbsBlsSignature2020",
      "created": "2026-02-20T07:44:02.433275217Z",
      "proofPurpose": "assertionMethod",
      "proofValue": "usbyXgt5SiNN0RLduPZELH9rmP5GusuEOVuvYstZP_O19tciY0gLsWmDBP9gs-_3AaPJb78_aLxxNDcDjKXrmFwGQg8mYgBAu904MtqXP_mkdk3n0cxLW6k1GszE3wKSmzb2MMNiblKWknUkYvbySaA",
      "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#delegateKey-1"
    }
  ],
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://w3id.org/security/bbs/v1"
  ]
}''';

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Full-screen interactive example for [ZetrixVpService.createVPFromDCQL].
///
/// Allows the developer to paste a real `/v1/presentation/{id}` response,
/// paste the wallet VC, supply key material, and inspect the resulting
/// [VpSubmissionBody] JSON.
class DcqlVpScreen extends StatefulWidget {
  const DcqlVpScreen({super.key});

  @override
  State<DcqlVpScreen> createState() => _DcqlVpScreenState();
}

class _DcqlVpScreenState extends State<DcqlVpScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _processing = false;

  // ── Tab 1: Presentation request ───────────────────────────────────────────
  final _requestCtrl =
      TextEditingController(text: _samplePresentationRequest);

  // ── Tab 2: VC ─────────────────────────────────────────────────────────────
  final _vcCtrl = TextEditingController(text: _sampleVc);

  // ── Tab 3: Keys ───────────────────────────────────────────────────────────
  // Replace these with real holder key values when testing end-to-end.
  final _holderDidCtrl = TextEditingController(
      text: 'did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9');
  final _ed25519PubCtrl = TextEditingController(
      text: 'CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH');
  final _ed25519PrivCtrl = TextEditingController(
      text: 'privBxpL2meqP4CHanp4KRzRrabwCEnTgJx8DAddWkveUoZWiYmuHFZx');
  final _bbsPubCtrl = TextEditingController(
      text: 'zuKRSsZjMAYe1TgsnV5yUb9T3bbCqDEqQnCoaUkEXNomACZtZfxv1N4GVcRJmeiLpCwHaifjRjqqHewDcZcn9gW9nWvEiLb1cdgkYUxQfEoremhgeg8dfgkRvDifP6ypMp6U');
  final _bbsPrivCtrl = TextEditingController(
      text: ''); // optional — not used by BBS+ derivation step

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [
      _requestCtrl, _vcCtrl, _holderDidCtrl,
      _ed25519PubCtrl, _ed25519PrivCtrl, _bbsPubCtrl, _bbsPrivCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Processing ────────────────────────────────────────────────────────────

  Future<void> _run() async {
    // Validate JSON fields before doing any async work.
    Map<String, dynamic> requestJson;
    Map<String, dynamic> vcJson;

    try {
      requestJson =
          jsonDecode(_requestCtrl.text.trim()) as Map<String, dynamic>;
    } catch (_) {
      _showError('Presentation request is not valid JSON.');
      return;
    }

    try {
      vcJson = jsonDecode(_vcCtrl.text.trim()) as Map<String, dynamic>;
    } catch (_) {
      _showError('Verifiable Credential is not valid JSON.');
      return;
    }

    // Decode keys.
    Uint8List ed25519Priv;
    Uint8List bbsPriv;
    try {
      // Accept the private key with or without the 'priv' prefix.
      final privStr = _ed25519PrivCtrl.text.trim();
      final stripped = privStr.startsWith('priv') ? privStr.substring(4) : privStr;
      ed25519Priv = Uint8List.fromList(base58.decode(stripped));
    } catch (e) {
      _showError('Ed25519 private key is not valid base58.\n$e');
      return;
    }

    final bbsPrivRaw = _bbsPrivCtrl.text.trim();
    if (bbsPrivRaw.isNotEmpty) {
      try {
        // Accept hex string for BBS private key.
        bbsPriv = Uint8List.fromList(
          List.generate(
            bbsPrivRaw.length ~/ 2,
            (i) => int.parse(bbsPrivRaw.substring(i * 2, i * 2 + 2), radix: 16),
          ),
        );
      } catch (e) {
        _showError('BBS private key is not valid hex.\n$e');
        return;
      }
    } else {
      // Not required for BBS+ derivation — pass empty bytes as placeholder.
      bbsPriv = Uint8List(0);
    }

    final keys = WalletKeyMaterial(
      holderDid: _holderDidCtrl.text.trim(),
      ed25519PrivateKey: ed25519Priv,
      ed25519PublicKey: _ed25519PubCtrl.text.trim(),
      bbsPrivateKey: bbsPriv,
      bbsPublicKey: _bbsPubCtrl.text.trim(),
    );

    setState(() => _processing = true);

    try {
      final service = ZetrixVpService();
      final result = await service.createVPFromDCQL(
        presentationResponse: requestJson,
        vc: vcJson,
        keys: keys,
      );

      _log.i('✅ createVPFromDCQL succeeded');
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JsonViewScreen(
            jsonString: const JsonEncoder.withIndent('  ').convert(result.toJson()),
          ),
        ),
      );
    } on DcqlMatchException catch (e) {
      _log.w('DcqlMatchException: $e');
      _showError('No matching credential found.\n\n${e.message}');
    } on ClaimNotFoundException catch (e) {
      _log.w('ClaimNotFoundException: $e');
      _showError('Required field not found in VC.\n\n$e');
    } on RangeProofFailException catch (e) {
      _log.w('RangeProofFailException: $e');
      _showError('Value does not satisfy range requirement.\n\n$e');
    } on ProofCreationException catch (e) {
      _log.e('ProofCreationException: $e');
      _showError('Proof generation failed.\n\n${e.message}');
    } on JwtSigningException catch (e) {
      _log.e('JwtSigningException: $e');
      _showError('JWT signing failed.\n\n${e.message}');
    } catch (e, st) {
      _log.e('Unexpected error: $e\n$st');
      _showError('Unexpected error:\n$e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Copy',
          textColor: Colors.white,
          onPressed: () => Clipboard.setData(ClipboardData(text: message)),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create VP from DCQL'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Request'),
            Tab(icon: Icon(Icons.badge), text: 'VC'),
            Tab(icon: Icon(Icons.key), text: 'Keys'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear all fields',
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _requestCtrl.clear();
              _vcCtrl.clear();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _JsonInputTab(
                      controller: _requestCtrl,
                      hint:
                          'Paste the JSON response from\nGET /v1/presentation/{id}',
                      label: 'Presentation Request JSON',
                    ),
                    _JsonInputTab(
                      controller: _vcCtrl,
                      hint: 'Paste the Verifiable Credential JSON\nfrom wallet storage',
                      label: 'Verifiable Credential JSON',
                    ),
                    _KeysTab(
                      holderDidCtrl: _holderDidCtrl,
                      ed25519PubCtrl: _ed25519PubCtrl,
                      ed25519PrivCtrl: _ed25519PrivCtrl,
                      bbsPubCtrl: _bbsPubCtrl,
                      bbsPrivCtrl: _bbsPrivCtrl,
                    ),
                  ],
                ),
              ),
              _RunButton(processing: _processing, onPressed: _run),
            ],
          ),
          if (_processing)
            const _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

/// Tab with a single large JSON text area + a paste-from-clipboard shortcut.
class _JsonInputTab extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;

  const _JsonInputTab({
    required this.controller,
    required this.hint,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.content_paste, size: 16),
                label: const Text('Paste'),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    controller.text = data!.text!;
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: const Text('Format'),
                onPressed: () {
                  try {
                    final pretty = const JsonEncoder.withIndent('  ')
                        .convert(jsonDecode(controller.text));
                    controller.text = pretty;
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Not valid JSON — cannot format')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(fontFamily: 'monospace', fontSize: 12),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab with labelled text fields for wallet key material.
class _KeysTab extends StatelessWidget {
  final TextEditingController holderDidCtrl;
  final TextEditingController ed25519PubCtrl;
  final TextEditingController ed25519PrivCtrl;
  final TextEditingController bbsPubCtrl;
  final TextEditingController bbsPrivCtrl;

  const _KeysTab({
    required this.holderDidCtrl,
    required this.ed25519PubCtrl,
    required this.ed25519PrivCtrl,
    required this.bbsPubCtrl,
    required this.bbsPrivCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WalletKeyMaterial',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Replace placeholder values with your holder wallet keys.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _KeyField(
            label: 'Holder DID',
            hint: 'did:zid:...',
            controller: holderDidCtrl,
          ),
          _KeyField(
            label: 'Ed25519 Public Key (base58)',
            hint: 'base58-encoded Ed25519 public key',
            controller: ed25519PubCtrl,
          ),
          _KeyField(
            label: 'Ed25519 Private Key (base58, optional "priv" prefix)',
            hint: 'privXXXXX  or  XXXXX (base58 seed)',
            controller: ed25519PrivCtrl,
            obscure: true,
          ),
          _KeyField(
            label: 'BBS+ Public Key (base58, z-prefix)',
            hint: 'zXXXXXXXXX...',
            controller: bbsPubCtrl,
          ),
          _KeyField(
            label: 'BBS+ Private Key (hex, optional)',
            hint: 'hex string — not required for derivation proof',
            controller: bbsPrivCtrl,
            obscure: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              '⚠️  These keys are only used locally for proof generation.\n'
              'Never use production keys in a demo/test app.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;

  const _KeyField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
  });

  @override
  State<_KeyField> createState() => _KeyFieldState();
}

class _KeyFieldState extends State<_KeyField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: widget.controller,
        obscureText: _hidden,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle:
              const TextStyle(fontFamily: 'monospace', fontSize: 11),
          border: const OutlineInputBorder(),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                      _hidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidden = !_hidden),
                )
              : null,
        ),
      ),
    );
  }
}

/// Fixed bottom button — shows a spinner while processing.
class _RunButton extends StatelessWidget {
  final bool processing;
  final VoidCallback onPressed;

  const _RunButton({required this.processing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: processing ? null : onPressed,
            icon: processing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              processing ? 'Processing…' : 'Run createVPFromDCQL',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

/// Semi-transparent overlay that blocks interaction while processing.
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(80),
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating VP…', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// Tiny helper so `const SizedBox(height(4))` compiles correctly.
double height(double v) => v;
