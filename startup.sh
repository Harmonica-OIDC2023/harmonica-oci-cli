#!/bin/bash
source .env
touch fnapp.json fnfnc.json apigw.json apideploy.json

mkdir logs
export logfile_name=log-`date +%m-%d-%y_%T`
touch logs/$logfile_name

# FUNCTION APPLICATION CREATE
oci fn application create -c $COMPARTMENT_ID \
                        --display-name $FNAPP_NAME \
                        --subnet-ids '["'"${SUBNET_ID}"'"]' \
                        --config "{
                                'ORDS_BASE_URL': '${ORDS_BASE_URL}',
                                'DB_USER_SECRET_OCID': '${DB_USER_SECRET_OCID}',
                                'DB_PASSWORD_SECRET_OCID': '${DB_PASSWORD_SECRET_OCID}'
                            }" > logs/$logfile_name
echo "### 1. fn application created ###########################"
echo "### 1. fn application created ###########################" >> logs/$logfile_name

# DEPLOY FUNCTION
cd my-func
fn deploy --app $FNAPP_NAME >> logs/$logfile_name
cd ../
echo "### 2. fn deploy done ###################################"
echo "### 2. fn deploy done ###################################" >> logs/$logfile_name

# FUNCTION APPLICATION LIST
oci fn application list -c $COMPARTMENT_ID --all > fnapp.json
python3 ./getIds.py "fnapp" # set $FNAPP_ID
source .env
echo "### 3. fn app listed ####################################"
echo "### 3. fn app listed ####################################" >> logs/$logfile_name

# FUNCTION FUNCTION LIST
oci fn function list --application-id $FNAPP_ID --all > fnfnc.json
python3 ./getIds.py "fnfnc" # set $FNFNC_ID
source .env
echo "### 4. fn function listed ###############################"
echo "### 4. fn function listed ###############################" >> logs/$logfile_name

# APIGATEWAY GATEWAY
oci api-gateway gateway create -c $COMPARTMENT_ID --endpoint-type PUBLIC --subnet-id $SUBNET_ID --display-name $APIGW_NAME >> logs/$logfile_name
echo "### 5. api gateway created ##############################"
echo "### 5. api gateway created ##############################" >> logs/$logfile_name

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
                echo "### 6. api gateway listed ###############################"
                echo "### 6. api gateway listed ###############################" >> logs/$logfile_name
                source .env
                break
        fi
    fi
done

# APIGATEWAY DEPLOYMENT CREATE
oci api-gateway deployment create -c $COMPARTMENT_ID --gateway-id $APIGW_ID --path-prefix "/" --display-name $APIDEPLOY_NAME --specification "file://$(pwd)/apideploy-spec.json"  >> logs/$logfile_name
echo "### 7. api deployment created ###########################"
echo "### 7. api deployment created ###########################" >> logs/$logfile_name

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