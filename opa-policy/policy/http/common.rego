package common

resp_unauthorized = {"authorized": false}

resp_authorized = {"authorized": true}

roles := {
	"sm": "store_manager",
	"gm": "general_manager",
	"cust": "customer",
}

global_entity := "global"

gm_global_entity_sample := {"global": {
	"type": "global",
	"roles": [roles.gm],
}}

is_gm_role(inpt) = result {
	allowedRoles := {roles.gm}

	some i, j

	# Use built in collection.all operator
	result = all([
		inpt.rbacData[global_entity].type == global_entity,
		inpt.rbacData[global_entity].roles[i] == allowedRoles[j],
	])
}

test_can_detect_gm_role {
	true == is_gm_role({"rbacData": gm_global_entity_sample})
}

test_can_detect_not_gm_role {
	not is_gm_role({"rbacData": {"store1": {
		"type": "store",
		"roles": [roles.sm],
	}}})
}
