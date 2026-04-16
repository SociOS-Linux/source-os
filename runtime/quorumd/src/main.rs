use chrono::Utc;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ValidatorInput {
    call_id: String,
    evidence_refs: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ValidatorDecision {
    decision_id: String,
    call_id: String,
    verdict: String,
    signer: String,
    decided_at: String,
}

fn decide(input: &ValidatorInput) -> ValidatorDecision {
    ValidatorDecision {
        decision_id: format!("urn:srcos:validator-decision:{}", Uuid::new_v4()),
        call_id: input.call_id.clone(),
        verdict: "reseal_resume".to_string(),
        signer: "validator@v1".to_string(),
        decided_at: Utc::now().to_rfc3339(),
    }
}

fn main() {
    let input = ValidatorInput {
        call_id: "call_aa11bb22".to_string(),
        evidence_refs: vec![
            "urn:srcos:audit-anchor:001".to_string(),
            "urn:srcos:quarantine:q001".to_string(),
        ],
    };

    let decision = decide(&input);
    println!("{}", serde_json::to_string_pretty(&decision).unwrap());
}
