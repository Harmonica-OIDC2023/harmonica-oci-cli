# How to setup OCI-CLI

### OS: Apple M1 Pro(Ventrua 13.2.1)

---

## 1. Install OCI-CLI

[Official Docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

```bash
brew update && brew install oci-cli
oci -v
---
3.29.1
```

## 2. Setup OCI-CLI Configuration

### 1) Interactively

```bash
oci setup config
```

### 2) Use original files

```bash
cat ~/.oci/config
---
[DEFAULT]
user=ocid1.user.oc1..<unique_ID>
fingerprint=<your_fingerprint>
key_file=~/.oci/oci_api_key.pem
tenancy=ocid1.tenancy.oc1..<unique_ID>
# Some comment
region=us-ashburn-1
```

## 3. Fill in dotenv file

### 1) **ALL VARS** are possible to change.

### 2) **ANNOTATED VARS** are to be made soon.

```bash
vi ~/.env
---
COMPARTMENT_ID='.'
FNAPP_NAME='test-cli2'
SUBNET_ID='.'
ORDS_BASE_UTL='.'
DB_USER_SECRET_OCID='test_user'
DB_PASSWORD_SECRET_OCID='Qwerty12345!'
FNFNC_NAME='product-store-operations-python'
APIGW_NAME='test-cli-gw2'
APIDEPLOY_NAME='test-cli-gw-deploy2'
# To be made after executing startup.sh
# FNAPP_ID='.'
# FNFNC_ID='.'
# APIGW_ID='.'
# APIDEPLOY_ID='.'
# APIDEPLOY_ENDPOINT='.'
```

## 4. Initialize function

```bash
cd my-func
```

### 1) You can newly make it with `fn init` or use the original one.

- But notice that all vars and settings(especially apideploy-spec.json) **are fitted with the original one**.

### 2) Check out `OCI Functions > Applications > Resources > Getting Started > Local setup`.

## 5. Execute Startup

```bash
sudo chmod +x ./startup.sh
./startup.sh
```

### 1) IF everything goes well, **ALL** the annotated vars in the dotenv file will be filled.

### 2) IF NOT, check logs 😅.

### 3) During the execution, some **temporary** files will be made(`fnapp.json`, `fnfnc.json`, `apigw.json`, `apideploy.json`). **Just ignore them**.

## 6. FMI

### 1) apideploy-spec.json.bak

- `apideploy-spec.json` can easly be remove, due to code.
- Alternatively, use this backup file instead.
