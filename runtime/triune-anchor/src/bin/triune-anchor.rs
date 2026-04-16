use serde_json::json;
use std::env;
use triune_anchor::append;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 {
        eprintln!("usage: triune-anchor <path> <kind> <target-id>");
        std::process::exit(1);
    }

    let path = &args[1];
    let kind = &args[2];
    let target_id = &args[3];

    let payload = json!({
        "msg": "anchor write",
        "target_id": target_id
    });

    match append(path, kind, Some(target_id), payload) {
        Ok(record) => println!("{}", serde_json::to_string_pretty(&record).unwrap()),
        Err(err) => {
            eprintln!("anchor error: {err}");
            std::process::exit(2);
        }
    }
}
