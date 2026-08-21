# 1. Integration Process

> 1. Complete business onboarding and confirm the relevant rates.
>
> 2. Contact operations to create the merchant number, secret key, merchant appId, product code, and apiUrl.
>
> 3. After development is completed, both parties will perform integration testing to verify that requests, reporting, and other information are complete.

# 2. MD5 Signature Algorithm

> 1. Sort all parameters in ascending order by key-value pair (`key1=value1`). Parameters with empty values do not participate in the signature.
>
> 2. Concatenate them in the format `key1=value1&key2=value2`.
>
> 3. Append the merchant secret key: `key1=value1&key2=value2...&key=merchant_secret_key`.
>
> 4. `sign=md5(the string assembled in the previous step)`. The signature result is a 32-character lowercase string.
>
> 5. For the signing key, please check Merchant Backend -> Basic Information, or contact our customer service.

# 3. Notes

## 3.1 API Related
> 1. All APIs in this document use the standard HTTP protocol with POST requests. Both request and response `Content-type` are `application/json`, and the character encoding is unified as `UTF-8`.
>
> 2. The amount unit is <span style="color:red;">Hong Kong Cents (Cents)</span>.
>
> 3. The requesting IP must be whitelisted.
>
> 4. `user_ip` should collect the user's real IP whenever possible. If unavailable, leave it empty. Do not use a local IP such as `127.0.0.1`.

## 3.2 Callback Related
> 1. After successfully processing the callback, please return the text `success` without any additional characters. Otherwise, the system will continue to resend the order notification multiple times.
>
> 2. During asynchronous notification interaction, if the received response is not `success`, the notification will be considered failed, and retries will be sent periodically according to the following schedule: `1m`, `1m`, `4m`, `10m`, `10m`, `1h`, `2h`, `6h`, `15h`.
>
> 3. If `pay_notice_url` is empty, it will be considered that the merchant does not require a callback, and the system will not push notifications.

# 4. Pay-in Order API

(The order IP must be whitelisted by contacting us.)
Order URL: `https://{api_domain}/api/v1/payApi/CreatePayInOrder`

## 4.1 Pay-in Order Request Parameters

| Name             | Type   | Required  | Description                                                                                                      |
|----------------|------|-----|---------------------------------------------------------------------------------------------------------|
| trade_no       | int    | true  | Merchant number                                                                                                     |
| app_id         | int    | true  | Merchant appId                                                                                                |
| pay_code       | int    | true  | Product code, contact our operations team to obtain                                                                                           |
| pay_method     | string    | true  | Payment method, see the payment methods below                                                                                            |
| price          | int    | true  | Order amount, unit: Hong Kong Cents (Cents), integer. 1 Hong Kong Dollar (HKD) = 100 Hong Kong Cents                                                                 |
| order_no       | string | true  | Merchant order number                                                                                                   |
| success_url    | string | false | Redirect URL after successful payment                                                                                              |
| fail_url       | string | false | Redirect URL after failed payment                                                                                              |
| pay_notice_url | string | false | Payment success notification URL                                                                                              |
| user_id        | string | false | Merchant user ID                                                                                                  |
| user_ip        | string | false | Payer IP                                                                                                  |
|attach|string|false| Additional parameter JSON string for payer information |
| sign           | string | true  | Signature result, see the signature method at the top of this document                                                                                          |
|timestamp|string|false| Order timestamp, 10-digit timestamp in seconds                                                                                         |

- Pay-in `attach` Additional Parameter Field Description

| Name            | Type     | Required    | Description                                                                      |
|---------------|--------|-------|-------------------------------------------------------------------------|
| phone         | string    | false | Phone number (please provide the real phone number whenever possible; use a placeholder if unavailable)                                                     |
| email         | string    | false | Email address (please provide the real email address whenever possible; use a placeholder if unavailable)                                                       |
| product_name  | string    | false | Product name                                                                    |


- Pay-in Order Request Example

```json
{
  "trade_no": 10003,
  "order_no": "p7158412025RAprmNz7lR",
  "app_id": 10002,
  "pay_code": 0,
  "price": 10099,
  "pay_notice_url": "http://host/api/v1/mer/cbtest",
  "attach": "{\"phone\":\"91234567\",\"email\":\"john.doe@example.com\",\"product_name\":\"Test Product\"}",
  "sign": "3d6dea05a7c08564911b9922e16455c2",
  "user_ip": "203.198.1.1",
  "success_url": "",
  "fail_url": "",
  "user_id": "2677343"
}
```

