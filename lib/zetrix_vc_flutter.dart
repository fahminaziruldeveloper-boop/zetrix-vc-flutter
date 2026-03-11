library;

export 'src/sdk/zetrix_vc_flutter.dart';
export 'src/utils/helpers.dart' show Helpers;
export 'src/utils/tools.dart' show Tools;
export 'src/utils/sdk_error_enum.dart' show SdkError;
export 'src/utils/encryption_utils.dart' show EncryptionUtils;
export 'src/utils/rsa_util.dart' show RsaUtil;
export 'src/utils/aes_gcm_util.dart' show AesGcmUtil;
export 'src/config.dart' show ConfigReader;
export 'src/utils/x25519encryption_utils.dart';
export 'src/services/vp_service.dart' show ZetrixVpService;
export 'src/services/vc_service.dart' show ZetrixVcService;
export 'src/services/vc_encrypted_service.dart' show ZetrixVcEncryptedService;
export 'src/services/vp_encrypted_service.dart' show ZetrixVpEncryptedService;
export 'src/services/account_service.dart' show ZetrixAccountService;
export 'src/services/pack_message_service.dart';
export 'src/services/unpack_message_service.dart';
export 'src/services/auth_credential_service.dart' show AuthCredentialService;
export 'bbs/bbs.dart' show Bbs;
export 'bbs/bbs_flutter.dart' show BbsFlutter;
export 'src/models/models.dart';
export 'src/protocols/protocols.dart';

// Bulletproof range proofs
export 'src/services/bulletproof_service.dart' show BulletproofService;
export 'src/utils/bulletproof_util.dart' show BulletproofUtil;
export 'src/models/bulletproof/bulletproof_proof.dart' show BulletproofProof;

// DCQL VP submission (now part of ZetrixVpService)
export 'src/models/dcql/dcql_models.dart'
    show
        PresentationResponse,
        CredentialQuery,
        CredentialRequirement,
        CredentialMeta,
        ClaimQuery,
        ClaimFilter;
export 'src/models/dcql/wallet_key_material.dart' show WalletKeyMaterial;
export 'src/models/dcql/vp_submission_body.dart'
    show VpSubmissionBody, PresentationSubmission, DescriptorMap;
export 'src/models/dcql/dcql_exceptions.dart'
    show
        DcqlMatchException,
        ClaimNotFoundException,
        ProofCreationException,
        RangeProofFailException,
        JwtSigningException;
