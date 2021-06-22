package uiguard.orders

import data.common

defaultPermissions := {
	"create": true,
	"update": false,
	"read": false,
	"delete": false,
}

test_anyone_can_create {
	defaultPermissions == permissions with input as {
		"rbacData": {"global": {
			"type": "global",
			"roles": [common.roles.cust],
		}},
		"path": ["permissions", "orders", "Brooklyn99"],
	}
}

test_gm_can_crud {
	gmPermissions == permissions with input as {"rbacData": common.gm_global_entity_sample}
}

test_sm_can_cru_own_store {
	smPermissions == permissions with input as {
		"rbacData": {"Brooklyn99": {
			"type": "store",
			"roles": ["store_manager"],
		}},
		"path": ["permissions", "orders", "Brooklyn99"],
	}
}

test_sm_can_c_other_store {
	defaultPermissions == permissions with input as {
		"rbacData": {"Brooklyn99": {
			"type": "store",
			"roles": ["store_manager"],
		}},
		"path": ["permissions", "orders", "Beverly90210"],
	}
}
