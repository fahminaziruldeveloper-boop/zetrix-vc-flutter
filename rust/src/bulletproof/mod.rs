pub mod prover;
pub mod verifier;

/// Bulletproof proof data matching Java Proof class
#[derive(Debug, Clone)]
pub struct BulletproofProofData {
    pub proof_bytes: Vec<u8>,
    pub commitments: Vec<Vec<u8>>,
}

/// Generate a single minimum range proof: value >= min
/// Proves that (value - min) >= 0
pub fn generate_single_min_range_proof(
    value: i64,
    min: i64,
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    generate_multiple_min_range_proof(&[value], &[min], bit_size, domain)
}

/// Generate a single maximum range proof: value <= max
/// Proves that (max - value) >= 0
pub fn generate_single_max_range_proof(
    value: i64,
    max: i64,
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    generate_multiple_max_range_proof(&[value], &[max], bit_size, domain)
}

/// Generate a single min-max range proof: min <= value <= max
pub fn generate_single_min_max_range_proof(
    value: i64,
    min: i64,
    max: i64,
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    generate_multiple_min_max_range_proof(&[value], &[min], &[max], bit_size, domain)
}

/// Generate multiple minimum range proofs: values[i] >= mins[i]
pub fn generate_multiple_min_range_proof(
    values: &[i64],
    mins: &[i64],
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    if values.len() != mins.len() {
        return Err("Values and mins arrays must have the same length".to_string());
    }

    // Calculate differences (value - min)
    let mut diffs = Vec::new();
    for i in 0..values.len() {
        let diff = values[i].checked_sub(mins[i])
            .ok_or_else(|| format!("Value at index {} is below minimum", i))?;
        
        if diff < 0 {
            return Err(format!("Value at index {} is below minimum", i));
        }
        diffs.push(diff as u64);
    }

    // Generate proof for the differences
    prover::generate_range_proof(&diffs, bit_size, domain)
}

/// Generate multiple maximum range proofs: values[i] <= maxs[i]
pub fn generate_multiple_max_range_proof(
    values: &[i64],
    maxs: &[i64],
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    if values.len() != maxs.len() {
        return Err("Values and maxs arrays must have the same length".to_string());
    }

    // Calculate differences (max - value)
    let mut diffs = Vec::new();
    for i in 0..values.len() {
        let diff = maxs[i].checked_sub(values[i])
            .ok_or_else(|| format!("Value at index {} is above maximum", i))?;
        
        if diff < 0 {
            return Err(format!("Value at index {} is above maximum", i));
        }
        diffs.push(diff as u64);
    }

    // Generate proof for the differences
    prover::generate_range_proof(&diffs, bit_size, domain)
}

/// Generate multiple min-max range proofs: mins[i] <= values[i] <= maxs[i]
/// If max == 0, it means no maximum constraint (only minimum)
pub fn generate_multiple_min_max_range_proof(
    values: &[i64],
    mins: &[i64],
    maxs: &[i64],
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    if values.len() != mins.len() || values.len() != maxs.len() {
        return Err("Values, mins, and maxs arrays must have the same length".to_string());
    }

    let mut proof_values = Vec::new();
    
    for i in 0..values.len() {
        // Check lower bound: value >= min
        let lower_diff = values[i].checked_sub(mins[i])
            .ok_or_else(|| format!("Value at index {} is below minimum", i))?;
        
        if lower_diff < 0 {
            return Err(format!("Value at index {} is below minimum", i));
        }
        
        proof_values.push(lower_diff as u64);

        // Check upper bound if max != 0 (0 means no max constraint)
        if maxs[i] != 0 {
            if values[i] > maxs[i] {
                return Err(format!("Value at index {} is above maximum", i));
            }

            let upper_diff = maxs[i].checked_sub(values[i])
                .ok_or_else(|| format!("Value at index {} is above maximum", i))?;
            
            proof_values.push(upper_diff as u64);
        }
    }

    // Generate proof for all the differences
    prover::generate_range_proof(&proof_values, bit_size, domain)
}

/// Verify a bulletproof range proof
pub fn verify_multiple_range_proof(
    bit_size: usize,
    proof_bytes: &[u8],
    commitments: &[Vec<u8>],
    domain: &str,
) -> Result<bool, String> {
    verifier::verify_range_proof(bit_size, proof_bytes, commitments, domain)
}

/// Verify a single min-max range proof
pub fn verify_single_min_max_range_proof(
    min: i64,
    max: i64,
    bit_size: usize,
    proof_bytes: &[u8],
    commitments: &[Vec<u8>],
    domain: &str,
) -> Result<bool, String> {
    verify_multiple_min_max_range_proof(&[min], &[max], bit_size, proof_bytes, commitments, domain)
}

/// Verify multiple min-max range proofs
pub fn verify_multiple_min_max_range_proof(
    mins: &[i64],
    maxs: &[i64],
    bit_size: usize,
    proof_bytes: &[u8],
    commitments: &[Vec<u8>],
    domain: &str,
) -> Result<bool, String> {
    if mins.len() != maxs.len() {
        return Err("Mins and maxs arrays must have the same length".to_string());
    }

    // Calculate expected number of commitments before padding
    let mut expected_commitments: usize = 0;
    for i in 0..mins.len() {
        expected_commitments += 1; // lower bound commitment
        if maxs[i] != 0 {
            expected_commitments += 1; // upper bound commitment
        }
    }

    // Commitments are padded to next power of 2
    let padded_expected = expected_commitments.next_power_of_two();
    
    if commitments.len() != padded_expected {
        return Err(format!(
            "Expected {} commitments (original {} padded to power of 2), got {}",
            padded_expected,
            expected_commitments,
            commitments.len()
        ));
    }

    verifier::verify_range_proof(bit_size, proof_bytes, commitments, domain)
}