## 4.2 Pay-in Order Response

| Name         | Type   | Required | Description                                                                                                                                                                                              |
|------------|------|----|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| code         | int    | true | `200`: Order created successfully; others: order creation failed                                                                                                                                                                                |
| msg          | string | true | Failure reason                                                                                                                                                                                            |
| pay_url      | string | false | Payment link                                                                                                                                                                                            |
| qr_code      | string | false | QR code string                                                                                                                                                                                          |
| order_no     | string | true | Merchant order number                                                                                                                                                                                           |
| dis_order_no | string | true | Platform order number                                                                                                                                                                                           |
| create_time  | int    | true | Creation time                                                                                                                                                                                            |
| pay_info  | string    | false | Payment information JSON string, for example: collection/payment raw information, card number, name, bank, etc. `{"pay_raw":"raw payment info","redirect_url":"payment redirect link"}` |
| sign         | string | true | Signature result, see the signature method at the top of this document                                                                                                                                                                                  |

- Pay-in Order Response Example

Failed:

```json
{
  "code": 1005,
  "msg": "Merchant not found",
  "sign": ""
}
```

Successful:

```json
{
  "code": 200,
  "msg": "",
  "sign": "b449b4b6907204a683ec6c50bff92b01",
  "order_no": "p7158412025J2dZjXLmz0",
  "dis_order_no": "2025071130770572062498816hkg1oushe",
  "create_time": 1752825512,
  "pay_url": "https://{api_domain}/checkout/scanqr/943543da169d4757a40bfa49b3eb83b5"
}
```

# 5. Pay-in Callback Notification `post/json`

Push URL: the `pay_notice_url` submitted by the merchant when creating the order. Callback IP: `call_back_server_ip`. Please add our IP to your callback whitelist.

## 5.1 Pay-in Callback Request Parameters

| Name         | Type   | Required  | Description                                                                                                                                                                                       |
|------------|------|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| trade_no     | int    | true  | Merchant number                                                                                                                                                                                      |
| status       | int    | true  | Order status, `2`: success, `3`: failure                                                                                                                                                                         |
| order_no     | string | true  | Merchant order number                                                                                                                                                                                    |
| dis_order_no | string | true  | Platform order number                                                                                                                                                                                    |
| order_price  | int    | true  | Order amount, unit: Hong Kong Cents (Cents)                                                                                                                                                                        |
| real_price   | int    | true  | Actual amount paid by the user, unit: Hong Kong Cents (Cents)                                                                                                                                                                   |
| nti_time     | int    | false | Notification initiation time                                                                                                                                                                                   |
| payer        | string | false | JSON string containing payer information `{"name":"name","account":"account","bank":"payer bank code","utr2":"bank serial number","email":"email","phone":"phone number","identify_type":"ID type","identify_num":"ID number"}`. In addition to the example fields, this parameter currently merges payer-related fields passed by the merchant in `attach`. |
| pay_info  | string    | false | Payment information JSON string, for example: collection/payment raw information, card number, name, bank, etc. |
| create_time  | int    | true  | Creation time                                                                                                                                                                                     |
| sign         | string | true  | Signature result, see the signature method at the top of this document                                                                                                                                                                           |

- Pay-in Callback Request Example

```json
{
  "trade_no": 10238,
  "status": 2,
  "order_no": "RCG0126042435820040804784",
  "dis_order_no": "Meg1352644s0800hkganVMR",
  "order_price": 10000,
  "real_price": 10000,
  "nti_time": 1776680622,
  "payer": "{\"account_no\":\"1234567890\",\"account_type\":\"FPS\",\"identify_num\":\"A123456(7)\",\"identify_type\":\"HKID\",\"req_api_ip\":\"203.198.1.1\",\"utr2\":\"9901108391\"}",
  "create_time": 1776680593,
  "sign": "7b23565a3dc790b6e55f29f0f0cf5f1a"
}
```
## 5.2 Pay-in Callback Response Description
After successfully processing the callback, please return `success`. The system will then stop pushing this order notification; otherwise, it will continue to retry.

# 6. Pay-out Order API

(The order IP must be whitelisted by contacting us.)
Order URL: `https://{api_domain}/api/v1/payApi/CreatePayOutOrder`

## 6.1 Pay-out Request Parameters

