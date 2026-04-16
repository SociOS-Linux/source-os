use serde_json::json;

pub fn build_anchor_payload(subject_id: &str, trigger_type: &str) -> serde_json::Value {
    json!({
        "target_id": subject_id,
        "kind": "quarantine-trigger",
        "trigger_type": trigger_type
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn payload_contains_subject_and_trigger() {
        let payload = build_anchor_payload("urn:srcos:session:s001", "egress_policy_violation");
        assert_eq!(payload["target_id"], "urn:srcos:session:s001");
        assert_eq!(payload["trigger_type"], "egress_policy_violation");
    }
}
