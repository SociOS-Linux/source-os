use chrono::Utc;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct TriggerEvent {
    subject_id: String,
    trigger_type: String,
    evidence_refs: Vec<String>,
}

fn main() {
    let event = TriggerEvent {
        subject_id: "urn:srcos:session:s001".to_string(),
        trigger_type: "egress_policy_violation".to_string(),
        evidence_refs: vec!["urn:srcos:audit-anchor:001".to_string()],
    };

    let packet = serde_json::json!({
        "ts": Utc::now().to_rfc3339(),
        "kind": "watchdog.trigger",
        "event": event,
        "next": [
            "quarantine",
            "anchor",
            "validator-review"
        ]
    });

    println!("{}", serde_json::to_string_pretty(&packet).unwrap());
}