| Name             | Type     | Required    | Description                                                                     |
|----------------|--------|-------|------------------------------------------------------------------------|
| trade_no       | int    | true  | Merchant number                                                                    |
| order_no       | string | true  | Merchant order number                                                                  |
| app_id         | int    | true  | Merchant appId                                                               |
| pay_code       | int    | true  | Product code, contact our operations team to obtain                                                          |
| price          | int    | true  | Order amount, unit: Hong Kong Cents (Cents), integer. 1 Hong Kong Dollar (HKD) = 100 Hong Kong Cents                                 |
| account_no     | string | true  | Beneficiary account                                                                   |
| account_type   | string | false | Account type                                                                   |
| account_name   | string | true  | Name                                                                     |
| bank_code      | string | true  | Bank code                                                                   |
| identify_type  | string | false | ID type                                                                   |
| identify_num   | string | false | ID number                                                                   |
| pay_notice_url | string | false | Pay-out success notification URL                                                             |
| attach         | string | false | Additional parameter JSON string                                                           |
| user_ip        | string | false | Beneficiary IP                                                                |
| sign           | string | true  | Signature result, see the signature method at the top of this document                                                         |
| timestamp      | string | false | Order timestamp, 10-digit timestamp in seconds                                                       |

- Pay-out `attach` Additional Parameter Field Description

| Name       | Type     | Required   | Description             |
|----------|--------|------|----------------|
| fps_id |string| false | FPS identifier |
| bank_name | string | false | Bank name |
| branch_code | string | false | Branch code |


- Pay-out Request Example

```json
{
  "trade_no": 10003,
  "order_no": "p7158412025MsJydJqT7b",
  "app_id": 10002,
  "pay_code": 1,
  "price": 10001,
  "pay_notice_url": "http://host/api/v1/mer/cbtest",
  "attach": "{\"fps_id\":\"john.doe@fps\",\"bank_name\":\"HSBC Hong Kong\"}",
  "sign": "12f74d71fa929087af79b5083567c453",
  "user_ip": "203.198.1.1",
  "account_type": "FPS",
  "account_no": "1234567890",
  "account_name": "John Doe",
  "bank_code": "HK_HSBC",
  "identify_type": "HKID",
  "identify_num": "A123456(7)"
}
```

## 6.2 Pay-out Order Response

| Name         | Type   | Required | Description                                          |
|------------|------|----|---------------------------------------------|
| code         | int    | true | `200`: Order created successfully; others: order creation failed                            |
| msg          | string | true | Failure reason                                        |
| dis_order_no | string | true | Platform order number                                       |
| order_no     | string | true | Merchant order number                                       |
| status       | int    | true | Order status: `2` pay-out success, `3` pay-out failure, `7` rejected, `9` reversed, `10` processing |
| create_time  | int    | true | Creation time                                        |
| sign         | string | true | Signature result, see the signature method at the top of this document                              |

- Pay-out Order Response Example

Failed:

```json
{
  "code": 1005,
  "msg": "Merchant not found",
  "sign": ""
}
```

Successful:

```json
{
  "code": 200,
  "msg": "",
  "sign": "d3ec1fa0f45bc44218d5fb63bb1beb61",
  "order_no": "p7158412025MsJydJqT7b",
  "dis_order_no": "2025071130776296733810688hkg1Dhr7H",
  "create_time": 1752826877,
  "status": 10
}
```

# 7. Pay-out Callback Notification

Push URL: the `pay_notice_url` submitted by the merchant when creating the order. Callback IP: `call_back_server_ip`. Please add our IP to your callback whitelist.

## 7.1 Pay-out Callback Request Parameters

| Name         | Type   | Required  | Description                                            |
|------------|------|-----|-----------------------------------------------|
| trade_no     | int    | true  | Merchant number                                           |
| order_no     | string | true  | Merchant order number                                         |
| dis_order_no | string | true  | Platform order number                                         |
| order_price        | int    | true  | Order amount, unit: Hong Kong Cents (Cents)                                     |
| fee          | int    | false | Order fee, unit: Hong Kong Cents (Cents)                         |
| status       | int    | true  | Order status, `2` pay-out success, `3` pay-out failure, `7` rejected, `9` reversed               |
| pay_info  | string    | false | Payment information JSON string, for example: collection/payment raw information, card number, name, bank, `utr2`, etc. |
| remark       | string | false | Failure reason                                          |
| create_time  | int    | true  | Creation time                                          |
| sign         | string | true  | Signature result, see the signature method at the top of this document                                |
| nti_time     | int    | true | Notification initiation time                                        |

