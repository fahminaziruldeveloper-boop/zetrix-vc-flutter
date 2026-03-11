use bulletproofs::{BulletproofGens, PedersenGens, RangeProof};
use curve25519_dalek_ng::scalar::Scalar;
use merlin::Transcript;
use rand::rngs::OsRng;
use rand::RngCore;

use super::BulletproofProofData;

/// Generate a range proof for multiple values
/// Each value must be in range [0, 2^bit_size)
pub fn generate_range_proof(
    values: &[u64],
    bit_size: usize,
    domain: &str,
) -> Result<BulletproofProofData, String> {
    // Validate bit size
    if bit_size == 0 || bit_size > 64 {
        return Err(format!("Bit size must be between 1 and 64, got {}", bit_size));
    }

    // Check that values fit in the bit size
    let max_value = if bit_size == 64 {
        u64::MAX
    } else {
        (1u64 << bit_size) - 1
    };

    for (i, &value) in values.iter().enumerate() {
        if value > max_value {
            return Err(format!(
                "Value at index {} ({}) exceeds maximum for {}-bit range ({})",
                i, value, bit_size, max_value
            ));
        }
    }

    // Create transcript with domain separator
    let mut transcript = Transcript::new(b"zetrix-bulletproof");
    transcript.append_message(b"domain", domain.as_bytes());

    // Initialize Pedersen generators (default)
    let pc_gens = PedersenGens::default();
    
    // Initialize Bulletproof generators
    // gens_capacity: maximum number of generators per party (bit_size)
    // party_capacity: maximum number of parties (must be power of 2)
    let original_len = values.len();
    let party_capacity = original_len.next_power_of_two();
    let bp_gens = BulletproofGens::new(bit_size, party_capacity);

    // Pad values to power of 2 by adding zeros
    let mut padded_values = values.to_vec();
    while padded_values.len() < party_capacity {
        padded_values.push(0);
    }

    // Generate blinding factors (including for padded values)
    let mut rng = OsRng;
    let mut blindings = Vec::new();
    for _ in 0..party_capacity {
        let mut bytes = [0u8; 32];
        rng.fill_bytes(&mut bytes);
        blindings.push(Scalar::from_bytes_mod_order(bytes));
    }

    // Create the range proof
    let (proof, commitments) = RangeProof::prove_multiple(
        &bp_gens,
        &pc_gens,
        &mut transcript,
        &padded_values,
        blindings.as_slice(),
        bit_size,
    ).map_err(|e| format!("Failed to generate proof: {:?}", e))?;

    // Serialize proof
    let proof_bytes = proof.to_bytes();

    // Serialize ALL commitments (including padded ones for verification to work)
    let commitment_bytes: Vec<Vec<u8>> = commitments
        .iter()
        .map(|c| c.as_bytes().to_vec())
        .collect();

    Ok(BulletproofProofData {
        proof_bytes,
        commitments: commitment_bytes,
    })
}
