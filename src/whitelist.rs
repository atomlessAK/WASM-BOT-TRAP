// src/whitelist.rs
// Whitelist logic for WASM Bot Trap
// Supports single IPs, CIDR ranges, and inline comments (e.g., "192.168.1.0/24 # office")

use ipnet::IpNet;
use std::net::IpAddr;

/// Returns true if the given IP is whitelisted by exact match or CIDR range.
pub fn is_whitelisted(ip: &str, whitelist: &[String]) -> bool {
    let ip_addr: IpAddr = match ip.parse() {
        Ok(addr) => addr,
        Err(_) => return false,
    };
    for entry in whitelist {
        // Remove inline comments and trim whitespace
        let entry = entry.split('#').next().unwrap_or("").trim();
        if entry.is_empty() { continue; }
        // Try exact match
        if entry == ip {
            return true;
        }
        // Try CIDR match
        if let Ok(net) = entry.parse::<IpNet>() {
            if net.contains(&ip_addr) {
                return true;
            }
        }
    }
    false
}
