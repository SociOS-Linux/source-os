use chrono::Utc;
use hex::encode as hex_encode;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs::{File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum AnchorError {
    #[error("I/O error: {0}")]
    Io(String),
    #[error("JSON error: {0}")]
    Json(String),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnchorRecord {
    pub ts_ms: i64,
    pub kind: String,
    pub target_id: Option<String>,
    pub payload: serde_json::Value,
    pub entry_hash: String,
    pub root: String,
}

fn sha256_hex(bytes: &[u8]) -> String {
    hex_encode(Sha256::digest(bytes))
}

pub fn current_root<P: AsRef<Path>>(path: P) -> Result<String, AnchorError> {
    let path = path.as_ref();
    if !path.exists() {
        return Ok("0".repeat(64));
    }

    let file = File::open(path).map_err(|e| AnchorError::Io(e.to_string()))?;
    let reader = BufReader::new(file);
    let mut root = "0".repeat(64);

    for line in reader.lines() {
        let line = line.map_err(|e| AnchorError::Io(e.to_string()))?;
        if line.trim().is_empty() {
            continue;
        }
        let record: AnchorRecord =
            serde_json::from_str(&line).map_err(|e| AnchorError::Json(e.to_string()))?;
        root = record.root;
    }

    Ok(root)
}

pub fn append<P: AsRef<Path>>(
    path: P,
    kind: &str,
    target_id: Option<&str>,
    payload: serde_json::Value,
) -> Result<AnchorRecord, AnchorError> {
    let path = path.as_ref();
    let previous_root = current_root(path)?;
    let payload_json = serde_json::to_vec(&payload).map_err(|e| AnchorError::Json(e.to_string()))?;
    let entry_hash = format!("sha256:{}", sha256_hex(&payload_json));
    let root = format!(
        "sha256:{}",
        sha256_hex(format!("{}{}", previous_root, entry_hash).as_bytes())
    );

    let record = AnchorRecord {
        ts_ms: Utc::now().timestamp_millis(),
        kind: kind.to_string(),
        target_id: target_id.map(|s| s.to_string()),
        payload,
        entry_hash,
        root,
    };

    let line = serde_json::to_string(&record).map_err(|e| AnchorError::Json(e.to_string()))?;
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
        .map_err(|e| AnchorError::Io(e.to_string()))?;
    writeln!(file, "{}", line).map_err(|e| AnchorError::Io(e.to_string()))?;

    Ok(record)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rolling_root_advances() {
        let path = std::env::temp_dir().join(format!("triune-anchor-{}.ndjson", std::process::id()));
        let _ = std::fs::remove_file(&path);

        let first = append(&path, "telemetry", Some("urn:srcos:session:s001"), serde_json::json!({"ok": true})).unwrap();
        let second = append(&path, "telemetry", Some("urn:srcos:session:s001"), serde_json::json!({"ok": false})).unwrap();

        assert_ne!(first.root, second.root);
        assert!(current_root(&path).unwrap().starts_with("sha256:"));

        let _ = std::fs::remove_file(&path);
    }
}
