use std::{path::Path, time::Duration};

mod cleanup_service;
mod cleanups;
mod saving_service;
mod savings;
mod service_utils;

pub fn saving_service(path: &Path, duration: &Duration, notify: bool) {
    saving_service::service(path, duration, notify);
}

pub fn cleanup_service(
    paths: &Vec<&Path>,
    duration_old: &Duration,
    duration_grace: &Duration,
    allow_deletion: bool,
    notify: bool,
) {
    cleanup_service::service(paths, duration_old, duration_grace, allow_deletion, notify);
}
