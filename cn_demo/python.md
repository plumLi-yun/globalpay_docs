# Python 签名示例

签名规则：

1. 解析请求参数 JSON。
2. 过滤值为 `None`、空字符串 `""` 和字段 `sign`。
3. 按参数名升序排序后，拼接为 `key1=value1&key2=value2`。
4. 末尾追加 `&key=商户密钥`。
5. 对待签名字符串做 MD5，输出 32 位小写签名。

```python
import hashlib
import json


def generate_sign(params_json: str, merchant_secret: str):
    """
    根据签名规则生成 MD5 签名

    :param params_json: 参数的 JSON 字符串
    :param merchant_secret: 商户密钥
    :return: (待签名字符串, 32位小写MD5签名结果)
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
    print("待签名字符串:", sign_str)
    print("最终签名(MD5, 32位小写):", sign_result)
```
