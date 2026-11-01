// Synthetic real compiled backend HTTP fixtures, source d41e559.
// Export: ops/release-expansion-20261028/backend-company-services-fixtures.json
// Source SHA-256: 525385c0b95f541a4015ec0eb1aa027a36bca055c3a2f2696ed3b6bdf554fa4e
// No credentials, tokens, keys or live customer data.
const companyServicesBackendCases = [
  {
    "name": "grantless-manager",
    "actorCase": "grantless-manager",
    "method": "GET",
    "path": "/api/business/my-services",
    "status": 200,
    "body": {
      "success": true,
      "message": "Success",
      "data": {
        "data": {
          "businessId": "507f1f77bcf86cd799439081",
          "services": ["deepCleaning", "houseCleaning"]
        },
        "locale": "en"
      }
    },
    "assignedPermissions": [],
    "storedCanSeePrices": "absent",
    "privateProfileStatus": 403,
    "genericBusinessStatus": 403
  },
  {
    "name": "explicit-false-grantless-manager",
    "actorCase": "explicit-false-grantless-manager",
    "method": "GET",
    "path": "/api/business/my-services",
    "status": 200,
    "body": {
      "success": true,
      "message": "Success",
      "data": {
        "data": {
          "businessId": "507f1f77bcf86cd799439081",
          "services": ["deepCleaning", "houseCleaning"]
        },
        "locale": "en"
      }
    },
    "assignedPermissions": [],
    "storedCanSeePrices": false,
    "privateProfileStatus": 403,
    "genericBusinessStatus": 403
  }
];
