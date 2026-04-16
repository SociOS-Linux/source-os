use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuarantinePlan {
    pub subject_id: String,
    pub isolation_mode: String,
    pub allow_dns: Option<String>,
    pub allow_hosts: Vec<String>,
}

pub fn build_quarantine_plan(subject_id: &str) -> QuarantinePlan {
    QuarantinePlan {
        subject_id: subject_id.to_string(),
        isolation_mode: "cgroup-ebpf".to_string(),
        allow_dns: Some("10.7.0.1".to_string()),
        allow_hosts: vec!["audit.example.org".to_string()],
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn default_plan_is_cgroup_ebpf() {
        let plan = build_quarantine_plan("urn:srcos:session:s001");
        assert_eq!(plan.isolation_mode, "cgroup-ebpf");
        assert_eq!(plan.allow_dns.as_deref(), Some("10.7.0.1"));
    }
}
