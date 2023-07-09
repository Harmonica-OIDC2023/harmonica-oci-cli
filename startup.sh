#!/bin/bash
source .env
touch fnapp.json fnfnc.json apigw.json apideploy.json

# FUNCTION APPLICATION CREATE
oci fn application create -c $COMPARTMENT_ID \
                        --display-name $FNAPP_NAME \
                        --subnet-ids '["'"${SUBNET_ID}"'"]' \
                        --config "{
                                'ORDS_BASE_URL': '${ORDS_BASE_UTL}',
                                'DB_USER_SECRET_OCID': '${DB_USER_SECRET_OCID}',
                                'DB_PASSWORD_SECRET_OCID': '${DB_PASSWORD_SECRET_OCID}'
                            }"
echo "### 1. fn application created ###########################"

# DEPLOY FUNCTION
cd my-func
fn deploy --app $FNAPP_NAME
cd ../
echo "### 2. fn deploy done ###################################"

# FUNCTION APPLICATION LIST
oci fn application list -c $COMPARTMENT_ID --all > fnapp.json
python3 ./getIds.py "fnapp" # set $FNAPP_ID
source .env
echo "### 3. fn app listed ####################################"

# FUNCTION FUNCTION LIST
oci fn function list --application-id $FNAPP_ID --all > fnfnc.json
python3 ./getIds.py "fnfnc" # set $FNFNC_ID
source .env
echo "### 4. fn function listed ###############################"


# APIGATEWAY GATEWAY
oci api-gateway gateway create -c $COMPARTMENT_ID --endpoint-type PUBLIC --subnet-id $SUBNET_ID --display-name $APIGW_NAME
echo "### 5. api gateway created ##############################"


# APIGATEWAY GATEWAY LIST
## Until status turns from CREATING to ACTIVE
i=0
echo "api-gateway initializing... can take over 30 seconds..."
while True
do
    oci api-gateway gateway list -c $COMPARTMENT_ID --all > apigw.json
    if [ `python3 ./getIds.py "apigw"` = "CREATING" ] # set $APIGW_ID
        then
            echo $i "seconds,,,"
            sleep 2
            i=$(($i + 2))
        else if [ `python3 ./getIds.py "apigw"` = "ACTIVE" ]
            then
                echo "### 6. api gateway listed ##############################"
                source .env
                break
        fi
    fi
done

# APIGATEWAY DEPLOYMENT CREATE
oci api-gateway deployment create -c $COMPARTMENT_ID --gateway-id $APIGW_ID --path-prefix "/" --display-name $APIDEPLOY_NAME --specification "file://$(pwd)/apideploy-spec.json"
echo "### 7. api deployment created ############################"

# APIGATEWAY DEPLOYMENT LIST
oci api-gateway deployment list -c $COMPARTMENT_ID --all > apideploy.json
python3 ./getIds.py "apideploy" # set $APIDEPLOY_ID, $APIDEPLOY_ENDPOINT
source .env

# TO DO
## Add endpoint(.env/$APIDEPLOY_ENDPOINT) in index.html
## If url needs update
### oci api-gateway deployment update --deployment-id $APIDEPLOY_ID --specification "file://$(pwd)/apideploy-spec.json"

# CLEAN TMP FILES
rm -rf fnapp.json fnfnc.json apigw.json apideploy.json