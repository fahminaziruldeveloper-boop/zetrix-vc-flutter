import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:example/json_screen.dart';
import 'package:example/src/services/vc_service.dart';
import 'package:example/src/services/vp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:bs58/bs58.dart';
import 'package:logger/logger.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart'; // Import for RustLib
import 'qr_code.dart';

var logger = Logger(printer: PrettyPrinter());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZetrixVcFlutter().init(); // Initialize the Zetrix VC SDK
  runApp(const MyApp());
}

// Simple reusable ActionButton widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// Simple SectionHeader widget for section titles
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zetrix VC Plugin Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Zetrix VC SDK')),
        body: const Center(child: ZetrixSdkTestWidget()),
      ),
    );
  }
}

class ZetrixSdkTestWidget extends StatefulWidget {
  const ZetrixSdkTestWidget({super.key});

  @override
  State<ZetrixSdkTestWidget> createState() => _ZetrixSdkTestWidgetState();
}

class _ZetrixSdkTestWidgetState extends State<ZetrixSdkTestWidget> with WidgetsBindingObserver {

  // ── DCQL VP Demo ────────────────────────────────────────────────────────────

  /// Pops a dialog where the user pastes a presentation request JSON
  /// (from GET /v1/presentation/{id}), calls [ZetrixVpService.createVPFromDCQL],
  /// and pushes the resulting [VpSubmissionBody] to [JsonViewScreen].
  Future<void> _runDcqlVpDemo() async {
    const defaultRequest = '''{
  "object": {
    "credential_query": {
      "credentials": [
        {
          "id": "did:zid:ba4f1fcf68831a5c",
          "format": "ldp_vc",
          "meta": {
            "vct_values": ["VerifiableCredential", "IDENTITY CARD MALAYSIA"]
          },
          "claims": [
            {
              "path": ["credentialSubject", "nationality"],
              "constraints": { "const": "Malaysian" }
            },
            {
              "path": ["credentialSubject", "gender"],
              "constraints": { "enum": ["Male", "Female"] }
            },
            {
              "path": ["credentialSubject", "age"],
              "constraints": { "minimum": 18 }
            }
          ]
        }
      ]
    },
    "nonce": "15e49bc18f0eaec5abe3fa6381cff76b",
    "state": "user_session_demo",
    "response_uri": "http://localhost:8080/v1/presentation/submit",
    "response_mode": "direct_post"
  }
}''';

    final requestController = TextEditingController(text: defaultRequest);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DCQL Presentation Request'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste the JSON from GET /v1/presentation/{id}:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: requestController,
                maxLines: 14,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste presentation request JSON here…',
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate VP'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _result = '⏳ Generating DCQL VP…');

    // Demo VC provided by user (Identity Card Malaysia)
    const vcJson = '''{
        "id": "did:zid:798d3458a858771808b7c5957fef7c1d2aed6689b8364b9c1659d26478d05d3d",
        "type": [
          "VerifiableCredential",
          "IDENTITY CARD MALAYSIA"
        ],
        "issuer": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
        "validFrom": "2026-04-03T00:00:00Z",
        "validUntil": "2029-12-02T00:00:00Z",
        "credentialSubject": {
          "id": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
          "name": "muhammad harith",
          "DOB": "01-10-1990",
          "idNo": "901001014937",
          "nationality": "Malaysian",
          "gender": "Male",
          "age": 36
        },
        "proof": [
          {
            "type": "BbsBlsSignature2020",
            "created": "2026-03-04T06:14:13.255991952Z",
            "proofPurpose": "assertionMethod",
            "proofValue": "utxbeMnOkBuEp1F_ow-CL2hKXHHOD9I6XXa5steBfwG0gf6wnHPL5ekRwYMi5R-skXuK8cgBkqp7EIGQHysK97xcgZCNJWta1U5CPf5k0p2gLy6WuX_KmxIpFi0N05KypsbSid41LZdjiS8YF9Z8YMA",
            "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#delegateKey-1"
          },
          {
            "type": "Ed25519Signature2020",
            "created": "2026-03-04T06:14:13.256985568Z",
            "proofPurpose": "assertionMethod",
            "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#controllerKey",
            "jws": "ewogICJhbGciOiAiRWREU0EiCn0.ewogICJpZCIgOiAiZGlkOnppZDo3OThkMzQ1OGE4NTg3NzE4MDhiN2M1OTU3ZmVmN2MxZDJhZWQ2Njg5YjgzNjRiOWMxNjU5ZDI2NDc4ZDA1ZDNkIiwKICAidHlwZSIgOiBbICJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsICJJREVOVElUWSBDQVJEIE1BTEFZU0lBIiBdLAogICJpc3N1ZXIiIDogImRpZDp6aWQ6OWJlZTc2NTY3NGRlMDAwZGU3MzZjZDczZTIzNTM4OTBkZjFmZGI2YWMwZGY5ZWNjM2E1YTc4YTRhZmVlMDNhOSIsCiAgInZhbGlkRnJvbSIgOiAiMjAyNi0wNC0wM1QwMDowMDowMFoiLAogICJ2YWxpZFVudGlsIiA6ICIyMDI5LTEyLTAyVDAwOjAwOjAwWiIsCiAgImNyZWRlbnRpYWxTdWJqZWN0IiA6IHsKICAgICJpZCIgOiAiZGlkOnppZDo5YmVlNzY1Njc0ZGUwMDBkZTczNmNkNzNlMjM1Mzg5MGRmMWZkYjZhYzBkZjllY2MzYTVhNzhhNGFmZWUwM2E5IiwKICAgICJpZGVudGl0eUNhcmRNYWxheXNpYSIgOiB7CiAgICAgICJuYW1lIiA6ICJtdWhhbW1hZCBoYXJpdGgiLAogICAgICAiRE9CIiA6ICIwMS0xMC0xOTkwIiwKICAgICAgImlkTm8iIDogOTAxMDAxMDE0OTM3LAogICAgICAiZ2VuZGVyIiA6ICJNYWxlIiwKICAgICAgImFnZSIgOiAzNgogICAgfQogIH0sCiAgIkBjb250ZXh0IiA6IFsgImh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL3YxIiwgImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwgImh0dHBzOi8vdGVzdC1ub2RlLnpldHJpeC5jb20vZ2V0QWNjb3VudE1ldGFEYXRhP2FkZHJlc3M9WlRYM0pzenFQZ1JVeDc0M1NBcDdxN3pVUmZqdmtXdUgyRk1FeiZrZXk9dGVtcGxhdGVfX2RpZDp6aWQ6NmFkODM4NGZmZmJjNmY3NzJjNWVmN2ZjMDNjOWRkMDkzY2JkMDRiNTc2ZmU2ZmIyMzYyZDZmNDgwZTdmN2JhOSIgXQp9.NkFFQjE2NjdGRjdGNjc1NzY4M0FFNjVFMDgwMjdFNkIwOEIwQUIyMDFCMDQ0NzRBNENENEE0MjU3NDkxQ0YwNzIxM0IxREJEOEY4QTE1MEVCNDdCQjg0OTlCMTREQkNBODhCNzE5Q0QxRDYxRTk1QTg5QzU3NkExMzVERjg5MDk"
          }
        ],
        "@context": [
          "https://www.w3.org/2018/credentials/v1",
          "https://w3id.org/security/bbs/v1",
          "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:6ad8384fffbc6f772c5ef7fc03c9dd093cbd04b576fe6fb2362d6f480e7f7ba9"
        ]
      }''';

    // Decode holder Ed25519 private key seed.
    // Zetrix format: "privB..." → strip "priv", base58-decode → first 32 bytes.
    // Use user-supplied keys
    Uint8List ed25519Seed;
    try {
      const rawPrivKey = 'privBueqLZ7z5eMUpSpgxsdaZqehtnSCkzzrjBQHFpmYXR28kor3ucm5';
      final decoded = base58.decode(rawPrivKey.substring(4));
      ed25519Seed = Uint8List.fromList(decoded.take(32).toList());
    } catch (_) {
      ed25519Seed = Uint8List(32);
    }

    // Decode provided BBS private key (strip leading 'z' if present)
    Uint8List bbsSeed;
    try {
      final rawBbs = 'z3Wyh9R6dvUR1YyCiJMb1LQEt9EsEYFihB2Yo1cBjHh46';
      final strippedBbs = rawBbs.startsWith('z') ? rawBbs.substring(1) : rawBbs;
      bbsSeed = Uint8List.fromList(base58.decode(strippedBbs).take(32).toList());
    } catch (_) {
      bbsSeed = Uint8List(32);
    }

    final keys = WalletKeyMaterial(
      holderDid:
          'did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9',
      ed25519PrivateKey: ed25519Seed,
      ed25519PublicKey:
          'b0019bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9c8b47173',
      bbsPrivateKey: bbsSeed,
      bbsPublicKey:
          'z23VEBWyZUQGqU5e43dJDwxBGYi4mosy3gm1PQgqQod7qZbeWKfUboofmeUjtHNZusGZXv7ZUSG3ehjyzzo5d6XghCezk4rYyXKosEctzgDeHfQppGuXstCQGWrE37S1K8KLB',
    );

    try {
      final requestMap =
          jsonDecode(requestController.text) as Map<String, dynamic>;
      final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;

      final result = await zetrixVpService.createVPFromDCQL(
        presentationResponse: requestMap,
        vc: vcMap,
        keys: keys,
      );

      logger.i('✅ DCQL VP generated');
      setState(() => _result = '✅ DCQL VP generated');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JsonViewScreen(jsonString: jsonEncode(result.toJson())),
        ),
      );
    } on DcqlMatchException catch (e) {
      logger.e('DcqlMatchException: $e');
      setState(() => _result = '❌ No matching credential');
      if (!mounted) return;
      _showDcqlErrorDialog('No Matching Credential', e.message);
    } on ClaimNotFoundException catch (e) {
      logger.e('ClaimNotFoundException: $e');
      setState(() => _result = '❌ Claim not found: ${e.path}');
      if (!mounted) return;
      _showDcqlErrorDialog(
          'Claim Not Found', 'Required field missing in VC:\n${e.path}');
    } on RangeProofFailException catch (e) {
      logger.e('RangeProofFailException: $e');
      setState(() => _result = '❌ Does not meet requirements');
      if (!mounted) return;
      _showDcqlErrorDialog('Requirement Not Met',
          'Field "${e.fieldName}" = ${e.value} does not satisfy '
          '[min=${e.minimum ?? "—"}, max=${e.maximum ?? "—"}]');
    } on ProofCreationException catch (e) {
      logger.e('ProofCreationException: $e');
      setState(() => _result = '❌ Proof generation failed');
      if (!mounted) return;
      _showDcqlErrorDialog('Proof Generation Failed', e.message);
    } catch (e, st) {
      logger.e('DCQL VP error', error: e, stackTrace: st);
      setState(() => _result = '❌ Error: $e');
      if (!mounted) return;
      _showDcqlErrorDialog('Error', e.toString());
    }
  }

  // ── DCQL VP Real Demo (user-supplied keys + VC) ──────────────────────────

  Future<void> _runDcqlVpDemoReal() async {
    final requestCtrl = TextEditingController();
    final holderDidCtrl = TextEditingController();
    final ed25519PrivCtrl = TextEditingController();
    final ed25519PubCtrl = TextEditingController();
    final bbsPrivCtrl = TextEditingController();
    final bbsPubCtrl = TextEditingController();
    final vcCtrl = TextEditingController();

    // Local helper to build a labelled text field
    Widget buildField({
      required String label,
      required TextEditingController ctrl,
      int maxLines = 1,
      String hint = '',
      bool optional = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              optional ? '$label (optional)' : label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: ctrl,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 11),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ],
        ),
      );
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DCQL VP — Real Demo'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildField(
                  label: 'Presentation Request JSON',
                  ctrl: requestCtrl,
                  maxLines: 6,
                  hint: '{ "object": { "credential_query": … } }',
                ),
                const Divider(height: 20),
                const Text(
                  'Wallet Key Material',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                const SizedBox(height: 8),
                buildField(
                  label: 'holderDid',
                  ctrl: holderDidCtrl,
                  hint: 'did:zid:…',
                ),
                buildField(
                  label: 'ed25519PrivateKey',
                  ctrl: ed25519PrivCtrl,
                  hint: 'privB… (Zetrix format)',
                ),
                buildField(
                  label: 'ed25519PublicKey',
                  ctrl: ed25519PubCtrl,
                  hint: 'hex string, e.g. b001…',
                ),
                buildField(
                  label: 'bbsPrivateKey',
                  ctrl: bbsPrivCtrl,
                  hint: 'privB… or leave blank',
                  optional: true,
                ),
                buildField(
                  label: 'bbsPublicKey (issuer BLS key)',
                  ctrl: bbsPubCtrl,
                  hint: 'z… (multibase BLS12-381 G2)',
                ),
                const Divider(height: 20),
                buildField(
                  label: 'Verifiable Credential JSON',
                  ctrl: vcCtrl,
                  maxLines: 8,
                  hint: '{ "@context": […], "type": […], "proof": […], … }',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate VP'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _result = '⏳ Generating DCQL VP…');

    // ── Decode Ed25519 private key (Zetrix privB… format) ───────────────────
    Uint8List ed25519Seed;
    try {
      final raw = ed25519PrivCtrl.text.trim();
      final stripped = raw.startsWith('priv') ? raw.substring(4) : raw;
      ed25519Seed =
          Uint8List.fromList(base58.decode(stripped).take(32).toList());
    } catch (e) {
      setState(() => _result = '❌ Invalid ed25519PrivateKey');
      _showDcqlErrorDialog('Invalid Key',
          'Could not decode ed25519PrivateKey.\n'
          'Expected Zetrix "privB…" format.\n\nError: $e');
      return;
    }

    // ── Decode BBS private key (optional, zeros if blank) ───────────────────
    Uint8List bbsSeed;
    final bbsPrivRaw = bbsPrivCtrl.text.trim();
    if (bbsPrivRaw.isEmpty) {
      bbsSeed = Uint8List(32);
    } else {
      try {
        final stripped = bbsPrivRaw.startsWith('priv')
            ? bbsPrivRaw.substring(4)
            : bbsPrivRaw;
        bbsSeed =
            Uint8List.fromList(base58.decode(stripped).take(32).toList());
      } catch (e) {
        setState(() => _result = '❌ Invalid bbsPrivateKey');
        _showDcqlErrorDialog('Invalid Key',
            'Could not decode bbsPrivateKey.\nLeave blank to use zeros.\n\nError: $e');
        return;
      }
    }

    final keys = WalletKeyMaterial(
      holderDid: holderDidCtrl.text.trim(),
      ed25519PrivateKey: ed25519Seed,
      ed25519PublicKey: ed25519PubCtrl.text.trim(),
      bbsPrivateKey: bbsSeed,
      bbsPublicKey: bbsPubCtrl.text.trim(),
    );

    try {
      final requestMap =
          jsonDecode(requestCtrl.text.trim()) as Map<String, dynamic>;
      final vcMap = jsonDecode(vcCtrl.text.trim()) as Map<String, dynamic>;

      final result = await zetrixVpService.createVPFromDCQL(
        presentationResponse: requestMap,
        vc: vcMap,
        keys: keys,
      );

      logger.i('✅ DCQL VP (real) generated');
      setState(() => _result = '✅ DCQL VP generated');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JsonViewScreen(jsonString: jsonEncode(result.toJson())),
        ),
      );
    } on DcqlMatchException catch (e) {
      logger.e('DcqlMatchException: $e');
      setState(() => _result = '❌ No matching credential');
      if (!mounted) return;
      _showDcqlErrorDialog('No Matching Credential', e.message);
    } on ClaimNotFoundException catch (e) {
      logger.e('ClaimNotFoundException: $e');
      setState(() => _result = '❌ Claim not found: ${e.path}');
      if (!mounted) return;
      _showDcqlErrorDialog(
          'Claim Not Found', 'Required field missing in VC:\n${e.path}');
    } on RangeProofFailException catch (e) {
      logger.e('RangeProofFailException: $e');
      setState(() => _result = '❌ Does not meet requirements');
      if (!mounted) return;
      _showDcqlErrorDialog('Requirement Not Met',
          'Field "${e.fieldName}" = ${e.value} does not satisfy '
          '[min=${e.minimum ?? "—"}, max=${e.maximum ?? "—"}]');
    } on ProofCreationException catch (e) {
      logger.e('ProofCreationException: $e');
      setState(() => _result = '❌ Proof generation failed');
      if (!mounted) return;
      _showDcqlErrorDialog('Proof Generation Failed', e.message);
    } catch (e, st) {
      logger.e('DCQL VP (real) error', error: e, stackTrace: st);
      setState(() => _result = '❌ Error: $e');
      if (!mounted) return;
      _showDcqlErrorDialog('Error', e.toString());
    }
  }

  Future<void> _runDcqlVpDemoPresentationRequestandVC() async {
    final prCtrl = TextEditingController();
    final vcCtrl = TextEditingController();

    final generate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste Presentation Request and VC'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Presentation Request (JSON)')),
              const SizedBox(height: 8),
              TextField(controller: prCtrl, maxLines: 8, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: Text('Verifiable Credential (JSON)')),
              const SizedBox(height: 8),
              TextField(controller: vcCtrl, maxLines: 8, decoration: const InputDecoration(border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate')),
        ],
      ),
    );

    if (generate != true) return;

    setState(() => _result = '⏳ Generating DCQL VP (presentation+vc)...');

    try {
      final presentationResponse = jsonDecode(prCtrl.text.trim()) as Map<String, dynamic>;
      final vc = jsonDecode(vcCtrl.text.trim()) as Map<String, dynamic>;

      // Build WalletKeyMaterial from provided constants (fall back to zeros on error)
      Uint8List ed25519Seed;
      try {
        const rawPrivKey = 'privBueqLZ7z5eMUpSpgxsdaZqehtnSCkzzrjBQHFpmYXR28kor3ucm5';
        final decoded = base58.decode(rawPrivKey.substring(4));
        ed25519Seed = Uint8List.fromList(decoded.take(32).toList());
      } catch (_) {
        ed25519Seed = Uint8List(32);
      }

      Uint8List bbsSeed;
      try {
        final rawBbs = 'z6sdSJeEaj1GYt4urS4GmaNJ59tc6gQMDqjU6PVubTpSq';
        final stripped = rawBbs.startsWith('z') ? rawBbs.substring(1) : rawBbs;
        bbsSeed = Uint8List.fromList(base58.decode(stripped).take(32).toList());
      } catch (_) {
        bbsSeed = Uint8List(32);
      }

      final keys = WalletKeyMaterial(
        holderDid: 'did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9',
        ed25519PrivateKey: ed25519Seed,
        ed25519PublicKey: 'b0019bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9c8b47173',
        bbsPrivateKey: bbsSeed,
        bbsPublicKey:
            'z23VEBWyZUQGqU5e43dJDwxBGYi4mosy3gm1PQgqQod7qZbeWKfUboofmeUjtHNZusGZXv7ZUSG3ehjyzzo5d6XghCezk4rYyXKosEctzgDeHfQppGuXstCQGWrE37S1K8KLB',
      );

      final result = await zetrixVpService.createVPFromDCQL(
        presentationResponse: presentationResponse,
        vc: vc,
        keys: keys,
      );

      logger.i('✅ DCQL VP (presentation+vc) generated');
      setState(() => _result = '✅ DCQL VP generated');
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JsonViewScreen(jsonString: jsonEncode(result.toJson()))),
      );
    } on FormatException catch (e) {
      _showDcqlErrorDialog('Invalid JSON', e.toString());
    } on DcqlMatchException catch (e) {
      _showDcqlErrorDialog('No Matching Credential', e.message);
    } on ClaimNotFoundException catch (e) {
      _showDcqlErrorDialog('Claim Not Found', 'Required field missing: ${e.path}');
    } on RangeProofFailException catch (e) {
      _showDcqlErrorDialog('Requirement Not Met', 'Field ${e.fieldName} value=${e.value} not in [${e.minimum},${e.maximum}]');
    } on ProofCreationException catch (e) {
      _showDcqlErrorDialog('Proof Generation Failed', e.message);
    } catch (e, st) {
      logger.e('DCQL VP (presentation+vc) error', error: e, stackTrace: st);
      _showDcqlErrorDialog('Error', e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  /// Demo: createVpLite with range proof for age >= 18
  Future<void> _runVpLiteRangeProofDemo() async {
    final vcCtrl = TextEditingController();

    final generate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VP Lite with Range Proof (Age ≥ 18)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Paste your Identity Card VC JSON:\n'
                  '(will reveal identityCardMalaysia.age and prove age ≥ 18)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: vcCtrl,
                maxLines: 10,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate VP')),
        ],
      ),
    );

    if (generate != true) return;

    setState(() => _result = '⏳ Generating VP Lite with range proof...');

    try {
      final vcMap = jsonDecode(vcCtrl.text.trim()) as Map<String, dynamic>;
      final vc = VerifiableCredential.fromJson(vcMap);

      // Reveal attribute for selective disclosure
      final revealAttribute = ["identityCardMalaysia.age"];

      // Range proof: prove age >= 18 (without revealing exact value)
      final rangeProofRequest = RangeProofRequest(
        attributes: ["identityCardMalaysia.age"],
        minValues: [18],
        maxValues: [BulletproofUtil.noMaxValue], // No upper limit
        bits: 32,
        domain: 'age-verification',
      );

      // BLS public key from the VC issuer
      const String issuerBlsPublicKey =
          'z23VEBWyZUQGqU5e43dJDwxBGYi4mosy3gm1PQgqQod7qZbeWKfUboofmeUjtHNZusGZXv7ZUSG3ehjyzzo5d6XghCezk4rYyXKosEctzgDeHfQppGuXstCQGWrE37S1K8KLB';
      const String holderPublicKey = 'b0019bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9c8b47173';

      final ZetrixSDKResult<String> result = await zetrixVpService.createVpLite(
        vc,
        revealAttribute,
        issuerBlsPublicKey,
        holderPublicKey,
        rangeProofRequest,
      );

      if (result is Success<String> && result.data != null) {
        logger.i('✅ VP Lite with range proof generated!');
        setState(() => _result = '✅ VP generated successfully');
        if (!mounted) return;

        // Parse and display result
        try {
          var parsedJson = jsonDecode(result.data!);
          if (parsedJson is! Map) {
            parsedJson = {'vpCompressed': parsedJson};
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(jsonString: jsonEncode(parsedJson)),
            ),
          );
        } catch (e) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(
                jsonString: jsonEncode({'vpCompressed': result.data!}),
              ),
            ),
          );
        }
      } else if (result is Failure) {
        final failure = result as Failure;
        logger.e('❌ VP generation failed: ${failure.error}');
        setState(() => _result = '❌ VP generation failed: ${failure.error}');
        if (!mounted) return;
        _showDcqlErrorDialog('VP Generation Failed', failure.error.toString());
      } else {
        setState(() => _result = '❌ Unknown error');
      }
    } on FormatException catch (e) {
      logger.e('Invalid JSON: $e');
      _showDcqlErrorDialog('Invalid JSON', e.toString());
    } catch (e, stackTrace) {
      logger.e('❌ Exception during VP Lite generation: $e', stackTrace: stackTrace);
      setState(() => _result = '❌ Exception: ${e.toString()}');
      _showDcqlErrorDialog('Error', e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _showDcqlErrorDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: SelectableText(body)),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: body));
              Navigator.pop(ctx);
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showExampleBulletproofVC() async {
    // Use Driving License VC data for bulletproof VP generation
      const vcJson = '''{
            "id": "did:zid:eb25b601831d5a11f7412f6beef0eb8abe9c554b78ff9a2684b1fa218f4a1eb5",
            "type": [
                "VerifiableCredential",
                "IDENTITY CARD MALAYSIA"
            ],
            "issuer": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
            "validFrom": "2026-02-15T00:00:00Z",
            "validUntil": "2036-12-31T00:00:00Z",
            "credentialSubject": {
                "id": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
                "identityCardMalaysia": {
                    "name": "muhammad harith",
                    "DOB": "01-10-1990",
                    "idNo": 901001014937,
                    "gender": "Male",
                    "age": 36
                }
            },
            "proof": [
                {
                    "type": "BbsBlsSignature2020",
                    "created": "2026-03-06T00:07:08.102236052Z",
                    "proofPurpose": "assertionMethod",
                    "proofValue": "uqYfjajSZfrUjkJ5cn3G74iOKQYV-he-IiHE3aMzt2LTTnaQsEqN8ENX-ba6w11WFK27CizcCmwmC8D7IkTRrozjTW3isUNE0k_Y1mFYwTZFksEEU5_AKzoqhqAGdaUFYLO9kZaG78FZh8Y2NygMeYw",
                    "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#delegateKey-3"
                },
                {
                    "type": "Ed25519Signature2020",
                    "created": "2026-03-06T00:07:08.103848738Z",
                    "proofPurpose": "assertionMethod",
                    "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#controllerKey",
                    "jws": "ewogICJhbGciOiAiRWREU0EiCn0.ewogICJpZCIgOiAiZGlkOnppZDplYjI1YjYwMTgzMWQ1YTExZjc0MTJmNmJlZWYwZWI4YWJlOWM1NTRiNzhmZjlhMjY4NGIxZmEyMThmNGExZWI1IiwKICAidHlwZSIgOiBbICJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsICJJREVOVElUWSBDQVJEIE1BTEFZU0lBIiBdLAogICJpc3N1ZXIiIDogImRpZDp6aWQ6OWJlZTc2NTY3NGRlMDAwZGU3MzZjZDczZTIzNTM4OTBkZjFmZGI2YWMwZGY5ZWNjM2E1YTc4YTRhZmVlMDNhOSIsCiAgInZhbGlkRnJvbSIgOiAiMjAyNi0wMi0xNVQwMDowMDowMFoiLAogICJ2YWxpZFVudGlsIiA6ICIyMDM2LTEyLTMxVDAwOjAwOjAwWiIsCiAgImNyZWRlbnRpYWxTdWJqZWN0IiA6IHsKICAgICJpZCIgOiAiZGlkOnppZDo5YmVlNzY1Njc0ZGUwMDBkZTczNmNkNzNlMjM1Mzg5MGRmMWZkYjZhYzBkZjllY2MzYTVhNzhhNGFmZWUwM2E5IiwKICAgICJpZGVudGl0eUNhcmRNYWxheXNpYSIgOiB7CiAgICAgICJuYW1lIiA6ICJtdWhhbW1hZCBoYXJpdGgiLAogICAgICAiRE9CIiA6ICIwMS0xMC0xOTkwIiwKICAgICAgImlkTm8iIDogOTAxMDAxMDE0OTM3LAogICAgICAiZ2VuZGVyIiA6ICJNYWxlIiwKICAgICAgImFnZSIgOiAzNgogICAgfQogIH0sCiAgIkBjb250ZXh0IiA6IFsgImh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL3YxIiwgImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwgImh0dHBzOi8vdGVzdC1ub2RlLnpldHJpeC5jb20vZ2V0QWNjb3VudE1ldGFEYXRhP2FkZHJlc3M9WlRYM0pzenFQZ1JVeDc0M1NBcDdxN3pVUmZqdmtXdUgyRk1FeiZrZXk9dGVtcGxhdGVfX2RpZDp6aWQ6NmFkODM4NGZmZmJjNmY3NzJjNWVmN2ZjMDNjOWRkMDkzY2JkMDRiNTc2ZmU2ZmIyMzYyZDZmNDgwZTdmN2JhOSIgXQp9.N0RGQzQyMjMxRUEwQUVBNTVBQzk1QzIzRTc4OUQ4NkYyQUU2NDIwQkIzOUQ3N0U0Mjk4MzM4NDAyMDhGNDRCMzY2RDYwQzlGMDExRDZDNTU1MTRDRTE4QzAyQ0JFMUM1QTJEQUI4MTYyQTVFMTgyMTM4RkI4QTYyNDk4RDMwMDk"
                }
            ],
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/bbs/v1",
                "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:6ad8384fffbc6f772c5ef7fc03c9dd093cbd04b576fe6fb2362d6f480e7f7ba9"
            ]
        }''';

    final revealAttribute = ["identityCardMalaysia.age"];
    final proofAttributes = ["identityCardMalaysia.age"];
    final minValues = [18];
    final maxValues = [50];
    const String domain = 'age-range-proof';
    const int bits = 32;
    final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;
    final vc = VerifiableCredential.fromJson(vcMap);

    final rangeProofRequest = RangeProofRequest(
      attributes: proofAttributes,
      minValues: minValues,
      maxValues: maxValues,
      bits: bits,
      domain: domain,
    );
    final ZetrixSDKResult<String> vp = await zetrixVpService.createVp(
      vc,
      revealAttribute,
      'z23VEBWyZUQGqU5e43dJDwxBGYi4mosy3gm1PQgqQod7qZbeWKfUboofmeUjtHNZusGZXv7ZUSG3ehjyzzo5d6XghCezk4rYyXKosEctzgDeHfQppGuXstCQGWrE37S1K8KLB',
      'b0019bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9c8b47173',
      'privBueqLZ7z5eMUpSpgxsdaZqehtnSCkzzrjBQHFpmYXR28kor3ucm5',
      rangeProofRequest,
    );
    if (!mounted) return;
    if (vp is Success<String> && vp.data != null) {
      logger.i('✅ Lite VP with Bulletproof generated!');
      if (!mounted) return;
      try {
        // Try parsing as JSON directly
        final parsedJson = jsonDecode(vp.data!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JsonViewScreen(jsonString: jsonEncode(parsedJson)),
          ),
        );
      } catch (e1) {
        try {
          // Fallback: decode base64 and decompress gzip
          final compressed = base64.decode(vp.data!);
          final decompressed = gzip.decode(compressed);
          final parsedJson = jsonDecode(utf8.decode(decompressed));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(jsonString: jsonEncode(parsedJson)),
            ),
          );
        } catch (e2) {
          final errorJson = {
            'error': 'Invalid JSON returned from createVp',
            'rawResult': vp.data,
            'exception': 'Direct JSON error: ${e1.toString()}\nDecode error: ${e2.toString()}',
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(jsonString: jsonEncode(errorJson)),
            ),
          );
          setState(() => _result = '❌ VP generation failed: Invalid JSON returned');
        }
      }
    } else if (vp is Failure) {
      final failure = vp as Failure;
      final errorJson = {
        'error': 'VP generation failed',
        'details': failure.error.toString(),
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JsonViewScreen(jsonString: jsonEncode(errorJson)),
        ),
      );
      setState(() => _result = '❌ VP generation failed: \n${failure.error}');
    } else {
      setState(() => _result = '❌ VP generation failed: Unknown error');
    }
  }

  Future<void> _generateLiteVpWithBulletproof() async {
    // Example VC with drivingLicense credential
    const vcJson = '''{
            "id": "did:zid:8a8447142bce8a7afd2ac8466d5dc513c529a2a9b5739d44872e581b5cb1249a",
            "type": [
                "VerifiableCredential",
                "IDENTITY CARD MALAYSIA"
            ],
            "issuer": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
            "validFrom": "2026-02-15T00:00:00Z",
            "validUntil": "2036-12-31T00:00:00Z",
            "credentialSubject": {
                "id": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9",
                "identityCardMalaysia": {
                    "name": "muhammad harith",
                    "DOB": "01-10-1990",
                    "idNo": 901001014937,
                    "gender": "Male",
                    "age": 36
                }
            },
            "proof": [
                {
                    "type": "BbsBlsSignature2020",
                    "created": "2026-03-05T11:01:44.095235758Z",
                    "proofPurpose": "assertionMethod",
                    "proofValue": "urlUPLwE-zHH6GRtW5sI09jcVaAYbLa6f2r6o7f9uTQPXiYqi2DEYMpNiM8T9BOqGHMYu-QsMUgoP_jG9YU1eAayZ0GztdBe86LTPkFm_T7gGqWhPH0xjrrVtTyshONb1TQguIkH47qqHwKHheyAgYQ",
                    "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#delegateKey-3"
                },
                {
                    "type": "Ed25519Signature2020",
                    "created": "2026-03-05T11:01:44.106170963Z",
                    "proofPurpose": "assertionMethod",
                    "verificationMethod": "did:zid:9bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9#controllerKey",
                    "jws": "ewogICJhbGciOiAiRWREU0EiCn0.ewogICJpZCIgOiAiZGlkOnppZDo4YTg0NDcxNDJiY2U4YTdhZmQyYWM4NDY2ZDVkYzUxM2M1MjlhMmE5YjU3MzlkNDQ4NzJlNTgxYjVjYjEyNDlhIiwKICAidHlwZSIgOiBbICJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsICJJREVOVElUWSBDQVJEIE1BTEFZU0lBIiBdLAogICJpc3N1ZXIiIDogImRpZDp6aWQ6OWJlZTc2NTY3NGRlMDAwZGU3MzZjZDczZTIzNTM4OTBkZjFmZGI2YWMwZGY5ZWNjM2E1YTc4YTRhZmVlMDNhOSIsCiAgInZhbGlkRnJvbSIgOiAiMjAyNi0wMi0xNVQwMDowMDowMFoiLAogICJ2YWxpZFVudGlsIiA6ICIyMDM2LTEyLTMxVDAwOjAwOjAwWiIsCiAgImNyZWRlbnRpYWxTdWJqZWN0IiA6IHsKICAgICJpZCIgOiAiZGlkOnppZDo5YmVlNzY1Njc0ZGUwMDBkZTczNmNkNzNlMjM1Mzg5MGRmMWZkYjZhYzBkZjllY2MzYTVhNzhhNGFmZWUwM2E5IiwKICAgICJpZGVudGl0eUNhcmRNYWxheXNpYSIgOiB7CiAgICAgICJuYW1lIiA6ICJtdWhhbW1hZCBoYXJpdGgiLAogICAgICAiRE9CIiA6ICIwMS0xMC0xOTkwIiwKICAgICAgImlkTm8iIDogOTAxMDAxMDE0OTM3LAogICAgICAiZ2VuZGVyIiA6ICJNYWxlIiwKICAgICAgImFnZSIgOiAzNgogICAgfQogIH0sCiAgIkBjb250ZXh0IiA6IFsgImh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL3YxIiwgImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwgImh0dHBzOi8vdGVzdC1ub2RlLnpldHJpeC5jb20vZ2V0QWNjb3VudE1ldGFEYXRhP2FkZHJlc3M9WlRYM0pzenFQZ1JVeDc0M1NBcDdxN3pVUmZqdmtXdUgyRk1FeiZrZXk9dGVtcGxhdGVfX2RpZDp6aWQ6NmFkODM4NGZmZmJjNmY3NzJjNWVmN2ZjMDNjOWRkMDkzY2JkMDRiNTc2ZmU2ZmIyMzYyZDZmNDgwZTdmN2JhOSIgXQp9.OEVFMjBEMTJEQTU3RkZFQzRFMEQxRUJDN0JGMUQxOEY0N0QzODlFMzQxNThENTZGNDBDRTA2Q0FGRUREOTQzRDlBMTI2NTAxODBCMzFBNDFDRkQ0MEYyN0UzRDhFNTcyNENCNTgwQTJFNTA0OUEzNkRCMDYyRTM2Q0FGMjVDMDY"
                }
            ],
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/bbs/v1",
                "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:6ad8384fffbc6f772c5ef7fc03c9dd093cbd04b576fe6fb2362d6f480e7f7ba9"
            ]
        }''';

    final revealAttribute = ["identityCardMalaysia.age"];
    final proofAttributes = ["identityCardMalaysia.age"];
    final minValues = [18];
    final maxValues = [50];
    const String domain = 'age-range-proof';
    const int bits = 32;

    try {
      setState(() => _result = '⏳ Generating Lite VP with Bulletproof...');
      final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;
      final vc = VerifiableCredential.fromJson(vcMap);

      // The BLS public key must match the issuer's BLS key that signed the VC
      const String issuerBlsPublicKey = 'z23VEBWyZUQGqU5e43dJDwxBGYi4mosy3gm1PQgqQod7qZbeWKfUboofmeUjtHNZusGZXv7ZUSG3ehjyzzo5d6XghCezk4rYyXKosEctzgDeHfQppGuXstCQGWrE37S1K8KLB';
      const String holderPublicKey = 'b0019bee765674de000de736cd73e2353890df1fdb6ac0df9ecc3a5a78a4afee03a9c8b47173';

      final rangeProofRequest = RangeProofRequest(
        attributes: proofAttributes,
        minValues: minValues,
        maxValues: maxValues,
        bits: bits,
        domain: domain,
      );

      final ZetrixSDKResult<String> result = await zetrixVpService.createVpLite(
        vc,
        revealAttribute,
        issuerBlsPublicKey,
        holderPublicKey,
        rangeProofRequest,
      );

      if (result is Success<String> && result.data != null) {
        logger.i('✅ Lite VP with Bulletproof generated!');
        if (!mounted) return;
        try {
          var parsedJson = jsonDecode(result.data!);
          if (parsedJson is! Map) {
            parsedJson = {'result': parsedJson};
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(jsonString: jsonEncode(parsedJson)),
            ),
          );
        } catch (e) {
          // If not valid JSON, show as string in an object
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonViewScreen(jsonString: jsonEncode({'result': result.data!})),
            ),
          );
        }
      } else if (result is Failure) {
        final failure = result as Failure;
        final errorJson = {
          'error': 'VP generation failed',
          'details': failure.error.toString(),
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JsonViewScreen(jsonString: jsonEncode(errorJson)),
          ),
        );
        setState(() => _result = '❌ VP generation failed: \n${failure.error}');
      } else {
        setState(() => _result = '❌ VP generation failed: Unknown error');
      }
    } catch (e, stackTrace) {
      logger.e('❌ Exception during Lite VP generation: $e');
      logger.e('Stack trace: $stackTrace');
      setState(() => _result = '❌ Exception: ${e.toString()}');
    }
  }
  String _result = 'Tap the button to start.';
  ZetrixVpService zetrixVpService = ZetrixVpService();
  final _dio = ZetrixVcFlutter().dio;
  final network = ZetrixVcFlutter().isMainnet;
  late final VcService vcService;
  late final VpService vpService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    vcService = VcService(_dio, network);
    vpService = VpService(_dio, network);
    zetrixVpService = ZetrixVpService(dio: _dio, isMainnet: network);
  }

  /// Shows a dialog informing that BBS+ is not available on Windows
  void _showWindowsNotSupported() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('BBS+ Not Available on Windows'),
        content: const Text(
          'BBS+ selective disclosure proofs are not available on Windows desktop.\n\n'
          'BBS+ works on iOS and Android.\n\n'
          'For Windows, use Bulletproof range proofs instead (fully functional).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateVP() async {
    // BBS+ not available on Windows
    if (Platform.isWindows) {
      _showWindowsNotSupported();
      return;
    }

    const vcJson = '''{
            "id": "did:zid:6601378b18e96707d25b2070fd7125549ece3f2e3ad4b5e1dda67d262975ba4f",
            "type": [
                "VerifiableCredential",
                "TestPassport"
            ],
            "issuer": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff",
            "issuanceDate": "2025-06-17T00:00:00Z",
            "expirationDate": "2035-06-17T00:00:00Z",
            "credentialSubject": {
                "id": "did:zid:eff30af3427a38c5cd021f5ac28578d27c3bd1ab53fc4d2789c1f8cb1827e83c",
                "testPassport": {
                    "name": "John Doeee",
                    "dob": "1990-01-01",
                    "gender": "Male",
                    "nationality": "Myanmarese",
                    "identityNo": "A123456789",
                    "passportNo": "P987654321",
                    "citizenType": "Permanent Resident",
                    "dateOfExpiry": "2030-12-31",
                    "countryIssue": "Malaysia",
                    "photo": "google.com"
                }
            },
            "proof": [
                {
                    "type": "BbsBlsSignature2020",
                    "created": "2025-06-18T03:20:49.542446Z",
                    "proofPurpose": "assertionMethod",
                    "proofValue": "uprfR-i_9Apk88cc-UxqYie61cfHoi9TQLj3nvARxJjcL_dDSto2GpP2PI-LARq5jHfjfGw5IZg_yqOGewi9Fd3Iu7BRsh4zq56My7qo28XUOpc5dzaXzoyTUc8yGPUaHzP6V-UgvEhuIpRiBZIjEmQ",
                    "verificationMethod": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff#delegateKey-1"
                },
                {
                    "type": "Ed25519Signature2020",
                    "created": "2025-06-18T03:20:49.544218Z",
                    "proofPurpose": "assertionMethod",
                    "verificationMethod": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff#controllerKey",
                    "jws": "eyJhbGciOiJFZERTQSJ9.eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwiaHR0cHM6Ly90ZXN0LW5vZGUuemV0cml4LmNvbS9nZXRBY2NvdW50TWV0YURhdGE_YWRkcmVzcz1aVFgzSnN6cVBnUlV4NzQzU0FwN3E3elVSZmp2a1d1SDJGTUV6JmtleT10ZW1wbGF0ZV9fZGlkOnppZDo5YWE3ZWNlZmMwNzY1ZmU5MzkyMzZiNDQ3N2NiNTI2MjIwNWJkNDNhNDI4MWQ1MWZjYTJjZDdlNDNjMjljODM4Il0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImlkIjoiZGlkOnppZDplZmYzMGFmMzQyN2EzOGM1Y2QwMjFmNWFjMjg1NzhkMjdjM2JkMWFiNTNmYzRkMjc4OWMxZjhjYjE4MjdlODNjIiwidGVzdFBhc3Nwb3J0Ijp7ImNpdGl6ZW5UeXBlIjoiUGVybWFuZW50IFJlc2lkZW50IiwiY291bnRyeUlzc3VlIjoiTWFsYXlzaWEiLCJkYXRlT2ZFeHBpcnkiOiIyMDMwLTEyLTMxIiwiZG9iIjoiMTk5MC0wMS0wMSIsImdlbmRlciI6Ik1hbGUiLCJpZGVudGl0eU5vIjoiQTEyMzQ1Njc4OSIsIm5hbWUiOiJKb2huIERvZWVlIiwibmF0aW9uYWxpdHkiOiJNeWFubWFyZXNlIiwicGFzc3BvcnRObyI6IlA5ODc2NTQzMjEiLCJwaG90byI6Imdvb2dsZS5jb20ifX0sImV4cGlyYXRpb25EYXRlIjoiMjAzNS0wNi0xN1QwMDowMDowMFoiLCJpZCI6ImRpZDp6aWQ6NjYwMTM3OGIxOGU5NjcwN2QyNWIyMDcwZmQ3MTI1NTQ5ZWNlM2YyZTNhZDRiNWUxZGRhNjdkMjYyOTc1YmE0ZiIsImlzc3VhbmNlRGF0ZSI6IjIwMjUtMDYtMTdUMDA6MDA6MDBaIiwiaXNzdWVyIjoiZGlkOnppZDphMGVmOTE3MTRmMWI4NDMxN2QzOTUxMTg3MDY3OTZlMzhmMDEyYzQ4ODkzZjUwNjNlYmQ3ZGIyZDk0MDZjOWZmIiwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlRlc3RQYXNzcG9ydCJdfQ.QjdDQTJGNUU2MTA4MEZCNjEwNzJENzhBQzM4M0E0MUQyQ0U1MEZDQkM1NkMzRDQ5ODAwMEQ2ODBDRTUxNEQyN0IyNTg5M0VDODlBMUI5QjYyMDJDRUMwMUEyOEI3MTk3NjNERDUyMDAzMDgwRkJENzE3QTkxOEI4ODA1NThEMDA"
                }
            ],
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/bbs/v1",
                "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:9aa7ecefc0765fe939236b4477cb5262205bd43a4281d51fca2cd7e43c29c838"
            ]
        }''';

    final reveal = [
      "testPassport.name",
      // "testPassport.gender",
      // "testPassport.nationality",
    ];

    final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;
    final vc = VerifiableCredential.fromJson(vcMap);

    final ZetrixSDKResult<String> vp = await zetrixVpService.createVpMC(
      vc,
      reveal,
      'z23ENzoxDd3PJFWMLQYCoPwJBC7epEKoG3wdEFYLU6JTtznnL4zukArZMEFX4n1DSwi5GmssJnx7gsjsQRi7fcf7seZ3rqQBv48Mef2hHTdtkeDrqV7SHdv4YkAx5o9MxhjLw',
      'b001a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ffe3b775cb',
    );

    if (vp is Success<String> && vp.data != null) {
      logger.d(vp.data);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QrCodeScreen(data: vp.data!)),
      );
    } else {
      setState(() => _result = 'VP generation failed');
    }
  }

  Future<void> _generateAndSubmitVPBlob() async {

    final VerifiablePresentation? vp = await vpService.generateAndSubmitVPBlob();
    if (vp  != null) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JsonViewScreen(jsonString: jsonEncode(vp)),
        ),
      );
    } else {
      setState(() => _result =  'VP generation failed');
    }
  }

  Future<void> _generateFullVP() async {
    // BBS+ not available on Windows
    if (Platform.isWindows) {
      _showWindowsNotSupported();
      return;
    }

    const vcJson = '''{
            "id": "did:zid:69bd3c95f51fc2ca134fe67e6303e3e83633bbbdb14cf00400e87cd3388a8eeb",
            "type": [
                "VerifiableCredential",
                "Passport"
            ],
            "issuer": "did:zid:d545dc623b0562e9b02a0b4f280b32bd060c9ff1b3582290e6d760e3cc3bfd15",
            "issuanceDate": "2025-07-02T00:00:00Z",
            "expirationDate": "2035-07-02T00:00:00Z",
            "credentialSubject": {
                "id": "did:zid:eff30af3427a38c5cd021f5ac28578d27c3bd1ab53fc4d2789c1f8cb1827e83c",
                "passport": {
                    "name": "John Doe",
                    "dob": "1990-01-01",
                    "gender": "Male",
                    "nationality": "Myanmarese",
                    "identityNo": "A123456789",
                    "passportNo": "P987654321",
                    "citizenType": "Permanent Resident",
                    "dateOfExpiry": "2030-12-31",
                    "countryIssue": "Malaysia",
                    "photo": "https://img/a.jpg"
                }
            },
            "proof": [
                {
                    "type": "BbsBlsSignature2020",
                    "created": "2025-07-16T01:41:07.227776Z",
                    "proofPurpose": "assertionMethod",
                    "proofValue": "uozMvrMFy2PbetH0pndRm7BIxITxo0Z1_ffVmvGloknN0I-wUqgIpRHO05op2g3UCKs6I72n_kjt1u6B-rHGV3zWyyfOxE0DT5plOK8dlDMsdX4NNBKAy2dUaTkleztnmC3aStYKhXUgJmnnLDlWzIg",
                    "verificationMethod": "did:zid:d545dc623b0562e9b02a0b4f280b32bd060c9ff1b3582290e6d760e3cc3bfd15#delegateKey-2"
                },
                {
                    "type": "Ed25519Signature2020",
                    "created": "2025-07-16T01:41:07.228880Z",
                    "proofPurpose": "assertionMethod",
                    "verificationMethod": "did:zid:d545dc623b0562e9b02a0b4f280b32bd060c9ff1b3582290e6d760e3cc3bfd15#controllerKey",
                    "jws": "eyJhbGciOiJFZERTQSJ9.eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwiaHR0cHM6Ly90ZXN0LW5vZGUuemV0cml4LmNvbS9nZXRBY2NvdW50TWV0YURhdGE_YWRkcmVzcz1aVFgzSnN6cVBnUlV4NzQzU0FwN3E3elVSZmp2a1d1SDJGTUV6JmtleT10ZW1wbGF0ZV9fZGlkOnppZDo3MzliMDAwZTZhODk2MTc4ZTMzODZhMmVkODQ4ZDAxYTg3M2I4MzNkM2MwMjQ4ZDI4ZTVjN2QyYmJkZTQ2MDZlIl0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImlkIjoiZGlkOnppZDplZmYzMGFmMzQyN2EzOGM1Y2QwMjFmNWFjMjg1NzhkMjdjM2JkMWFiNTNmYzRkMjc4OWMxZjhjYjE4MjdlODNjIiwicGFzc3BvcnQiOnsiY2l0aXplblR5cGUiOiJQZXJtYW5lbnQgUmVzaWRlbnQiLCJjb3VudHJ5SXNzdWUiOiJNYWxheXNpYSIsImRhdGVPZkV4cGlyeSI6IjIwMzAtMTItMzEiLCJkb2IiOiIxOTkwLTAxLTAxIiwiZ2VuZGVyIjoiTWFsZSIsImlkZW50aXR5Tm8iOiJBMTIzNDU2Nzg5IiwibmFtZSI6IkpvaG4gRG9lIiwibmF0aW9uYWxpdHkiOiJNeWFubWFyZXNlIiwicGFzc3BvcnRObyI6IlA5ODc2NTQzMjEiLCJwaG90byI6Imh0dHBzOi8vaW1nL2EuanBnIn19LCJleHBpcmF0aW9uRGF0ZSI6IjIwMzUtMDctMDJUMDA6MDA6MDBaIiwiaWQiOiJkaWQ6emlkOjY5YmQzYzk1ZjUxZmMyY2ExMzRmZTY3ZTYzMDNlM2U4MzYzM2JiYmRiMTRjZjAwNDAwZTg3Y2QzMzg4YThlZWIiLCJpc3N1YW5jZURhdGUiOiIyMDI1LTA3LTAyVDAwOjAwOjAwWiIsImlzc3VlciI6ImRpZDp6aWQ6ZDU0NWRjNjIzYjA1NjJlOWIwMmEwYjRmMjgwYjMyYmQwNjBjOWZmMWIzNTgyMjkwZTZkNzYwZTNjYzNiZmQxNSIsInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQYXNzcG9ydCJdfQ.MkU4ODI2ODRBRjdCQjUwMUQ4QzRCQjVDMTQ0MTIzRTMxRDZGMTBBRUQ3REE0N0Y3NDA1NjcxOENFQ0U0NzQ4MkIxMkM0N0ZBNzAwREE4NzcyNDNBQjcxRkMyNEZGNENEQkVDMTIwNTdBRjNDMzY0Q0Y2QUExQ0YyM0JBMkY5MDA"
                }
            ],
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/bbs/v1",
                "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:739b000e6a896178e3386a2ed848d01a873b833d3c0248d28e5c7d2bbde4606e"
            ]
        }''';

    final reveal = ["passport.name", "passport.nationality"];

    final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;
    final vc = VerifiableCredential.fromJson(vcMap);

    final ZetrixSDKResult<String> vp = await zetrixVpService.createVp(
      vc,
      reveal,
      'zyztLoBw5uQwwitr5rpXUWMAya91CHLqvnubTVWLFR8RJC1TDhvjteYxGojMGDBPxwyXRVUzB35Zu1tRDXhEmLW3fYe5uKcpQDKyx4dQCrEdMVhNrH3En3NRZr14bfBR3uWK',
      'b001eff30af3427a38c5cd021f5ac28578d27c3bd1ab53fc4d2789c1f8cb1827e83c58de414a',
      'privBxpL2meqP4CHanp4KRzRrabwCEnTgJx8DAddWkveUoZWiYmuHFZx',
      null,
    );

    if (vp is Success<String> && vp.data != null) {
      logger.d(vp.data);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JsonViewScreen(jsonString: vp.data!),
        ),
      );
    } else if (vp is Failure) {
      final failure = vp as Failure;
      final message = ZetrixSDKExceptions.getErrorMessage(failure.error as ZetrixSDKExceptions);
      setState(() => _result = message);
    } else {
      setState(() => _result = 'VP generation failed');
    }
  }

  Future<void> _applyVc() async {
    String vcId = await vcService.applyVc();
    setState(() {
      _result = '✅ VC Applied\nID: $vcId';
    });
  }

  Future<void> _applyVcEnc() async {
    String vcId = await vcService.applyVcEnc();
    setState(() {
      _result = '✅ VC Applied\nID: $vcId';
    });
  }

  Future<void> _downloadVc() async {
    await vcService.downloadVc();

    setState(() {
      _result = '✅ VC Downloaded';
    });
  }

  Future<void> _downloadVcEnc() async {
    await vcService.downloadVcEnc();

    setState(() {
      _result = '✅ VC Downloaded';
    });
  }

  Future<void> _createVpEnc() async {

    final VerifiablePresentation? vp = await vpService.createVpEncrypted();
    if (vp  != null) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JsonViewScreen(jsonString: jsonEncode(vp)),
        ),
      );
    } else {
      setState(() => _result =  'VP generation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Zetrix VC SDK",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                if (_result.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _result.startsWith('✅')
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _result.startsWith('✅') ? Icons.check_circle : Icons.info,
                          color: _result.startsWith('✅') ? Colors.green : Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _result,
                            style: TextStyle(
                              color: _result.startsWith('✅') ? Colors.green[900] : Colors.red[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SectionHeader("Key Management"),
                ActionButton(
                  icon: Icons.vpn_key,
                  label: "Generate BLS12381G1 Key",
                  onPressed: () async {
                    // BBS+ not available on Windows
                    if (Platform.isWindows) {
                      _showWindowsNotSupported();
                      return;
                    }
                    
                    final seed = Uint8List(32);
                    final keyPair = await BbsFlutter.generateBls12381G1Key(seed);
                    logger.d('Public Key: ${base64.encode(keyPair['publicKey']!)}');
                    logger.d('Secret Key: ${base64.encode(keyPair['secretKey']!)}');
                  },
                ),
                const SectionHeader("VC Operations"),
                ActionButton(
                  icon: Icons.upload_file,
                  label: "Call Apply VC",
                  onPressed: _applyVc,
                ),
                ActionButton(
                  icon: Icons.lock,
                  label: "Call Apply VC Encrypted",
                  onPressed: _applyVcEnc,
                ),
                ActionButton(
                  icon: Icons.download,
                  label: "Call Download VC",
                  onPressed: _downloadVc,
                ),
                ActionButton(
                  icon: Icons.vpn_lock,
                  label: "Call Download VC Encrypted",
                  onPressed: _downloadVcEnc,
                ),
                const SectionHeader('DCQL Presentation'),
                ActionButton(
                  icon: Icons.verified_user,
                  label: 'DCQL VP — createVPFromDCQL',
                  onPressed: _runDcqlVpDemo,
                ),
                ActionButton(
                  icon: Icons.manage_accounts,
                  label: 'DCQL VP — Real Demo',
                  onPressed: _runDcqlVpDemoReal,
                ),
                ActionButton(
                  icon: Icons.manage_accounts,
                  label: 'DCQL VP — Presentation Request & VC',
                  onPressed: _runDcqlVpDemoPresentationRequestandVC,
                ),
                ActionButton(
                  icon: Icons.playlist_add_check,
                  label: 'VP Lite — Age Range Proof (≥18)',
                  onPressed: _runVpLiteRangeProofDemo,
                ),
                const SectionHeader("Presentation"),
                ActionButton(
                  icon: Icons.description,
                  label: "Generate Lite Verifiable Presentation",
                  onPressed: _generateVP,
                ),
                ActionButton(
                  icon: Icons.description,
                  label: "Generate Lite Verifiable Presentation with range proof",
                  onPressed: _generateLiteVpWithBulletproof,
                ),
                ActionButton(
                  icon: Icons.verified,
                  label: "Generate Verifiable Presentation",
                  onPressed: _generateFullVP,
                ),
                ActionButton(
                  icon: Icons.verified,
                  label: "Generate Verifiable Presentation with range proof",
                  onPressed: _showExampleBulletproofVC,
                ),
                const SectionHeader('VP Operations'),
                ActionButton(
                  icon: Icons.edit_document,
                  label: "Generate VP blob,sign and submit",
                  onPressed: _generateAndSubmitVPBlob,
                ),
                ActionButton(
                  icon: Icons.edit_document,
                  label: "Generate VP blob,sign and submit Encrypted",
                  onPressed: _createVpEnc,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

