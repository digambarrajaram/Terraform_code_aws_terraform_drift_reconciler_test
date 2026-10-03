import base64
import json
import os

import boto3
from botocore.exceptions import ClientError


s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET_NAME"]


def _json_response(status_code, payload):
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(payload),
    }


def _valid_key(key):
    if not key or key.startswith("/") or len(key.encode("utf-8")) > 1024:
        return False
    return all(part not in ("", ".", "..") for part in key.split("/"))


def lambda_handler(event, context):
    route = event.get("routeKey", "")
    if route == "GET /health":
        return _json_response(200, {"status": "ok"})

    key = (event.get("pathParameters") or {}).get("key", "")
    if not _valid_key(key):
        return _json_response(400, {"message": "A valid object key is required."})

    if route == "PUT /objects/{key}":
        body = event.get("body") or ""
        if event.get("isBase64Encoded"):
            contents = base64.b64decode(body)
        else:
            contents = body.encode("utf-8")
        headers = event.get("headers") or {}
        content_type = headers.get("content-type", "application/octet-stream")
        s3.put_object(
            Bucket=BUCKET,
            Key=key,
            Body=contents,
            ContentType=content_type,
        )
        return _json_response(201, {"key": key})

    if route == "GET /objects/{key}":
        try:
            result = s3.get_object(Bucket=BUCKET, Key=key)
        except ClientError as error:
            code = error.response.get("Error", {}).get("Code")
            if code in ("NoSuchKey", "404", "NotFound"):
                return _json_response(404, {"message": "Object not found."})
            raise

        contents = result["Body"].read()
        return {
            "statusCode": 200,
            "headers": {
                "content-type": result.get("ContentType", "application/octet-stream")
            },
            "isBase64Encoded": True,
            "body": base64.b64encode(contents).decode("ascii"),
        }

    return _json_response(404, {"message": "Route not found."})