- Pay-out Callback Request Example

```json
{
  "trade_no": 10000,
  "status": 2,
  "order_no": "20060354339090013",
  "dis_order_no": "Meg2352644o2nmjo0800hkgYZ2A",
  "order_price": 11000,
  "nti_time": 1776665229,
  "create_time": 1776665034,
  "sign": "d2f74c18dca3bd6bd79172a1a7c26d9a",
  "pay_info": "{\"utr2\":\"611011445289\"}"
}
```
## 7.2 Pay-out Callback Response Description
After successfully processing the callback, please return `success`. The system will then stop pushing this order notification; otherwise, it will continue to retry.

# 8. Order Query API (Shared by Pay-in and Pay-out)

(The requesting IP must be whitelisted by contacting us.)
Query URL: `https://{api_domain}/api/v1/payApi/QueryOrder`

## 8.1 Query Request Parameters

| Name         | Type   | Required | Description                        |
|------------|------|----|---------------------------|
| order_type | string | true | `pay_out`: pay-out, `pay_in`: pay-in    |
| trade_no   | int    | true | Merchant number                      |
| app_id         | int    | true  | Merchant appId                    |
| dis_order_no | string | false | Platform order number                |
| order_no | string | false  | Merchant order number                |
| sign       | string | true | Signature result, see the signature method at the top of this document |

- Query Request Example

```json
{
  "order_type": "pay_in",
  "trade_no": 165,
  "app_id": 165,
  "dis_order_no": "p7158277185f96603047656571",
  "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```

## 8.2 Query Response

| Name         | Type   | Required  | Description                                                                                                                                                |
|------------|------|-----|---------------------------------------------------------------------------------------------------------------------------------------------------|
| code         | int    | true  | `200`: Query successful; others: failed                                                                                                                                    |
| msg          | string | true  | Reason for query failure                                                                                                                                            |
| trade_no     | int    | true  | Merchant number                                                                                                                                               |
| real_price   | int    | true  | Actual paid amount, unit: Hong Kong Cents (Cents)                                                                                                                              |
| status       | int    | true  | Order status: `1` unpaid, `2` success, `3` failure, `7` rejected, `9` reversed, `10` processing                                                                                                       |
| success_time | int    | true  | Success timestamp                                                                                                                                             |
| order_no     | string | true  | Merchant order number                                                                                                                                             |
| dis_order_no | string | true  | Platform order number                                                                                                                                             |
| remark       | string | true  | Pay-out failure reason                                                                                                                                            |
| fee          | int    | false | Order fee, unit: Hong Kong Cents (Cents)                                                                                                                               |
| create_time  | int    | true  | Creation time                                                                                                                                              |
| payer        | string | false | JSON string containing payer information `{"account_name":"name","account_type":"account type","account_no":"account","identify_type":"ID type","identify_num":"ID number"}` |
| pay_info  | string    | false | Payment information JSON string, for example: collection/payment raw information, card number, name, bank, etc. |
| sign         | string | true  | Signature result, see the signature method at the top of this document                                                                                                                                    |
|utr2|string|false|Bank order number|

- Query Response Example

Failed:

```json
{
  "code": 1017,
  "msg": "Order does not exist"
}
```

Successful:

```json
{
  "code": 200,
  "msg": "success",
  "trade_no": 123,
  "real_price": 10000,
  "status": 2,
  "success_time": 1693057443,
  "order_no": "47210116924681604173",
  "dis_order_no": "lufei169246816001692",
  "remark": "",
  "fee": 10,
  "create_time": 1695317066,
  "payer": "{\"account_name\":\"John Doe\",\"account_type\":\"FPS\",\"account_no\":\"1234567890\",\"identify_type\":\"HKID\",\"identify_num\":\"A123456(7)\"}",
  "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```

# 9. Pay-out Balance Query API

(The requesting IP must be whitelisted by contacting us.)
URL: `https://{api_domain}/api/v1/payApi/QueryBalance`

## 9.1 Balance Request Parameters

| Name     | Type   | Required | Description             |
|--------|------|----|----------------|
| trade_no | int    | true | Merchant number            |
| app_id   | int    | true | Merchant appid       |
| sign     | string | true | Signature result, see the signature method at the top of this document |

- Balance Request Example

```json
{
  "trade_no": 165,
  "app_id": 281,
  "sign": "db3406277185f9660b3b928d6adc115"
}
```

