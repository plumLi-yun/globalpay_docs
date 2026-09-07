# PHP 签名示例

签名规则：

1. 解析请求参数 JSON。
2. 过滤值为 `null`、空字符串 `""` 和字段 `sign`。
3. 按参数名升序排序后，拼接为 `key1=value1&key2=value2`。
4. 末尾追加 `&key=商户密钥`。
5. 对待签名字符串做 MD5，输出 32 位小写签名。

```php
<?php

function generateSign(string $paramsJson, string $merchantSecret): array
{
    $params = json_decode($paramsJson, true, 512, JSON_THROW_ON_ERROR);

    $filteredParams = [];
    foreach ($params as $key => $value) {
        if ($key === 'sign') {
            continue;
        }
        if ($value === null) {
            continue;
        }
        if ((string)$value === '') {
            continue;
        }
        $filteredParams[$key] = $value;
    }

    ksort($filteredParams, SORT_STRING);

    $pairs = [];
    foreach ($filteredParams as $key => $value) {
        $pairs[] = $key . '=' . $value;
    }

    $paramStr = implode('&', $pairs);
    $signStr = $paramStr . '&key=' . $merchantSecret;
    $sign = strtolower(md5($signStr));

    return [$signStr, $sign];
}

$testParamsJson = json_encode([
    'trade_no' => 10003,
    'order_no' => 'p7158412025RAprmNz7lR',
    'app_id' => 10002,
    'pay_code' => 0,
    'price' => 10099,
    'pay_notice_url' => 'http://host/api/v1/mer/cbtest',
    'attach' => '',
    'sign' => '3d6dea05a7c08564911b9922e16455c2',
    'user_ip' => '87.200.59.100',
    'success_url' => '',
    'fail_url' => '',
    'user_id' => '2677343',
], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);

$testSecret = 'your_merchant_secret_key';

[$signStr, $signResult] = generateSign($testParamsJson, $testSecret);
echo '待签名字符串: ' . $signStr . PHP_EOL;
echo '最终签名(MD5, 32位小写): ' . $signResult . PHP_EOL;
```
