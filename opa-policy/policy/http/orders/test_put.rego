package orders

import data.common

test_gm_allowed {
	common.resp_authorized == put with input as {
		"rbacData": common.gm_global_entity_sample,
		"path": ["orders", "Brooklyn99"],
		"originalMethod": "PUT",
	}
}

test_put_allow_sm_on_own_store {
	common.resp_authorized == put with input as {
		"rbacData": {"Brooklyn99": {
			"type": "store",
			"roles": ["store_manager"],
		}},
		"path": ["orders", "Brooklyn99"],
		"originalMethod": "PUT",
	}
}

test_put_not_allow_sm_on_other_store {
	common.resp_unauthorized == put with input as {
		"rbacData": {"BeverlyHills90210": {
			"type": "store",
			"roles": ["store_manager"],
		}},
		"path": ["orders", "Brooklyn99"],
		"originalMethod": "PUT",
	}
}

test_put_not_allow_customer_put {
	common.resp_unauthorized == put with input as {
		"rbacData": {"global": {
			"type": "global",
			"roles": [common.roles.cust],
		}},
		"path": ["orders", "Brooklyn99"],
		"originalMethod": "PUT",
	}
}

test_customer_is_also_GM {
	common.resp_authorized == put with input as {
		"rbacData": {"global": {
			"type": "global",
			"roles": [common.roles.cust, common.roles.gm],
		}},
		"path": ["orders", "Brooklyn99"],
		"originalMethod": "PUT",
	}
}
