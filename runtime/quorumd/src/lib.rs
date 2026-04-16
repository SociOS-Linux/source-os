use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Vote {
    pub signer: String,
    pub verdict: String,
}

pub fn aggregate(votes: &[Vote]) -> Option<String> {
    let mut counts = std::collections::BTreeMap::<String, usize>::new();
    for vote in votes {
        *counts.entry(vote.verdict.clone()).or_default() += 1;
    }
    counts
        .into_iter()
        .max_by_key(|(_, count)| *count)
        .map(|(verdict, _)| verdict)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn picks_majority_verdict() {
        let votes = vec![
            Vote { signer: "validator@v1".into(), verdict: "reseal_resume".into() },
            Vote { signer: "validator@v2".into(), verdict: "reseal_resume".into() },
            Vote { signer: "watchdog@w1".into(), verdict: "terminate".into() },
        ];
        assert_eq!(aggregate(&votes).as_deref(), Some("reseal_resume"));
    }
}
