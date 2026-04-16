use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum OperationKind {
    Read,
    Write,
    Execute,
    Tag,
    Network,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CapabilityGrant {
    pub id: String,
    pub subject: String,
    pub operations: Vec<OperationKind>,
    pub labels: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperationRequest {
    pub operation: OperationKind,
    pub target_id: String,
    pub target_labels: Vec<String>,
}

#[derive(Debug, Error)]
pub enum CapabilityError {
    #[error("operation denied: no matching capability grant")]
    Denied,
}

pub fn authorize(request: &OperationRequest, grants: &[CapabilityGrant]) -> Result<String, CapabilityError> {
    for grant in grants {
        if !grant.operations.contains(&request.operation) {
            continue;
        }
        if grant.labels.is_empty() || request.target_labels.iter().any(|l| grant.labels.iter().any(|g| g == l)) {
            return Ok(grant.id.clone());
        }
    }
    Err(CapabilityError::Denied)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn authorizes_matching_label_and_operation() {
        let request = OperationRequest {
            operation: OperationKind::Tag,
            target_id: "urn:srcos:dataset:health_obs".into(),
            target_labels: vec!["dag::mutable".into()],
        };
        let grants = vec![CapabilityGrant {
            id: "cap-1".into(),
            subject: "agent.watchdog.validator".into(),
            operations: vec![OperationKind::Tag],
            labels: vec!["dag::mutable".into()],
        }];
        assert_eq!(authorize(&request, &grants).unwrap(), "cap-1");
    }

    #[test]
    fn denies_non_matching_request() {
        let request = OperationRequest {
            operation: OperationKind::Execute,
            target_id: "urn:srcos:dataset:health_obs".into(),
            target_labels: vec!["dag::mutable".into()],
        };
        let grants = vec![CapabilityGrant {
            id: "cap-1".into(),
            subject: "agent.watchdog.validator".into(),
            operations: vec![OperationKind::Tag],
            labels: vec!["dag::mutable".into()],
        }];
        assert!(authorize(&request, &grants).is_err());
    }
}
