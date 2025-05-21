#[cfg(test)]
mod tests {
    use crate::doc::{document_types::BlockDoc, utils::sorting::ChainSorting};

    use super::*;
    use std::collections::HashMap;

    #[test]
    fn test_complex_move_operations() {
        // Setup test data matching the provided structure
        let mut children_map = HashMap::new();
        children_map.insert(
            "j62VDi".to_string(),
            vec![
                "I4098s".to_string(),
                "UX_nxA".to_string(),
                "1WVpT8".to_string(),
                "SXTmU4".to_string(),
                "jBMJf8".to_string(),
                "FcPUds".to_string(),
                "n9Bx2_".to_string(),
                "Zq4qVr".to_string(),
            ]
        );

        let mut blocks = HashMap::new();
        
        // Parent block
        blocks.insert("j62VDi".to_string(), BlockDoc {
            id: "j62VDi".to_string(),
            ty: "page".to_string(),
            attributes: HashMap::from([
                ("device".to_string(), "7b2d08f0-59a4-4f51-b88b-1673d27a6d37".to_string()),
                ("timestamp".to_string(), "2025-03-25T20:18:15.200909".to_string()),
            ]),
            delta: None,
            parent_id: None,
            prev_id: None,
            old_parent_id: None,
            next_id: None,
        });

        // Child blocks
        let child_data = vec![
            ("I4098s", "7b2d08f0...", "2025-03-25T20:18:48.985091", None),
            ("UX_nxA", "d5612d23...", "2025-03-25T20:19:13.255235", None),
            ("1WVpT8", "7b2d08f0...", "2025-03-25T20:19:12.230850", Some("I4098s")),
            ("SXTmU4", "d5612d23...", "2025-03-25T20:22:48.866588", Some("UX_nxA")),
            ("jBMJf8", "7b2d08f0...", "2025-03-25T20:19:13.255235", Some("1WVpT8")),
            ("FcPUds", "d5612d23...", "2025-03-25T20:23:05.595778", Some("SXTmU4")),
            ("n9Bx2_", "7b2d08f0...", "2025-03-25T20:19:14.000000", Some("jBMJf8")),
            ("Zq4qVr", "d5612d23...", "2025-03-25T20:23:20.833103", Some("FcPUds")),
        ];

        for (id, device, timestamp, prev_id) in child_data {
            blocks.insert(id.to_string(), BlockDoc {
                id: id.to_string(),
                ty: "paragraph".to_string(),
                attributes: HashMap::from([
                    ("device".to_string(), device.to_string()),
                    ("timestamp".to_string(), timestamp.to_string()),
                    ("level".to_string(), "1".to_string()),
                ]),
                delta: Some(format!("[{{\"insert\":\"{}\"}}]", id)),
                parent_id: Some("j62VDi".to_string()),
                prev_id: prev_id.map(|s| s.to_string()),
                old_parent_id: None,
                next_id: None,
            });
        }

        // Test initial sorting
        let sorted = ChainSorting::sort_blocks_by_chain(&blocks);
        let parent_children = sorted.get("j62VDi").unwrap();

        // Verify expected device grouping and ordering
        let expected_order = vec![
            // Device 7b2d08f0... blocks sorted by timestamp
            "I4098s", "1WVpT8", "jBMJf8", "n9Bx2_",
            // Device d5612d23... blocks sorted by timestamp
            "UX_nxA", "SXTmU4", "FcPUds", "Zq4qVr"
        ];
        
        assert_eq!(parent_children, &expected_order,
            "Blocks not grouped by device and sorted by timestamp");

        // Test after moving SXTmU4 to first device
        blocks.get_mut("SXTmU4").unwrap().attributes.insert(
            "device".to_string(),
            "7b2d08f0-59a4-4f51-b88b-1673d27a6d37".to_string()
        );
        blocks.get_mut("SXTmU4").unwrap().prev_id = Some("n9Bx2_".to_string());

        let sorted_after_move = ChainSorting::sort_blocks_by_chain(&blocks);
        let moved_children = sorted_after_move.get("j62VDi").unwrap();

        // Verify new position of moved block
        let expected_after_move = vec![
            "I4098s", "1WVpT8", "jBMJf8", "n9Bx2_", "SXTmU4",
            "UX_nxA", "FcPUds", "Zq4qVr"
        ];
        
        assert_eq!(moved_children, &expected_after_move,
            "Moved block not inserted correctly in device group");
            
        // Verify chain integrity for moved block
        let sxtm4_index = moved_children.iter().position(|id| id == "SXTmU4").unwrap();
        assert_eq!(
            moved_children[sxtm4_index - 1], "n9Bx2_",
            "Previous block mismatch after move"
        );
        assert_eq!(
            blocks["SXTmU4"].prev_id.as_deref(),
            Some("n9Bx2_"),
            "prev_id not updated correctly"
        );
    }
}