## 9.2 Balance Response

| Name    | Type   | Required | Description                        |
|-------|------|----|---------------------------|
| code    | int    | true | `200`: Query successful; others: failed      |
| msg     | string | true | Failure reason                    |
| balance | int    | true | Balance, unit: Hong Kong Cents (Cents)       |
| balance_frozen | int    | false | Frozen balance, unit: Hong Kong Cents (Cents) |
| sign    | string | true | Signature result, see the signature method at the top of this document |

- Balance Response Example

Failed:

```json
{
  "code": 10001,
  "msg": "Merchant does not exist"
}
```

Successful:

```json
{
  "code": 200,
  "msg": "success",
  "balance": 10000,
  "balance_frozen": 1000,
  "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```
# 10. Payment Voucher Query API

(The requesting IP must be whitelisted by contacting us.)
URL: `https://{api_domain}/api/v1/payApi/QueryCertificate`

## 10.1 Payment Voucher Request Parameters

| Name     | Type   | Required | Description             |
|--------|------|----|----------------|
| trade_no | int    | true | Merchant number            |
| app_id   | int    | true | Merchant appid       |
| order_no   | string    | false | Merchant order number, choose one of `order_no` or `dis_order_no`    |
| dis_order_no   | string    | false | Platform order number, choose one of `order_no` or `dis_order_no`    |
| sign     | string | true | Signature result, see the signature method at the top of this document |

- Payment Voucher Request Example

```json
{
  "trade_no": 10003,
  "app_id": 10003,
  "order_no": "",
  "dis_order_no": "35011C02gljuf6k0800hkg1lVY",
  "sign": "3969f17cd1a551769f85967d0a05b7b6"
}
```

## 10.2 Payment Voucher Response Parameters

| Name    | Type   | Required | Description                        |
|-------|------|----|---------------------------|
| code    | int    | true | `200`: Response successful; others: failed      |
| msg     | string | true | Failure reason                    |
| img_link | string    | false | Voucher link       |
| img_base | string    | false | Base64 content of the generated voucher                 |
| sign    | string | true | Signature result, see the signature method at the top of this document |

- Payment Voucher Response Example
  No payment voucher available
```json
{
  "code":200,
  "msg":"No payment voucher available at the moment",
  "sign": "",
  "img_link": "",
  "img_base": ""
}
```
Payment voucher available
```json
{
  "code": 200,
  "msg": "",
  "sign": "3969f17cd1a551769f85967d0a05b7b6",
  "img_link": "http://dsggfgdsf.djdj?ddd=snn",
  "img_base": "data:image/png;base64,hfhshdhfhfh"
}
```


# 11. Payment Methods for Pay-in `pay_method`


| pay_method | Region   | Value             | Description           |
|------------|--------|---------------|----------------|
| pay_method        | Hong Kong   | FPS        | FPS Payment            |
| pay_method        | Hong Kong   | BANK_HK        | Bank Transfer            |


# 12. Bank Codes

