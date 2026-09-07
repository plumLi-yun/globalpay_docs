# PHP Signature Example

Signature rules:

1. Parse the request parameters from JSON.
2. Exclude fields whose values are `null`, empty string `""`, or whose key is `sign`.
3. Sort parameters by key in ascending order, then concatenate them as `key1=value1&key2=value2`.
4. Append `&key=merchant_secret` to the end.
5. Apply MD5 to the signing string and output a 32-character lowercase signature.

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
echo 'String to sign: ' . $signStr . PHP_EOL;
echo 'Final signature (MD5, 32 lowercase chars): ' . $signResult . PHP_EOL;
```
