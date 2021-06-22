# This package gives CRUD controls to the UI side (forwarded from BE)
package uiguard.orders

import data.common
import input

gmPermissions := {
	"create": true,
	"update": true,
	"read": true,
	"delete": true,
}

smPermissions := {
	"create": true,
	"update": true,
	"read": true,
	"delete": false,
}

default permissions = {
	"create": true,
	"update": false,
	"read": false,
	"delete": false,
}

permissions = gmPermissions {
	common.is_gm_role(input)
}

else = smPermissions {
	allowedRoles := {common.roles.sm}

	allowedEntityType := {"orders"}
	some forwardedRoute, entityId, entityType #, i, j

	# # Destructure the input.path
	input.path = [forwardedRoute, entityType, entityId]
	forwardedRoute == "permissions"

	# role check by traversing rbac data
	# first verify the correct entity type present
	input.rbacData[entityId].type == "store" # sm's entity type
	allowedEntityType[entityType] # ensure we're at the right place

	userRoles = input.rbacData[entityId].roles
	userRoles[i] == allowedRoles[j]
}