| Field Name | Code | Bank Name |
| :--- | :--- | :--- |
| bank_code | BETPAY | BetPay |
| bank_code | ZSK | 转数快 |
| bank_code | ZDBXG | 渣打銀行(香港)有限公司 |
| bank_code | XGSHHF | 香港上海匯豐銀行有限公司 |
| bank_code | DFHL | 東方匯理銀行 |
| bank_code | HQB | 花旗銀行 |
| bank_code | MGDT | 摩根大通銀行 |
| bank_code | GMXMS | 國民西敏寺資本市場銀行有限公司 |
| bank_code | ZGJSB | 中國建設銀行(亞洲)股份有限公司 |
| bank_code | ZGB | 中國銀行(香港)有限公司 |
| bank_code | DYB | 東亞銀行有限公司 |
| bank_code | XZB | 星展銀行(香港)有限公司 |
| bank_code | ZXB | 中信銀行國際有限公司 |
| bank_code | ZSYL | 招商永隆銀行有限公司 |
| bank_code | HUAQB | 華僑銀行 |
| bank_code | HSB | 恒生銀行有限公司 |
| bank_code | SHY | 上海商業銀行有限公司 |
| bank_code | JTB | 交通銀行股份有限公司 |
| bank_code | DZB | 大眾銀行(香港)有限公司 |
| bank_code | HQYH | 華僑永亨銀行有限公司 |
| bank_code | DAYB | 大有銀行有限公司 |
| bank_code | JIYB | 集友銀行有限公司 |
| bank_code | DXB | 大新銀行有限公司 |
| bank_code | CXB | 創興銀行有限公司 |
| bank_code | NYSY | 南洋商業銀行有限公司 |
| bank_code | UCOB | UCOBANK |
| bank_code | KEBHANABANK | KEBHANABANK |
| bank_code | SLUFJ | 三菱UFJ銀行 |
| bank_code | PANGB | 盤谷銀行 |
| bank_code | YDHY | 印度海外銀行 |
| bank_code | DYZB | 德意志銀行 |
| bank_code | MGB | 美國銀行 |
| bank_code | FZBL | 法國巴黎銀行 |
| bank_code | YDB | 印度銀行 |
| bank_code | BJGM | 巴基斯坦國民銀行 |
| bank_code | DSB | 大生銀行有限公司 |
| bank_code | MLB | 馬來亞銀行 |
| bank_code | SJZY | 三井住友銀行 |
| bank_code | YNGB | 印尼國家銀行 |
| bank_code | JYB | 金融銀行有限公司 |
| bank_code | DAHB | 大華銀行有限公司 |
| bank_code | ZGGSB | 中國工商銀行(亞洲)有限公司 |
| bank_code | BARCLAYSBANKPLC | BARCLAYSBANKPLC. |
| bank_code | JNDFY | 加拿大豐業銀行 |
| bank_code | JNDHJ | 加拿大皇家銀行 |
| bank_code | FGXY | 法國興業銀行 |
| bank_code | YDGB | 印度國家銀行 |
| bank_code | DLDDM | 多倫多道明銀行 |
| bank_code | MDKB | 滿地可銀行 |
| bank_code | JNDDG | 加拿大帝國商業銀行 |
| bank_code | DGSY | 德國商業銀行 |
| bank_code | RSB | 瑞士銀行 |
| bank_code | MGHF | 美國滙豐銀行 |
| bank_code | RUISB | 瑞穗銀行 |
| bank_code | DGZY | 德國中央合作銀行 |
| bank_code | YOULB | 友利銀行 |
| bank_code | PHILIPPINENATIONALBANK | PHILIPPINENATIONALBANK |
| bank_code | FUBB | 富邦銀行(香港)有限公司 |
| bank_code | SLUFJXT | 三菱UFJ信託銀行 |
| bank_code | NYMLB | 紐約梅隆銀行有限公司 |
| bank_code | INGBANKN | INGBANKN.V. |
| bank_code | XBYDY | 西班牙對外銀行 |
| bank_code | ADLYG | 澳大利亞國民銀行 |
| bank_code | XTPY | 西太平洋銀行 |
| bank_code | AOXINB | 澳新銀行集團有限公司 |
| bank_code | AZLB | 澳洲聯邦銀行 |
| bank_code | YDLLH | 義大利聯合聖保羅銀行股份有限公司 |
| bank_code | YUXB | 裕信(德國)銀行股份有限公司 |
| bank_code | RDSY | 瑞典商業銀行 |
| bank_code | QIANYB | 千葉銀行 |
| bank_code | BLSLH | 比利時聯合銀行 |
| bank_code | FUGUO | 富國銀行香港分行 |
| bank_code | HELAN | 荷蘭合作銀行 |
| bank_code | XINZHAN | 星展銀行香港分行 |
| bank_code | JINW | 靜岡銀行 |
| bank_code | BASER | 八十二銀行 |
| bank_code | HUANSY | 華南商業銀行股份有限公司 |
| bank_code | ZIHB | 滋賀銀行 |
| bank_code | YIWAN | 臺灣銀行股份有限公司 |
| bank_code | THECHUGOKUBANKLIMITED | THECHUGOKUBANKLIMITED |
| bank_code | DYSY | 第一商業銀行股份有限公司 |
| bank_code | ZHSY | 彰化商業銀行股份有限公司 |
| bank_code | FGWM | 法國外貿銀行 |
| bank_code | ZGGS | 中國工商銀行股份有限公司 |
| bank_code | MGDF | 美國道富銀行 |
| bank_code | ZGJS | 中國建設銀行股份有限公司 |
| bank_code | ZGNY | 中國農業銀行股份有限公司 |
| bank_code | ERSTEGROUPBANKAG | ERSTEGROUPBANKAG |
| bank_code | ZGXT | 中國信託商業銀行股份有限公司 |
| bank_code | YWZXQY | 臺灣中小企業銀行股份有限公司 |
| bank_code | CREDITSUISSEAG | CREDITSUISSEAG |
| bank_code | GTSHSY | 國泰世華商業銀行股份有限公司 |
| bank_code | RSYF | 瑞士盈豐銀行股份有限公司 |
| bank_code | ZSYB | 招商銀行股份有限公司 |
| bank_code | TBFBSY | 台北富邦商業銀行股份有限公司 |
| bank_code | YFSYB | 永豐商業銀行股份有限公司 |
| bank_code | ZFGJSY | 兆豐國際商業銀行 |
| bank_code | YSSYB | 玉山商業銀行股份有限公司 |
| bank_code | TXGJSY | 台新國際商業銀行股份有限公司 |
| bank_code | FLYB | 豐隆銀行有限公司 |
| bank_code | ZDB | 渣打銀行 |
| bank_code | HQXGB | 花旗銀行(香港)有限公司 |
| bank_code | ICICIBANKLIMITED | ICICIBANKLIMITED |
| bank_code | MELLIBANKPLC | MELLIBANKPLC |
| bank_code | HUAMB | 華美銀行 |
| bank_code | BALD | 巴魯達銀行 |
| bank_code | YDGJSY | 遠東國際商業銀行股份有限公司 |
| bank_code | CANARABANK | CANARABANK |
| bank_code | GUOTB | 國泰銀行 |
| bank_code | TWTDB | 台灣土地銀行股份有限公司 |
| bank_code | HZJKSY | 合作金庫商業銀行股份有限公司 |
| bank_code | PUNJABNATIONALBANK | PUNJABNATIONALBANK |
| bank_code | XBYSTD | 西班牙桑坦德銀行有限公司 |
| bank_code | UNIONBANKOFINDIA | UNIONBANKOFINDIA |
| bank_code | SHSYCX | 上海商業儲蓄銀行股份有限公司 |
| bank_code | INDUSTRIALBANKOFKOREA | INDUSTRIALBANKOFKOREA |
| bank_code | XJPB | 新加坡銀行有限公司 |
| bank_code | SHINHANBANK | SHINHANBANK |
| bank_code | WDSY | 王道商業銀行股份有限公司 |
| bank_code | BNPPARIBASSECURITIESSERVICES | BNPPARIBASSECURITIESSERVICES |
| bank_code | GJKFB | 國家開發銀行 |
| bank_code | FIRSTABUDHABIBANKPJSC | FIRSTABUDHABIBANKPJSC |
| bank_code | SAFRASARASINLTD | BANKJ.SAFRASARASINLTD. |
| bank_code | ABNAMROBANKN | ABNAMROBANKN.V. |
| bank_code | HDFCBANKLIMITED | HDFCBANKLIMITED |
| bank_code | UNIONBANCAIREPRIVEE | UNIONBANCAIREPRIVEE,UBPSA |
| bank_code | SKANDINAVISKAENSKILDABANKENAB | SKANDINAVISKAENSKILDABANKENAB |
| bank_code | BANKJULIUSBAER | BANKJULIUSBAER&CO.LTD. |
| bank_code | CREDITINDUSTRIELETCOMMERCIAL | CREDITINDUSTRIELETCOMMERCIAL |
| bank_code | YWXGSY | 臺灣新光商業銀行股份有限公司 |
| bank_code | ZGYHXG | 中國銀行香港分行 |
| bank_code | SWITZERLAND | CAINDOSUEZ(SWITZERLAND)SA |
| bank_code | ICBCSTANDARDBANKPLC | ICBCSTANDARDBANKPLC |
| bank_code | LGTHJXG | LGT皇家銀行(香港) |
| bank_code | MGLB | 麥格理銀行有限公司 |
| bank_code | SHPDFZ | 上海浦東發展銀行股份有限公司 |
| bank_code | ZGMSB | 中國民生銀行股份有限公司 |
| bank_code | PICTET&CIE | PICTET&CIE(EUROPE)S.A. |
| bank_code | GFB | 廣發銀行股份有限公司 |
| bank_code | BOHB | 渤海銀行股份有限公司 |
| bank_code | ZGGD | 中國光大銀行股份有限公司 |
| bank_code | SJZYXT | 三井住友信託銀行 |
| bank_code | SHXGB | 上海銀行(香港)有限公司 |
| bank_code | CIMBBANKBERHAD | CIMBBANKBERHAD |
| bank_code | XINYEB | 興業銀行股份有限公司 |
| bank_code | YDSY | 元大商業銀行股份有限公司 |
| bank_code | MASHREQBANK | MASHREQBANK-PUBLICSHAREHOLDINGCOMPANY |
| bank_code | KOOKMINBANK | KOOKMINBANK |
| bank_code | JTXG | 交通銀行(香港)有限公司 |
| bank_code | ZSYHB | 浙商銀行股份有限公司 |
| bank_code | MGSDL | 摩根士丹利銀行亞洲有限公司 |
| bank_code | PINANB | 平安銀行股份有限公司 |
| bank_code | HUAXIA | 華夏銀行股份有限公司 |
| bank_code | ZANB | 眾安銀行有限公司 |
| bank_code | LIVIVBLIMITED | LIVIVBLIMITED |
| bank_code | MOXBANKLIMITED | MOXBANKLIMITED |
| bank_code | WELABBANKLIMITED | WELABBANKLIMITED |
| bank_code | FRB | 富融銀行有限公司 |
| bank_code | PAYZHT | 平安壹賬通銀行(香港)有限公司 |
| bank_code | MYXG | 螞蟻銀行(香港)有限公司 |
| bank_code | QATARNATIONALBANK | QATARNATIONALBANK(Q.P.S.C.) |
| bank_code | TXB | 天星銀行有限公司 |
| bank_code | HONGKONGSECURITIESCLEARINGCOMPANYLIMITED | HONGKONGSECURITIESCLEARINGCOMPANYLIMITED |
| bank_code | CLSBANKINTERNATIONAL | CLSBANKINTERNATIONAL |
| bank_code | BANQUE | BANQUE PICTET & CIE SA |
| bank_code | DGB | 東莞銀行股份有限公司 |
| bank_code | NXB | 農協銀行 |
| bank_code | WECHAT | WeChat Pay Hong Kong Limited |
| bank_code | ALIPAY | Alipay Financial Services(HK) Limited |
| bank_code | BDTK | 八達通卡有限公司 |
| bank_code | LHB | 388 LIVI BANK LIMITED |

