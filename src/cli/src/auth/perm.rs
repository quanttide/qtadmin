use std::collections::BTreeSet;
use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Role {
    SuperAdmin,
    Operator,
}

impl Role {
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "super_admin" | "superadmin" | "admin" => Role::SuperAdmin,
            _ => Role::Operator,
        }
    }
}

fn permission_table() -> Vec<(&'static str, BTreeSet<Role>)> {
    use Role::*;
    vec![
        ("asset", BTreeSet::from([SuperAdmin, Operator])),
        ("asset backup", BTreeSet::from([SuperAdmin, Operator])),
        ("asset audit", BTreeSet::from([SuperAdmin])),
        ("human", BTreeSet::from([SuperAdmin, Operator])),
        ("human status", BTreeSet::from([SuperAdmin, Operator])),
        ("human position", BTreeSet::from([SuperAdmin, Operator])),
        ("business", BTreeSet::from([SuperAdmin, Operator])),
        ("business status", BTreeSet::from([SuperAdmin, Operator])),
        ("business quote", BTreeSet::from([SuperAdmin, Operator])),
        ("project", BTreeSet::from([SuperAdmin, Operator])),
        ("project status", BTreeSet::from([SuperAdmin, Operator])),
        ("qtconsult", BTreeSet::from([SuperAdmin, Operator])),
        ("qtconsult status", BTreeSet::from([SuperAdmin, Operator])),
        ("qtclass", BTreeSet::from([SuperAdmin, Operator])),
        ("qtclass status", BTreeSet::from([SuperAdmin, Operator])),
        ("qtcloud", BTreeSet::from([SuperAdmin, Operator])),
        ("qtcloud status", BTreeSet::from([SuperAdmin, Operator])),
        ("qtdata", BTreeSet::from([SuperAdmin, Operator])),
        ("qtdata status", BTreeSet::from([SuperAdmin, Operator])),
        ("qtrecurit", BTreeSet::from([SuperAdmin, Operator])),
        ("qtrecurit status", BTreeSet::from([SuperAdmin, Operator])),
        ("knowl", BTreeSet::from([SuperAdmin, Operator])),
        ("knowl acquire", BTreeSet::from([SuperAdmin, Operator])),
        ("auth", BTreeSet::from([SuperAdmin, Operator])),
        ("auth user", BTreeSet::from([SuperAdmin, Operator])),
        ("connect", BTreeSet::from([SuperAdmin, Operator])),
        ("connect notice", BTreeSet::from([SuperAdmin, Operator])),
    ]
}

pub fn check_permission(command_name: &str, role: Role) -> bool {
    let table = permission_table();
    if let Some((_, allowed)) = table.iter().find(|(name, _)| *name == command_name) {
        return allowed.contains(&role);
    }
    let top = command_name.split_whitespace().next().unwrap_or(command_name);
    if let Some((_, allowed)) = table.iter().find(|(name, _)| *name == top) {
        return allowed.contains(&role);
    }
    role == Role::SuperAdmin
}

pub fn audit_log_path() -> PathBuf {
    if let Ok(dir) = std::env::var("QTRECURIT_DATA") {
        return PathBuf::from(dir).join("audit.log");
    }
    if let Some(data_dir) = dirs::data_dir() {
        return data_dir.join("qtadmin").join("audit.log");
    }
    PathBuf::from("audit.log")
}

pub fn write_audit_log(command: &str, role: Role, mode: &str, result: &str) {
    let path = audit_log_path();
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    let role_str = match role {
        Role::SuperAdmin => "super_admin",
        Role::Operator => "operator",
    };
    let line = format!(
        r#"{{"t":{},"role":"{}","cmd":"{}","mode":"{}","result":"{}"}}"#,
        timestamp, role_str, command, mode, result
    );
    if let Some(parent) = path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }
    if let Ok(mut file) = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&path)
    {
        use std::io::Write;
        let _ = writeln!(file, "{}", line);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_superadmin_has_all_permissions() {
        assert!(check_permission("asset", Role::SuperAdmin));
        assert!(check_permission("asset audit", Role::SuperAdmin));
        assert!(check_permission("human", Role::SuperAdmin));
        assert!(check_permission("auth", Role::SuperAdmin));
        assert!(check_permission("connect", Role::SuperAdmin));
    }

    #[test]
    fn test_operator_has_common_permissions() {
        assert!(check_permission("asset", Role::Operator));
        assert!(check_permission("human", Role::Operator));
        assert!(check_permission("human position", Role::Operator));
        assert!(check_permission("auth", Role::Operator));
        assert!(check_permission("auth user", Role::Operator));
        assert!(check_permission("connect", Role::Operator));
        assert!(check_permission("connect notice", Role::Operator));
    }

    #[test]
    fn test_operator_cannot_audit() {
        assert!(!check_permission("asset audit", Role::Operator));
    }

    #[test]
    fn test_unknown_command_falls_to_superadmin() {
        assert!(check_permission("unknown command", Role::SuperAdmin));
        assert!(!check_permission("unknown command", Role::Operator));
    }

    #[test]
    fn test_top_level_fallback() {
        assert!(check_permission("asset backup", Role::Operator));
        assert!(check_permission("human status", Role::Operator));
    }

    #[test]
    fn test_role_from_str() {
        assert_eq!(Role::from_str("super_admin"), Role::SuperAdmin);
        assert_eq!(Role::from_str("admin"), Role::SuperAdmin);
        assert_eq!(Role::from_str("operator"), Role::Operator);
        assert_eq!(Role::from_str("unknown"), Role::Operator);
    }

    #[test]
    fn test_audit_log_path_uses_env() {
        let dir = std::env::temp_dir().join("qtadmin-test-audit");
        std::env::set_var("QTRECURIT_DATA", dir.to_str().unwrap());
        let path = audit_log_path();
        assert_eq!(path, dir.join("audit.log"));
        std::env::remove_var("QTRECURIT_DATA");
    }
}
