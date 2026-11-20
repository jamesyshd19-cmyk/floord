use std::path::Path;
use std::time::Duration;

mod services;

pub const SOON_DELETED: &str = "SoonDeleted";
pub const SECURE: &str = "Secure";
pub const UNKNOWN: &str = "Unknown";

pub fn saving_service(path: &Path, duration: &Duration, notify: bool) {
    services::saving_service(path, duration, notify);
}

pub fn cleanup_service(
    paths: &Vec<&Path>,
    duration_old: &Duration,
    duration_grace: &Duration,
    allow_deletion: bool,
    notify: bool,
) {
    services::cleanup_service(paths, duration_old, duration_grace, allow_deletion, notify);
}
