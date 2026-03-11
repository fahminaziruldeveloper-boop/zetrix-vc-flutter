/// Bulletproof API for Flutter Rust Bridge
/// These functions match the Java BulletProofUtil API

use crate::bulletproof;

/// Result type for bulletproof operations
#[derive(Debug, Clone)]
pub struct BulletproofResult {
    pub success: bool,
    pub proof_value: String,
    pub commitments: Vec<String>,
    pub error_message: String,
}

/// Verification result
#[derive(Debug, Clone)]
pub struct VerificationResult {
    pub success: bool,
    pub is_valid: bool,
    pub error_message: String,
}

/// Generate a single minimum range proof: value >= min
/// 
/// # Arguments
/// * `value` - The value to prove
/// * `min` - The minimum bound
/// * `bit_size` - Number of bits (typically 32 or 64)
/// * `domain` - Domain separator for the proof (e.g., "zetrix-vc")
pub fn generate_single_min_range_proof(
    value: i64,
    min: i64,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_single_min_range_proof(value, min, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Generate a single maximum range proof: value <= max
pub fn generate_single_max_range_proof(
    value: i64,
    max: i64,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_single_max_range_proof(value, max, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Generate a single min-max range proof: min <= value <= max
pub fn generate_single_min_max_range_proof(
    value: i64,
    min: i64,
    max: i64,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_single_min_max_range_proof(value, min, max, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Generate multiple minimum range proofs: values[i] >= mins[i]
pub fn generate_multiple_min_range_proof(
    values: Vec<i64>,
    mins: Vec<i64>,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_multiple_min_range_proof(&values, &mins, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Generate multiple maximum range proofs: values[i] <= maxs[i]
pub fn generate_multiple_max_range_proof(
    values: Vec<i64>,
    maxs: Vec<i64>,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_multiple_max_range_proof(&values, &maxs, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Generate multiple min-max range proofs: mins[i] <= values[i] <= maxs[i]
/// Use max=0 to indicate no maximum constraint (only minimum)
pub fn generate_multiple_min_max_range_proof(
    values: Vec<i64>,
    mins: Vec<i64>,
    maxs: Vec<i64>,
    bit_size: i32,
    domain: String,
) -> BulletproofResult {
    match bulletproof::generate_multiple_min_max_range_proof(&values, &mins, &maxs, bit_size as usize, &domain) {
        Ok(proof_data) => BulletproofResult {
            success: true,
            proof_value: base64_url_encode_with_prefix(&proof_data.proof_bytes),
            commitments: proof_data
                .commitments
                .iter()
                .map(|c| base64_url_encode_with_prefix(c))
                .collect(),
            error_message: String::new(),
        },
        Err(e) => BulletproofResult {
            success: false,
            proof_value: String::new(),
            commitments: Vec::new(),
            error_message: e,
        },
    }
}

/// Verify a bulletproof range proof
pub fn verify_multiple_range_proof(
    bit_size: i32,
    proof_value: String,
    commitments: Vec<String>,
    domain: String,
) -> VerificationResult {
    // Decode base64url proof
    let proof_bytes = match base64_url_decode_with_prefix(&proof_value) {
        Ok(bytes) => bytes,
        Err(e) => {
            return VerificationResult {
                success: false,
                is_valid: false,
                error_message: e,
            }
        }
    };

    // Decode base64url commitments
    let mut commitment_bytes = Vec::new();
    for commitment in commitments {
        match base64_url_decode_with_prefix(&commitment) {
            Ok(bytes) => commitment_bytes.push(bytes),
            Err(e) => {
                return VerificationResult {
                    success: false,
                    is_valid: false,
                    error_message: e,
                }
            }
        }
    }

    match bulletproof::verify_multiple_range_proof(
        bit_size as usize,
        &proof_bytes,
        &commitment_bytes,
        &domain,
    ) {
        Ok(is_valid) => VerificationResult {
            success: true,
            is_valid,
            error_message: String::new(),
        },
        Err(e) => VerificationResult {
            success: false,
            is_valid: false,
            error_message: e,
        },
    }
}

/// Verify a single min-max range proof
pub fn verify_single_min_max_range_proof(
    min: i64,
    max: i64,
    bit_size: i32,
    proof_value: String,
    commitments: Vec<String>,
    domain: String,
) -> VerificationResult {
    // Decode base64url proof
    let proof_bytes = match base64_url_decode_with_prefix(&proof_value) {
        Ok(bytes) => bytes,
        Err(e) => {
            return VerificationResult {
                success: false,
                is_valid: false,
                error_message: e,
            }
        }
    };

    // Decode base64url commitments
    let mut commitment_bytes = Vec::new();
    for commitment in commitments {
        match base64_url_decode_with_prefix(&commitment) {
            Ok(bytes) => commitment_bytes.push(bytes),
            Err(e) => {
                return VerificationResult {
                    success: false,
                    is_valid: false,
                    error_message: e,
                }
            }
        }
    }

    match bulletproof::verify_single_min_max_range_proof(
        min,
        max,
        bit_size as usize,
        &proof_bytes,
        &commitment_bytes,
        &domain,
    ) {
        Ok(is_valid) => VerificationResult {
            success: true,
            is_valid,
            error_message: String::new(),
        },
        Err(e) => VerificationResult {
            success: false,
            is_valid: false,
            error_message: e,
        },
    }
}

/// Verify multiple min-max range proofs
pub fn verify_multiple_min_max_range_proof(
    mins: Vec<i64>,
    maxs: Vec<i64>,
    bit_size: i32,
    proof_value: String,
    commitments: Vec<String>,
    domain: String,
) -> VerificationResult {
    // Decode base64url proof
    let proof_bytes = match base64_url_decode_with_prefix(&proof_value) {
        Ok(bytes) => bytes,
        Err(e) => {
            return VerificationResult {
                success: false,
                is_valid: false,
                error_message: e,
            }
        }
    };

    // Decode base64url commitments
    let mut commitment_bytes = Vec::new();
    for commitment in commitments {
        match base64_url_decode_with_prefix(&commitment) {
            Ok(bytes) => commitment_bytes.push(bytes),
            Err(e) => {
                return VerificationResult {
                    success: false,
                    is_valid: false,
                    error_message: e,
                }
            }
        }
    }

    match bulletproof::verify_multiple_min_max_range_proof(
        &mins,
        &maxs,
        bit_size as usize,
        &proof_bytes,
        &commitment_bytes,
        &domain,
    ) {
        Ok(is_valid) => VerificationResult {
            success: true,
            is_valid,
            error_message: String::new(),
        },
        Err(e) => VerificationResult {
            success: false,
            is_valid: false,
            error_message: e,
        },
    }
}

// ==================== Base64URL Encoding ====================
// Matches Java implementation with 'u' prefix

const BASE64URL_PREFIX: &str = "u";

/// Encode bytes to Base64URL with 'u' prefix (matching Java)
fn base64_url_encode_with_prefix(data: &[u8]) -> String {
    let base64 = base64_encode(data);
    let base64url = base64
        .replace('+', "-")
        .replace('/', "_")
        .trim_end_matches('=')
        .to_string();
    format!("{}{}", BASE64URL_PREFIX, base64url)
}

/// Decode Base64URL with 'u' prefix (matching Java)
fn base64_url_decode_with_prefix(data: &str) -> Result<Vec<u8>, String> {
    if !data.starts_with(BASE64URL_PREFIX) {
        return Err(format!(
            "Base64URL string must start with '{}' prefix",
            BASE64URL_PREFIX
        ));
    }

    let base64url = &data[BASE64URL_PREFIX.len()..];
    let base64 = base64url.replace('-', "+").replace('_', "/");

    // Add padding
    let padding_len = (4 - base64.len() % 4) % 4;
    let padded = if padding_len > 0 {
        format!("{}{}", base64, "=".repeat(padding_len))
    } else {
        base64
    };

    base64_decode(&padded).map_err(|e| format!("Failed to decode Base64: {}", e))
}

/// Simple Base64 encoding
fn base64_encode(data: &[u8]) -> String {
    use std::io::Write;
    let mut buf = Vec::new();
    {
        let mut encoder = base64::write::EncoderWriter::new(&mut buf, &base64::engine::general_purpose::STANDARD);
        encoder.write_all(data).unwrap();
    }
    String::from_utf8(buf).unwrap()
}

/// Simple Base64 decoding
fn base64_decode(data: &str) -> Result<Vec<u8>, String> {
    use base64::Engine;
    base64::engine::general_purpose::STANDARD
        .decode(data)
        .map_err(|e| format!("{}", e))
}
