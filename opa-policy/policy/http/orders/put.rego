package orders

import data.common
import input

# Entity Data
# {
#   "rbacData": {
#     "storeId": {
#       "type": "store",
#       "roles": ["store_manager"]
#     }
#   },
#   "path": ["orders","storeId"],
#   "originalMethod": "GET"
# }

# API side authorzation for orders based on role

# PUT
# Store managers should only be able to PUT their own store orders

default put = {"authorized": false}

# GM should be able to put all orders across all stores
put = common.resp_authorized {
	common.is_gm_role(input)
}

else = common.resp_authorized {
	allowedRoles := {common.roles.sm}
	allowedVerbs := {"PUT"}
	allowedEntityType := {"orders"}
	some entityId, entityType #, i, j

	# # Destructure the input.path
	input.path = [entityType, entityId]

	# verb check
	verb = input.originalMethod
	allowedVerbs[verb]

	# role check by traversing rbac data
	# first verify the correct entity type present
	input.rbacData[entityId].type == "store" # sm's entity type
	allowedEntityType[entityType] # ensure we're at the right place

	userRoles = input.rbacData[entityId].roles
	userRoles[i] == allowedRoles[j]
}