# 13. Error Codes

| Status Code  | Description                |
|------|-------------------|
| 200  | Success                |
| 1000 | Internal error              |
| 1001 | IP is not in the merchant IP whitelist       |
| 1002 | Parameter error              |
| 1003 | Signature error              |
| 1004 | This API is not enabled for the current merchant (contact operations to verify: merchant or App does not exist / is disabled / payment product is not configured)   |
| 1005 | Merchant does not exist             |
| 1006 | Current user IP is blacklisted       |
| 1007 | Current user is blacklisted         |
| 1008 | Merchant App does not exist          |
| 1009 | Payment product does not exist           |
| 1010 | Payment channel does not exist           |
| 1011 | Payment channel development is not completed yet and is temporarily unavailable  |
| 1012 | Payment channel exception, please try again later      |
| 1013 | The current order volume is too high, please try again later      |
| 1014 | Duplicate order number             |
| 1015 | Insufficient app balance           |
| 1016 | The same user is placing orders too frequently, please try again later    |
| 1017 | Order record does not exist           |
| 1018 | Current amount is not supported           |
| 1019 | Payment collection is not enabled in the current app's country |
| 1020 | Pay-out is not enabled in the current app's country |
| 1021 | Failure                |
|1036|API not open|
|1037|Currency not supported|
|1038|Abnormal UTR returned in pay-in callback|
| 9999 | Other error              |
|3000|System under upgrade and maintenance, order placement is temporarily suspended, please try again later|

# 14. Pay-in Cashier API

URL: `https://{api_domain}/api/v1/cashApi/CashIn.html`
Request method: `GET`

### Parameters:

| Name           | Type     | Required    | Description                        |
|--------------|--------|-------|---------------------------|
| app_id       | string | true  | Merchant app_id                    |
| order_no       | string | true  | Merchant order number                     |
| amount       | string | true  | Merchant amount, unit: Hong Kong Dollar (HKD)                     |
| notice_url       | string | false | Asynchronous notification URL                     |
| pay_code       | int    | true | Product code                     |

#### Example

```
https://{api_domain}/api/v1/cashApi/CashIn.html?app_id={{app_id}}&order_no={{merchant_order_no}}&amount={{merchant_amount}}&notice_url={{async_notification_url}}&pay_code={{product_code}}
```
---
# 15. Document Update Time
```
2026-08-21 00:00:00
```
