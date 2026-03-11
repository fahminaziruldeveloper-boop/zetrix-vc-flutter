use bulletproofs::{BulletproofGens, PedersenGens, RangeProof};
use curve25519_dalek_ng::ristretto::CompressedRistretto;
use merlin::Transcript;

/// Verify a range proof
pub fn verify_range_proof(
    bit_size: usize,
    proof_bytes: &[u8],
    commitment_bytes: &[Vec<u8>],
    domain: &str,
) -> Result<bool, String> {
    // Validate bit size
    if bit_size == 0 || bit_size > 64 {
        return Err(format!("Bit size must be between 1 and 64, got {}", bit_size));
    }

    // Deserialize proof
    let proof = RangeProof::from_bytes(proof_bytes)
        .map_err(|e| format!("Failed to deserialize proof: {:?}", e))?;

    // Deserialize commitments (keep them compressed)
    let mut commitments = Vec::new();
    for (i, bytes) in commitment_bytes.iter().enumerate() {
        if bytes.len() != 32 {
            return Err(format!(
                "Commitment at index {} has invalid length: expected 32, got {}",
                i,
                bytes.len()
            ));
        }

        let mut commitment_array = [0u8; 32];
        commitment_array.copy_from_slice(bytes);
        
        let compressed = CompressedRistretto(commitment_array);
        commitments.push(compressed);
    }

    // Bulletproofs requires party_capacity to be power of 2
    // The commitment count should already be padded from the prover
    let party_capacity = commitments.len();
    
    // Create transcript with domain separator
    let mut transcript = Transcript::new(b"zetrix-bulletproof");
    transcript.append_message(b"domain", domain.as_bytes());

    // Initialize Pedersen generators (default)
    let pc_gens = PedersenGens::default();
    
    // Initialize Bulletproof generators  
    // gens_capacity: maximum number of generators per party (bit_size)
    // party_capacity: maximum number of parties (must match what was used in proof generation)
    let bp_gens = BulletproofGens::new(bit_size, party_capacity);

    // Verify the proof
    proof
        .verify_multiple(&bp_gens, &pc_gens, &mut transcript, commitments.as_slice(), bit_size)
        .map(|_| true)
        .map_err(|e| format!("Proof verification failed: {:?}", e))
}
