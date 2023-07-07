import json
import os
import dotenv  # pip3 install python-dotenv
import sys

dotenv_file = dotenv.find_dotenv()
dotenv.load_dotenv(dotenv_file)

# FUNCTION APPLICATION
if sys.argv[1] == "fnapp":
    with open("./fnapp.json", encoding='utf-8') as f:
        result = json.load(f)
        for data in result["data"]:
            if data["display-name"] == os.environ["FNAPP_NAME"]:
                dotenv.set_key(dotenv_file, "FNAPP_ID", data["id"])
                break

# FUNCTION FUNCTION
elif sys.argv[1] == "fnfnc":
    with open("./fnfnc.json", encoding='utf-8') as f:
        result = json.load(f)
        for data in result["data"]:
            if data["display-name"] == os.environ["FNFNC_NAME"]:
                dotenv.set_key(dotenv_file, "FNFNC_ID", data["id"])
                break
    f = open("./apideploy-spec.json", "r")
    file = f.read().replace("FUNCTION_ID", data["id"])
    f.close()
    f = open("./apideploy-spec.json", "w")
    f.write(file)
    f.close()

# APIGATEWAY GATEWAY
elif sys.argv[1] == "apigw":  # active
    with open("./apigw.json", encoding='utf-8') as f:
        result = json.load(f)
        for data in result["data"]["items"]:
            if data["display-name"] == os.environ["APIGW_NAME"]:
                if data["lifecycle-state"] == "ACTIVE":
                    dotenv.set_key(dotenv_file, "APIGW_ID", data["id"])
                    os.system("echo 'ACTIVE'")
                    break
                elif data["lifecycle-state"] == "CREATING":
                    os.system("echo 'CREATING'")
                    break

# APIGATEWAY DEPLOYMENT
elif sys.argv[1] == "apideploy":
    with open("./apideploy.json", encoding='utf-8') as f:
        result = json.load(f)
        for data in result["data"]["items"]:
            if data["display-name"] == os.environ["APIDEPLOY_NAME"]:
                dotenv.set_key(dotenv_file, "APIDEPLOY_ID", data["id"])
                dotenv.set_key(dotenv_file, "APIDEPLOY_ENDPOINT",
                               data["endpoint"])
                os.system("echo api-endpoint: %s" %
                          data["endpoint"])
                break
