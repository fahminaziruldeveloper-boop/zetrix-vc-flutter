// Data models for DCQL (Digital Credentials Query Language) presentation requests.
// These models represent the response from `GET /v1/presentation/{pres_id}`,
// which is the input to [DcqlVpService.createVPFromDCQL].

/// Top-level response from `GET /v1/presentation/{pres_id}`.
///
/// The raw JSON looks like:
/// ```json
/// {
///   "object": {
///     "credential_query": { ... },
///     "nonce": "15e49bc...",
///     "state": "user_session_123",
///     "response_uri": "http://...",
///     "response_mode": "direct_post"
///   }
/// }
/// ```
class PresentationResponse {
  /// Parsed credential query containing the list of credential requirements.
  final CredentialQuery credentialQuery;

  /// Session nonce from the verifier. Binds the BBS+ proof to this session.
  final String nonce;

  /// Session state token echoed back in the submission.
  final String state;

  /// Presentation ID from the verifier request (`presentation_id` or `presentationId`).
  /// Sent back as `presentation_id` in the VP submission body.
  // ignore: non_constant_identifier_names
  final String presentation_id;

  /// URL to POST the completed VP submission to.
  final String responseUri;

  /// Response mode — currently always `"direct_post"`.
  final String responseMode;

  const PresentationResponse({
    required this.credentialQuery,
    required this.nonce,
    required this.state,
    // ignore: non_constant_identifier_names
    required this.presentation_id,
    required this.responseUri,
    required this.responseMode,
  });

  /// Parses a [PresentationResponse] from the raw JSON map returned by the
  /// `GET /v1/presentation/{pres_id}` endpoint.
  ///
  /// Expected structure: `{ "object": { "credential_query": ..., "nonce": ..., ... } }`
  factory PresentationResponse.fromJson(Map<String, dynamic> json) {
    final obj = json['object'] as Map<String, dynamic>;
    return PresentationResponse(
      credentialQuery: CredentialQuery.fromJson(
        obj['credential_query'] as Map<String, dynamic>,
      ),
      nonce: obj['nonce'] as String,
      state: obj['state'] as String? ?? '',
      presentation_id: obj['presentation_id'] as String? ??
          obj['presentationId'] as String? ?? '',
      responseUri: obj['response_uri'] as String? ?? '',
      responseMode: obj['response_mode'] as String? ?? 'direct_post',
    );
  }
}

/// Container for all credential requirements in the presentation request.
class CredentialQuery {
  /// List of credential requirements. Each entry specifies one credential
  /// the verifier is requesting, along with the claims to prove/disclose.
  final List<CredentialRequirement> credentials;

  const CredentialQuery({required this.credentials});

