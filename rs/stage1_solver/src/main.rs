use ethers::core::utils::{hex, keccak256, to_checksum};
use ethers::types::H160;
use rayon::prelude::*;
use std::{env, str::FromStr};

const DISPATCH_IDX: u8 = 3;

/// Input is 32 bytes laid out as follows:
/// [0:4]   - Signature (dispatch index)
/// [4:24]  - Attacker address
/// [24:32] - calldata[28:36]
fn hash(dispatch_idx: u8, addr: &str, i: u64) -> [u8; 32] {
    keccak256(hex::decode(format!("{:08x}{}{:016x}", dispatch_idx, addr, i)).expect("Invalid hex"))
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if let Some(a) = args.get(1) {
        if let Some(jumpdest) = args.get(2) {
            // Transform address to correct checksum:
            let address = &to_checksum(&H160::from_str(a).expect("Invalid address"), None)[2..42];
            let jumpdest = &hex::decode(jumpdest.replace("0x", "")).expect("Invalid jumpdest");

            if jumpdest.len() != 2 {
                eprintln!("Jumpdest can only be 2 bytes.");
                return;
            }

            println!("Checksumed Address: 0x{}", address);
            println!("Jumpdest: 0x{:02x}{:02x}", jumpdest[0], jumpdest[1]);

            let res = (0..u64::MAX).into_par_iter().find_any(|i| {
                let hash = hash(DISPATCH_IDX, address, *i);

                hash[0] == jumpdest[0]
                    && hash[1] == jumpdest[1]
                    && hash[30] == 0xD0
                    && hash[31] == 0x73
            });

            if let Some(i) = res {
                let hash = hash(DISPATCH_IDX, address, i);
                println!("Hash: {}", hex::encode(hash));
                println!("i: {}", i);
                println!("i (hex): {:016x}", i);
            } else {
                println!("Crunching failed. Bigger range?");
            }
        } else {
            eprintln!("No jumpdest provided.");
        }
    } else {
        eprintln!("No address provided.");
    }
}
