# Golang 签名示例

签名规则：

1. 解析请求参数 JSON。
2. 过滤值为 `nil`、空字符串 `""` 和字段 `sign`。
3. 按参数名升序排序后，拼接为 `key1=value1&key2=value2`。
4. 末尾追加 `&key=商户密钥`。
5. 对待签名字符串做 MD5，输出 32 位小写签名。

```go
package main

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
)

func generateSign(paramsJSON string, merchantSecret string) (string, string, error) {
	var params map[string]interface{}
	if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
		return "", "", err
	}

	filteredParams := make(map[string]interface{})
	for key, value := range params {
		if key == "sign" || value == nil {
			continue
		}
		if fmt.Sprint(value) == "" {
			continue
		}
		filteredParams[key] = value
	}

	keys := make([]string, 0, len(filteredParams))
	for key := range filteredParams {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	parts := make([]string, 0, len(keys))
	for _, key := range keys {
		parts = append(parts, fmt.Sprintf("%s=%v", key, filteredParams[key]))
	}

	paramStr := strings.Join(parts, "&")
	signStr := paramStr + "&key=" + merchantSecret

	sum := md5.Sum([]byte(signStr))
	sign := hex.EncodeToString(sum[:])

	return signStr, sign, nil
}

func main() {
	testParams := map[string]interface{}{
		"trade_no":        10003,
		"order_no":        "p7158412025RAprmNz7lR",
		"app_id":          10002,
		"pay_code":        0,
		"price":           10099,
		"pay_notice_url":  "http://host/api/v1/mer/cbtest",
		"attach":          "",
		"sign":            "3d6dea05a7c08564911b9922e16455c2",
		"user_ip":         "87.200.59.100",
		"success_url":     "",
		"fail_url":        "",
		"user_id":         "2677343",
	}

	data, err := json.Marshal(testParams)
	if err != nil {
		panic(err)
	}

	signStr, signResult, err := generateSign(string(data), "your_merchant_secret_key")
	if err != nil {
		panic(err)
	}

	fmt.Println("待签名字符串:", signStr)
	fmt.Println("最终签名(MD5, 32位小写):", signResult)
}
```
