# Python Signature Example

Signature rules:

1. Parse the request parameters from JSON.
2. Exclude fields whose values are `None`, empty string `""`, or whose key is `sign`.
3. Sort parameters by key in ascending order, then concatenate them as `key1=value1&key2=value2`.
4. Append `&key=merchant_secret` to the end.
5. Apply MD5 to the signing string and output a 32-character lowercase signature.

```python
import hashlib
import json


def generate_sign(params_json: str, merchant_secret: str):
    """
    Generate an MD5 signature according to the signing rules.

    :param params_json: JSON string of request parameters
    :param merchant_secret: Merchant secret key
    :return: (string_to_sign, 32-character lowercase MD5 signature)
    """
    params = json.loads(params_json)

    filtered_params = {
        k: v for k, v in params.items()
        if v is not None and str(v) != "" and k != "sign"
    }
    sorted_keys = sorted(filtered_params.keys())

    param_str = "&".join(f"{k}={filtered_params[k]}" for k in sorted_keys)
    sign_str = f"{param_str}&key={merchant_secret}"
    sign = hashlib.md5(sign_str.encode("utf-8")).hexdigest().lower()

    return sign_str, sign


if __name__ == "__main__":
    test_params_json = json.dumps({
        "trade_no": 10003,
        "order_no": "p7158412025RAprmNz7lR",
        "app_id": 10002,
        "pay_code": 0,
        "price": 10099,
        "pay_notice_url": "http://host/api/v1/mer/cbtest",
        "attach": "",
        "sign": "3d6dea05a7c08564911b9922e16455c2",
        "user_ip": "87.200.59.100",
        "success_url": "",
        "fail_url": "",
        "user_id": "2677343"
    })

    test_secret = "your_merchant_secret_key"

    sign_str, sign_result = generate_sign(test_params_json, test_secret)
    print("String to sign:", sign_str)
    print("Final signature (MD5, 32 lowercase chars):", sign_result)
```
