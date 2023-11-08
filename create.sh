#!/bin/bash
set -x
if [ -z $TOKEN ]; then
	echo "Set Terraform Cloud API Token by executing export TOKEN=<Terraform Cloud User or Organization Token>"
	exit
fi

if [ -z $GITHUB_APP_ID ]; then
	echo "Set Terraform Cloud GITHUB APP ID Token by executing export GITHUB_APP_ID=<GITHUB APP ID TOKEN>"
	exit
fi

# $1 == Organization Name
# $2 == Workspace Name
# $3 == Repo Name
# $4 == Variable Set
# $5 == Trigger Run (True or Falss) - Not used yet

ORGANIZATION=$1
WORKSPACE_NAME=$2
REPO_NAME=$3
VARIABLE_SET=$4
TRIGGER_RUN=$5 #Not used yet
WORKING_DIR=azure/demo

WORKSPACE_PAYLOAD=$(cat <<EOF
{"data": {
    "attributes": {
      "name": "$WORKSPACE_NAME",
      "resource-count": 0,
      "terraform_version": "1.6.2",
      "working-directory": "$WORKING_DIR",
      "vcs-repo": {
        "identifier": "$REPO_NAME",
        "github-app-installation-id": "$GITHUB_APP_ID",
        "branch": "",
        "tags-regex": null
      },
      "updated-at": "2023-11-08T19:18:09.976Z"
    },
    "type": "workspaces"
  }
}
EOF
)

WORKSPACE_PAYLOAD_NOVCS=$(cat <<EOF
{"data": {
    "attributes": {
      "name": "$WORKSPACE_NAME",
      "resource-count": 0,
      "terraform_version": "0.11.1",
      "working-directory": "",
      "updated-at": "2023-11-08T19:18:09.976Z"
    },
    "type": "workspaces"
  }
}
EOF
)


echo $WORKSPACE_PAYLOAD
WORKSPACE_CREATE_RESULT=$(curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$WORKSPACE_PAYLOAD" \
  https://app.terraform.io/api/v2/organizations/$ORGANIZATION/workspaces)

WORKSPACE_ID=$(echo $WORKSPACE_CREATE_RESULT | jq -r .data.id)
echo "The Workspace ID: $WORKSPACE_ID"

# Attach Variable Set to Workspace
# Obtain Variable Set from API or from UI by 
# going to https://app.terraform.io/app/mack-demo/settings/varsets
# and clicking on the interested variable set.
# the unique identifier will be in the URL
PAYLOAD=$(cat <<EOF
{
  "data": [
    {
      "type": "workspaces",
      "id": "$WORKSPACE_ID"
    }
  ]
}
EOF
)
echo $PAYLOAD

curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$PAYLOAD" \
  https://app.terraform.io/api/v2/varsets/$VARIABLE_SET/relationships/workspaces


echo "Setup Variables"
VAR_PAYLOAD=$(cat << EOF
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"number_of_servers",
      "value":"1",
      "description":"number_of_servers",
      "category":"terraform",
      "hcl":false,
      "sensitive":false
    }
  }
}
EOF
)
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VAR_PAYLOAD" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars

VAR_PAYLOAD=$(cat << EOF
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"prefix",
      "value":"mack-demo",
      "description":"number_of_servers",
      "category":"terraform",
      "hcl":false,
      "sensitive":false
    }
  }
}
EOF
)
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VAR_PAYLOAD" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars

VAR_PAYLOAD=$(cat << EOF
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"dropletname",
      "value":"dsiprouter",
      "description":"number_of_servers",
      "category":"terraform",
      "hcl":false,
      "sensitive":false
    }
  }
}
EOF
)
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$VAR_PAYLOAD" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars



RUN_PAYLOAD=$(cat <<EOF
{
  "data": {
    "attributes": {
      "message": "Custom message"
    },
    "type":"runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": "$WORKSPACE_ID"
        }
      }
    }
   }
}
EOF
)


curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$RUN_PAYLOAD" \
  https://app.terraform.io/api/v2/runs