  factory CredentialQuery.fromJson(Map<String, dynamic> json) {
    final list = json['credentials'] as List<dynamic>;
    return CredentialQuery(
      credentials: list
          .map((e) =>
              CredentialRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single credential requirement within a [CredentialQuery].
///
/// Specifies the credential type(s) that must be presented and which claims
/// must be either disclosed or proven via a range proof.
class CredentialRequirement {
  /// DID identifying this credential requirement.
  ///
  /// Used as `presentation_submission.definition_id` in the submission body.
  final String id;

  /// Credential format, e.g. `"ldp_vc"`.
  final String format;

  /// Metadata about the required credential type.
  final CredentialMeta meta;

  /// Claims the verifier wants to verify or have disclosed.
  final List<ClaimQuery> claims;

  const CredentialRequirement({
    required this.id,
    required this.format,
    required this.meta,
    required this.claims,
  });

  factory CredentialRequirement.fromJson(Map<String, dynamic> json) {
    final rawClaims = json['claims'] as List<dynamic>? ?? [];
    return CredentialRequirement(
      id: json['id'] as String,
      format: json['format'] as String? ?? 'ldp_vc',
      meta: CredentialMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
      claims: rawClaims
          .map((e) => ClaimQuery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Metadata for matching a wallet VC to a credential requirement.
class CredentialMeta {
  /// All strings that must appear in the VC's `type[]` array.
  ///
  /// Matching rule: `vctValues ⊆ vc.type` (strict superset — VC may have
  /// additional types beyond those listed here).
  final List<String> vctValues;

  const CredentialMeta({required this.vctValues});

  factory CredentialMeta.fromJson(Map<String, dynamic> json) {
    final list = json['vct_values'] as List<dynamic>? ?? [];
    return CredentialMeta(
      vctValues: list.map((e) => e as String).toList(),
    );
  }
}

/// A single claim within a [CredentialRequirement].
///
/// [path] is a JSON-path-style list rooted at the VC document level,
/// always starting with `"credentialSubject"`.
///
/// Examples:
/// ```json
/// { "path": ["credentialSubject", "nationality"],
///   "constraints": { "const": "Malaysian" } }
/// { "path": ["credentialSubject", "gender"],
///   "constraints": { "enum": ["Male", "Female"] } }
/// { "path": ["credentialSubject", "age"],
///   "constraints": { "minimum": 18 } }
/// ```
///
/// [filter] determines the proof mechanism (see [ClaimFilter]).
class ClaimQuery {
  /// JSON path to the field in the VC document.
  ///
  /// Always starts with `"credentialSubject"`. When navigating
  /// `vc['credentialSubject']`, skip the first element via `path.skip(1)`.
  final List<String> path;

  /// Filter applied to the claim value. `null` means plain selective disclosure.
  final ClaimFilter? filter;

  const ClaimQuery({required this.path, this.filter});

  factory ClaimQuery.fromJson(Map<String, dynamic> json) {
    final rawPath = json['path'] as List<dynamic>;
    // Accept both `constraints` (new server format) and `filter` (legacy).
    final rawFilter =
        json['constraints'] as Map<String, dynamic>? ??
        json['filter'] as Map<String, dynamic>?;
    return ClaimQuery(
      path: rawPath.map((e) => e as String).toList(),
      filter: rawFilter != null ? ClaimFilter.fromJson(rawFilter) : null,
    );
  }
}

/// Filter constraints applied to a [ClaimQuery].
///
/// Drives the proof mechanism selection:
/// - `minimum` and/or `maximum` present → BulletProof range proof
/// - `const` / `enum` / `pattern` → BBS+ selective disclosure (verifier checks value)
/// - no constraints → BBS+ selective disclosure
///
/// The `type` field is optional; it is inferred from the constraint fields when
/// absent (presence of `minimum`/`maximum` implies `"number"`).
class ClaimFilter {
  /// JSON Schema type of the expected value — `"number"` or `"string"`.
  ///
  /// Defaults to `"number"` when `minimum`/`maximum` are present, `"string"` otherwise.
  final String type;

  /// Minimum numeric value (inclusive) for range proofs. May be null.
  final num? minimum;

  /// Maximum numeric value (inclusive) for range proofs. May be null.
  final num? maximum;

  /// Regex pattern for string validation (verifier-side only). May be null.
  final String? pattern;

  /// Enumerated allowed values for string/number validation (verifier-side only).
  final List<dynamic>? enumValues;

  /// Exact expected value for string/number/boolean validation (verifier-side only).
  final dynamic constValue;

  const ClaimFilter({
    required this.type,
    this.minimum,
    this.maximum,
    this.pattern,
    this.enumValues,
    this.constValue,
  });

  factory ClaimFilter.fromJson(Map<String, dynamic> json) {
    final minimum = json['minimum'] as num?;
    final maximum = json['maximum'] as num?;
    // Infer type: explicit field wins; otherwise 'number' when range bounds
    // are present, 'string' for everything else.
    final String type = json['type'] as String? ??
        ((minimum != null || maximum != null) ? 'number' : 'string');
    return ClaimFilter(
      type: type,
      minimum: minimum,
      maximum: maximum,
      pattern: json['pattern'] as String?,
      enumValues: json['enum'] as List<dynamic>?,
      constValue: json['const'],
    );
  }

  /// Returns `true` if this filter requires a BulletProof range proof.
  ///
  /// Condition: at least one of `minimum` / `maximum` is set
  /// (which implies the value is numeric).
  bool get requiresRangeProof => minimum != null || maximum != null;
}
