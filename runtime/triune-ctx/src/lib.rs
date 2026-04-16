use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use thiserror::Error;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TriunePlane {
    Live,
    Audit,
    Replay,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Attestation {
    pub aum_id: String,
    pub kernel_hash: String,
    pub policy_digest: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TriuneContext {
    pub call_id: Uuid,
    pub plane: TriunePlane,
    pub attestation: Attestation,
    pub issued_at: DateTime<Utc>,
}

#[derive(Debug, Error)]
pub enum TriuneContextError {
    #[error("invalid kernel hash")]
    InvalidKernelHash,
    #[error("missing policy digest")]
    MissingPolicyDigest,
}

pub fn stamp_context(plane: TriunePlane, aum_id: &str, kernel_hash: &str, policy_digest: &str) -> TriuneContext {
    TriuneContext {
        call_id: Uuid::new_v4(),
        plane,
        attestation: Attestation {
            aum_id: aum_id.to_string(),
            kernel_hash: kernel_hash.to_string(),
            policy_digest: policy_digest.to_string(),
        },
        issued_at: Utc::now(),
    }
}

pub fn verify_context(ctx: &TriuneContext) -> Result<(), TriuneContextError> {
    if ctx.attestation.kernel_hash.trim().is_empty() {
        return Err(TriuneContextError::InvalidKernelHash);
    }
    if ctx.attestation.policy_digest.trim().is_empty() {
        return Err(TriuneContextError::MissingPolicyDigest);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stamps_and_verifies_context() {
        let ctx = stamp_context(
            TriunePlane::Audit,
            "agent.watchdog.validator",
            "sha256:deadbeef",
            "sha256:cafebabe",
        );
        assert!(verify_context(&ctx).is_ok());
        assert_eq!(ctx.plane, TriunePlane::Audit);
    }
}
