# 1. Integration Process

> 1. Business negotiation and account registration, discuss the related rates.
>
> 2. Contact the operations team to create the merchant number, secret key, merchant appId, product code, and apiUrl.
>
> 3. After development is completed, both parties conduct integration testing to verify that requests, callbacks, and related information are complete and correct.

# 2. MD5 Signature Algorithm

> 1. Sort all parameters in ascending order by key in the format of key-value pairs (key1=value1). Parameters with empty values do not participate in the signature.
>
> 2. Combine parameters in the format:
     >    key1=value1&key2=value2
>
> 3. Append the merchant secret key:
     >    key1=value1&key2=value2...&key=MerchantSecretKey
>
> 4. sign=md5(the assembled string from the previous step)
     >    The signature result must be a 32-character lowercase string.
>
> 5. The signature key can be viewed in Merchant Dashboard -> Basic Information, or obtained from our customer service.

# 3. Notes

## 3.1 API Related

> 1. All APIs in this document use the standard HTTP communication protocol with POST requests. Both request and response Content-Type are application/json, and the character encoding is uniformly UTF-8.
>
> 2. The amount unit is cents.
>
> 3. The requesting IP must be added to the whitelist.
>
> 4. user_ip should collect the user's real IP whenever possible. If unavailable, leave it empty. Do not use local IPs such as 127.0.0.1.

## 3.2 Callback Related

> 1. After successfully processing the callback, please return the plain text success without any additional characters. Otherwise, the system will continue pushing the order notification multiple times.
>
> 2. During asynchronous notification interaction, if the returned response is not success, the notification will be considered failed, and the system will retry periodically according to the following schedule:
     >    1m, 1m, 4m, 10m, 10m, 1h, 2h, 6h, 15h.
>
> 3. If pay_notice_url is empty, it will be considered that the merchant does not require callbacks, and the system will not push notifications.

# 4. Collection Order API

(The request IP must be whitelisted by contacting us)
Order URL: https://{api_domain}/api/v1/payApi/CreatePayInOrder

## 4.1 Collection - Request Parameters

| Name           | Type   | Required | Description                                                              |
| -------------- | ------ | -------- | ------------------------------------------------------------------------ |
| trade_no       | int    | true     | Merchant number                                                          |
| app_id         | int    | true     | Merchant appId                                                           |
| pay_code       | int    | true     | Product code, contact our operations team to obtain                      |
| pay_method     | string | true     | Payment method VND-Payment                                               |
| price          | int    | true     | Order amount, unit: cents, integer                                       |
| order_no       | string | true     | Merchant order number                                                    |
| success_url    | string | false    | Redirect URL after successful payment                                    |
| fail_url       | string | false    | Redirect URL after failed payment                                        |
| pay_notice_url | string | false    | Payment success callback URL                                             |
| user_id        | string | true     | System user ID                                                           |
| user_ip        | string | true     | Payer IP                                                                 |
| attach         | string | true     | Additional parameter JSON string, payer information                      |
| sign           | string | true     | Signature result, signature method described at the top of this document |
| timestamp      | string | false    | Order timestamp, 10-digit Unix timestamp in seconds                      |

* Collection - attach Additional Parameter Fields

| Name         | Type   | Required | Description                              |
| ------------ | ------ | -------- | ---------------------------------------- |
| name         | string | false    | Payer name                               |
| email        | string | false    | Payer email                              |
| phone        | string | false    | Payer phone number                       |
| account_no   | string | true     | Payment account                          |
| account_type | string | true     | Account type: PHONE, BANK (bank account) |
| bank_code    | string | false    | Bank code                                |
| bank_name    | string | false    | Bank name                                |

* Collection - Request Example

```json
{
  "trade_no": 10003,
  "order_no": "p7158412025RAprmNz7lR",
  "app_id": 10002,
  "pay_code": 0,
  "price": 10099,
  "pay_notice_url": "http://host/api/v1/mer/cbtest",
  "attach": "{\"name\":\"张三\",\"email\":\"zhangsan@example.com\",\"phone\":\"09123456789\",\"account_no\":\"1234567890\",\"account_type\":\"PHONE\",\"bank_code\":\"123456\",\"bank_name\":\"中国银行\"}",
  "sign": "3d6dea05a7c08564911b9922e16455c2",
  "user_ip": "87.200.59.100",
  "success_url": "",
  "fail_url": "",
  "user_id": "2677343"
}
```

## 4.2 Collection - Response Parameters

| Name         | Type   | Required | Description                                                                                                             |
| ------------ | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------- |
| code         | int    | true     | 200: Order created successfully, others: failed                                                                         |
| msg          | string | true     | Failure reason                                                                                                          |
| pay_url      | string | false    | Payment link                                                                                                            |
| qr_code      | string | false    | PIX QR code string                                                                                                      |
| order_no     | string | true     | Merchant order number                                                                                                   |
| dis_order_no | string | true     | Platform order number                                                                                                   |
| create_time  | int    | true     | Creation time                                                                                                           |
| pay_info     | string | false    | Payment information JSON string, such as receiving/payment original information, card number, name, bank, etc. 25-10-28 |
| sign         | string | true     | Signature result, signature method described at the top of this document                                                |

* Collection - Response Example

Failure:

```json
{
  "code": 1005,
  "msg": "Merchant not found",
  "sign": ""
}
```

Success:

```json
{
  "code": 200,
  "msg": "",
  "sign": "b449b4b6907204a683ec6c50bff92b01",
  "order_no": "p7158412025J2dZjXLmz0",
  "dis_order_no": "2025071130770572062498816india1oushe",
  "create_time": 1752825512,
  "pay_url": "https://api.sunpayinr.net/checkout/scanqr/943543da169d4757a40bfa49b3eb83b5"
}
```

# 5. Collection Callback Notification post/json

Push URL: Callback IP of the pay_notice_url passed by the merchant: call_back_server_ip. Please add our callback IP to your whitelist.

## 5.1 Collection Callback - Request Parameters

| Name         | Type   | Required | Description                                                                                                                                                                                                                                                                                                      |
| ------------ | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| trade_no     | int    | true     | Merchant number                                                                                                                                                                                                                                                                                                  |
| status       | int    | true     | Order status, 2: Success, 3: Failed                                                                                                                                                                                                                                                                              |
| order_no     | string | true     | Merchant order number                                                                                                                                                                                                                                                                                            |
| dis_order_no | string | true     | Platform order number                                                                                                                                                                                                                                                                                            |
| order_price  | int    | true     | Order amount, unit: cents                                                                                                                                                                                                                                                                                        |
| real_price   | int    | true     | Actual amount paid by the user, unit: cents                                                                                                                                                                                                                                                                      |
| nti_time     | int    | false    | Notification initiation time                                                                                                                                                                                                                                                                                     |
| payer        | string | false    | JSON string of payer information {"name":"Name","account":"Account","bank":"Payer bank code","utr2":"Bank transaction number","email":"Email","phone":"Phone","identify_type":"Document type","identify_num":"CPF,CNPJ"}, besides the example fields, payer-related fields passed in attach may also be included |
| pay_info     | string | false    | Payment information JSON string, such as receiving/payment original information, card number, name, bank, etc. 25-10-28                                                                                                                                                                                          |
| create_time  | int    | true     | Creation time                                                                                                                                                                                                                                                                                                    |
| sign         | string | true     | Signature result, signature method described at the top of this document                                                                                                                                                                                                                                         |

* Collection Callback - Request Example

```json
{
  "trade_no": 10003,
  "status": 3,
  "order_no": "p71584120256SlWlKkymb",
  "dis_order_no": "2025071130460153942908928india1sKQbX",
  "order_price": 10099,
  "real_price": 10000,
  "payer": "{\"name\":\"姓名\",\"email\":\"邮箱\",\"phone\":\"手机号\",\"identify_type\":\"证件类型\",\"identify_num\":\"CPF,CNPJ\"}",
  "nti_time": 1752826164,
  "create_time": 1752751502,
  "sign": "eba7f27e0f49581d8784294ef29f994d"
}
```

## 5.2 Collection Callback - Response Description

After successfully processing the callback, please return success. The system will stop retrying the notification.

# 6. Payout Order API

(The request IP must be whitelisted by contacting us)
Order URL: https://{api_domain}/api/v1/payApi/CreatePayOutOrder

## 6.1 Payout - Request Parameters

| Name           | Type   | Required | Description                                                                                     |
| -------------- | ------ | -------- | ----------------------------------------------------------------------------------------------- |
| trade_no       | int    | true     | Merchant number                                                                                 |
| order_no       | string | true     | Merchant order number                                                                           |
| app_id         | int    | true     | Merchant appId                                                                                  |
| pay_code       | int    | true     | Product code, contact our operations team to obtain                                             |
| price          | int    | true     | Order amount, unit: cents, integer. After conversion to currency unit, decimals are not allowed |
| account_no     | string | true     | Receiving account                                                                               |
| account_type   | string | true     | Account type: PHONE, BANK (bank account)                                                        |
| account_name   | string | true     | Recipient name                                                                                  |
| bank_code      | string | true     | Receiving bank code, refer to bank code list                                                    |
| pay_notice_url | string | false    | Payout success callback URL                                                                     |
| attach         | string | false    | Additional parameters {"email":"Email","phone":"Phone number","bank_name":"Bank name"}          |
| user_ip        | string | true     | Recipient user IP                                                                               |
| sign           | string | true     | Signature result, signature method described at the top of this document                        |
| timestamp      | string | false    | Order timestamp, 10-digit Unix timestamp in seconds                                             |

* Payout - Request Example

```json
{
  "trade_no": 10003,
  "order_no": "p7158412025MsJydJqT7b",
  "app_id": 10002,
  "pay_code": 1,
  "price": 10001,
  "pay_notice_url": "http://host/api/v1/mer/cbtest",
  "attach": "",
  "sign": "12f74d71fa929087af79b5083567c453",
  "user_ip": "87.200.59.100",
  "account_type": "PHONE",
  "account_no": "123456789",
  "account_name": "test",
  "bank_code": "PKREAYPAISA",
  "identify_type": "",
  "identify_num": ""
}
```

## 6.2 Payout - Response Parameters

| Name         | Type   | Required | Description                                                              |
| ------------ | ------ | -------- | ------------------------------------------------------------------------ |
| code         | int    | true     | 200: Order created successfully, others: failed                          |
| msg          | string | true     | Failure reason                                                           |
| dis_order_no | string | true     | Platform order number                                                    |
| order_no     | string | true     | Merchant order number                                                    |
| status       | int    | true     | Order status: 2.Success, 3.Failed, 7.Rejected, 9.Reversed, 10.Processing |
| create_time  | int    | true     | Creation time                                                            |
| sign         | string | true     | Signature result, signature method described at the top of this document |

* Payout - Response Example

Failure:

```json
{
  "code": 1005,
  "msg": "Merchant not found",
  "sign": ""
}
```

Success:

```json
{
  "code": 200,
  "msg": "",
  "sign": "d3ec1fa0f45bc44218d5fb63bb1beb61",
  "order_no": "p7158412025MsJydJqT7b",
  "dis_order_no": "2025071130776296733810688india1Dhr7H",
  "create_time": 1752826877,
  "status": 10
}
```

# 7. Payout Callback Notification

Push URL: Callback IP of the pay_notice_url passed by the merchant: call_back_server_ip. Please add our callback IP to your whitelist.

## 7.1 Payout Callback - Request Parameters

| Name         | Type   | Required | Description                                                                                                             |
| ------------ | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------- |
| trade_no     | int    | true     | Merchant number                                                                                                         |
| order_no     | string | true     | Merchant order number                                                                                                   |
| dis_order_no | string | true     | Platform order number                                                                                                   |
| order_price  | int    | true     | Order amount, unit: cents                                                                                               |
| fee          | int    | false    | Order handling fee, unit: cents                                                                                         |
| status       | int    | true     | Order status: 2.Success, 3.Failed, 7.Rejected, 9.Reversed                                                               |
| pay_info     | string | false    | Payment information JSON string, such as receiving/payment original information, card number, name, bank, etc. 25-10-28 |
| remark       | string | false    | Failure reason                                                                                                          |
| create_time  | int    | true     | Creation time                                                                                                           |
| sign         | string | true     | Signature result, signature method described at the top of this document                                                |
| nti_time     | int    | true     | Notification initiation time                                                                                            |

* Payout Callback - Request Example

```json
{
  "trade_no": 10003,
  "status": 3,
  "order_price": 10000,
  "order_no": "p71584120257igU8n8FII",
  "dis_order_no": "2025071130700746140950528india15rLVI",
  "nti_time": 1752808888,
  "create_time": 1752808865,
  "sign": "746140950528indi"
}
```

## 7.2 Payout Callback - Response Description

After successfully processing the callback, please return success. The system will stop retrying the notification.

# 8. Order Query API (Shared by Collection and Payout)

(The request IP must be whitelisted by contacting us)
Query URL: https://{api_domain}/api/v1/payApi/QueryOrder

## 8.1 Query Request Parameters

| Name         | Type   | Required | Description                                                              |
| ------------ | ------ | -------- | ------------------------------------------------------------------------ |
| order_type   | string | true     | pay_out: payout, pay_in: collection                                      |
| trade_no     | int    | true     | Merchant number                                                          |
| app_id       | int    | true     | Merchant appId                                                           |
| dis_order_no | string | false    | Platform order number                                                    |
| order_no     | string | false    | Merchant order number                                                    |
| sign         | string | true     | Signature result, signature method described at the top of this document |

* Query Request Example

```json
{
  "order_type": "pay_in",
  "trade_no": 165,
  "app_id": 165,
  "dis_order_no": "p7158277185f96603047656571",
  "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```

## 8.2 Query Response Parameters

| Name         | Type   | Required | Description                                                                                                                                                                                   |
| ------------ | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| code         | int    | true     | 200: Query successful, others: failed                                                                                                                                                         |
| msg          | string | true     | Failure reason                                                                                                                                                                                |
| trade_no     | int    | true     | Merchant number                                                                                                                                                                               |
| real_price   | int    | true     | Actual payment amount, unit: cents                                                                                                                                                            |
| status       | int    | true     | Order status: 1.Unpaid, 2.Success, 3.Failed, 7.Rejected, 9.Reversed, 10.Processing                                                                                                            |
| success_time | int    | true     | Success timestamp                                                                                                                                                                             |
| order_no     | string | true     | Merchant order number                                                                                                                                                                         |
| dis_order_no | string | true     | Platform order number                                                                                                                                                                         |
| remark       | string | true     | Payout failure reason                                                                                                                                                                         |
| fee          | int    | false    | Order handling fee, unit: cents                                                                                                                                                               |
| create_time  | int    | true     | Creation time                                                                                                                                                                                 |
| payer        | string | false    | JSON string of payer information {"account_name":"Name","account_type":"Account type: CPF,CNPJ,EMAIL,PHONE","account_no":"Account","identify_type":"Document type","identify_num":"CPF,CNPJ"} |
| pay_info     | string | false    | Payment information JSON string, such as receiving/payment original information, card number, name, bank, etc. 25-10-28                                                                       |
| sign         | string | true     | Signature result, signature method described at the top of this document                                                                                                                      |
| utr2         | string | false    | Bank order number                                                                                                                                                                             |

* Query Response Example

Failure:

```json
{
  "code": 1017,
  "msg": "Order not found"
}
```

Success:

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
  "payer": "{\"name\":\"姓名\",\"email\":\"邮箱\",\"phone\":\"手机号\",\"identify_type\":\"证件类型\",\"identify_num\":\"CPF,CNPJ\"}",
  "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```

# 9. Payout Balance Query API

(The request IP must be whitelisted by contacting us)
URL: https://{api_domain}/api/v1/payApi/QueryBalance

## 9.1 Balance Query Request Parameters

| Name     | Type   | Required | Description                                                              |
| -------- | ------ | -------- | ------------------------------------------------------------------------ |
| trade_no | int    | true     | Merchant number                                                          |
| app_id   | int    | true     | Merchant appId                                                           |
| sign     | string | true     | Signature result, signature method described at the top of this document |

* Balance Query Request Example

```json
{
  "trade_no": 165,
  "app_id": 281,
  "sign": "db3406277185f9660b3b928d6adc115"
}
```

## 9.2 Balance Query Response Parameters

| Name           | Type   | Required | Description                                                              |
| -------------- | ------ | -------- | ------------------------------------------------------------------------ |
| code           | int    | true     | 200: Query successful, others: failed                                    |
| msg            | string | true     | Failure reason                                                           |
| balance        | int    | true     | Balance, unit: cents                                                     |
| balance_frozen | int    | false    | Frozen balance, unit: cents                                              |
| sign           | string | true     | Signature result, signature method described at the top of this document |

* Balance Query Response Example

Failure:

```json
{
  "code": 10001,
  "msg": "Merchant not found"
}
```

Success:

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

(The request IP must be whitelisted by contacting us)
URL: https://{api_domain}/api/v1/payApi/QueryCertificate

## 10.1 Payment Voucher Request Parameters

| Name         | Type   | Required | Description                                                              |
| ------------ | ------ | -------- | ------------------------------------------------------------------------ |
| trade_no     | int    | true     | Merchant number                                                          |
| app_id       | int    | true     | Merchant appId                                                           |
| order_no     | string | false    | Merchant order number, choose one between order_no and dis_order_no      |
| dis_order_no | string | false    | Platform order number, choose one between dis_order_no and order_no      |
| sign         | string | true     | Signature result, signature method described at the top of this document |

* Payment Voucher Request Example

```json
{
    "trade_no": 10003,
    "app_id": 10003,
    "order_no": "",
    "dis_order_no": "35011C02gljuf6k0800india1lVY",
    "sign": "3969f17cd1a551769f85967d0a05b7b6"
}
```

## 10.2 Payment Voucher Response Parameters

| Name     | Type   | Required | Description                                                              |
| -------- | ------ | -------- | ------------------------------------------------------------------------ |
| code     | int    | true     | 200: Success, others: failed                                             |
| msg      | string | true     | Failure reason                                                           |
| img_link | string | false    | Voucher image link                                                       |
| img_base | string | false    | Base64 encoded voucher image                                             |
| sign     | string | true     | Signature result, signature method described at the top of this document |

* Payment Voucher Response Example

No payment voucher available:

```json
{
  "code":200,
  "msg":"No payment voucher available at the moment",
  "sign": "",
  "img_link": "",
  "img_base": ""
}
```

Payment voucher available:

```json
{
  "code": 200,
  "msg": "",
  "sign": "3969f17cd1a551769f85967d0a05b7b6",
  "img_link": "http://dsggfgdsf.djdj?ddd=snn",
  "img_base": "data:image/png;base64,hfhshdhfhfh"
}
```

# 11. Bank Codes

| Field Name | Code       | Bank Name                                              |
| :--------- | :--------- | :----------------------------------------------------- |
| bank_code  | PVCB       | Vietnam Public Joint Stock Commercial Bank             |
| bank_code  | VPB        | Vietnam Prosperity Bank                                |
| bank_code  | VCB        | Bank for Foreign Trade of Vietnam                      |
| bank_code  | CTG        | Vietnam Bank for Industry and Trade                    |
| bank_code  | BIDV       | Bank for Investment & Development of Vietnam           |
| bank_code  | EIB        | Vietnam Export Import Commercial Joint Stock Bank      |
| bank_code  | TCB        | Vietnam Technological And Commercial Joint Stock Bank  |
| bank_code  | TPB        | Tien Phong Commercial Joint Stock Bank                 |
| bank_code  | LPB        | Viet Nam Post Joint Stock Commercial Bank              |
| bank_code  | PGB        | Petrolimex Group Commercial Joint Stock Bank           |
| bank_code  | SEAB       | Southeast Asia Commercial Joint Stock Bank             |
| bank_code  | SGB        | Saigon Bank For Industry And Trade                     |
| bank_code  | VIB        | Vietnam International Commercial Joint Stock Bank      |
| bank_code  | MBV        | Modern Bank of Vietnam                                 |
| bank_code  | HDB        | HoChiMinh City Development Joint Stock Commercial Bank |
| bank_code  | GPB        | Global Petro Bank                                      |
| bank_code  | BVB        | Baoviet Joint Stock Commercial Bank                    |
| bank_code  | VRB        | Vietnam - Russia Joint Venture Bank                    |
| bank_code  | VNDSHINHAN | SHINHAN Bank                                           |
| bank_code  | WOORI      | WOORI BANK                                             |
| bank_code  | MSB        | Vietnam Maritime Commercial Joint Stock Bank           |
| bank_code  | STB        | Saigon Thuong Tin Commercial Joint Stock Bank          |
| bank_code  | NASB       | North Asia Commercial Joint Stock Bank                 |
| bank_code  | VAB        | Vietnam Asia Commercial Joint Stock Bank               |
| bank_code  | ABB        | An Binh Commercial Joint Stock Bank                    |
| bank_code  | ACB        | Asia Commercial Bank                                   |
| bank_code  | AGRIBANK   | Vietnam Bank For Agriculture and Rural Development     |
| bank_code  | MBB        | Military Commercial Joint Stock Bank                   |
| bank_code  | OCB        | Orient Commercial Joint Stock Bank                     |
| bank_code  | SHB        | Saigon – Hanoi Commercial Joint Stock Bank             |
| bank_code  | NAB        | Nam A Commercial Joint Stock Bank                      |
| bank_code  | SCB        | Saigon Commercial Bank                                 |
| bank_code  | KLB        | Kien Long Commercial Joint Stock Bank                  |
| bank_code  | VTTB       | Viet Nam Thuong Tin Commercial Joint Stock Bank        |
| bank_code  | VCB_CAP    | Viet Capital Bank                                      |
| bank_code  | PBVN       | Public Bank Vietnam Limited                            |
| bank_code  | IVB        | Indovina Bank LTD                                      |
| bank_code  | UOB        | United Overseas Bank                                   |
| bank_code  | VIKKI      | Vikki Digital Bank Limited                             |
| bank_code  | NCB        | National Citizen Bank                                  |
| bank_code  | VIETCREDIT | Tin Viet Finance Joint Stock Company                   |
| bank_code  | CIMB       | CIMB One Member Limited Liability Company              |
| bank_code  | VNDDBS     | DBS Bank (Ho Chi Minh City)                            |
| bank_code  | UMEE       | UMEE by Kienlongbank                                   |
| bank_code  | NONGHYUP   | NongHyup Bank Hanoi Branch                             |
| bank_code  | LIO        | Liobank by OCB                                         |
| bank_code  | VNDHSBC    | HSBC Vietnam                                           |
| bank_code  | KB         | KB Kookmin Bank Ha Noi Branch                          |
| bank_code  | TIMO       | Timo by Viet Capital Bank                              |
| bank_code  | VNPT       | VNPT Fintech                                           |
| bank_code  | MIRAE      | Mirae Asset Finance Company (Vietnam)                  |
| bank_code  | CAKE       | Cake by VP Bank                                        |
| bank_code  | VIETTELPAY | Viettel Digital Services Corporation                   |
| bank_code  | UBANK      | Ubank by VPBank                                        |
| bank_code  | VBSP       | Vietnam bank for social policies                       |
| bank_code  | VNDKBANK   | Kasikornbank Bank                                      |
| bank_code  | HLB        | Hong Leong Bank Vietnam Limited                        |
| bank_code  | DAB        | DongA Bank                                             |
| bank_code  | COOP       | Vietnam Cooperative Bank                               |

# 12. Error Codes

| Status Code | Description                                                                                                                                     |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 200         | Success                                                                                                                                         |
| 1000        | Internal error                                                                                                                                  |
| 1001        | IP not in merchant whitelist                                                                                                                    |
| 1002        | Parameter error                                                                                                                                 |
| 1003        | Signature error                                                                                                                                 |
| 1004        | API not enabled for current merchant (contact operations to verify: merchant or App does not exist / disabled / payment product not configured) |
| 1005        | Merchant does not exist                                                                                                                         |
| 1006        | Current user IP is blacklisted                                                                                                                  |
| 1007        | Current user is blacklisted                                                                                                                     |
| 1008        | Merchant App does not exist                                                                                                                     |
| 1009        | Payment product does not exist                                                                                                                  |
| 1010        | Payment channel does not exist                                                                                                                  |
| 1011        | Payment channel is under development and temporarily unavailable                                                                                |
| 1012        | Payment channel exception, please try again later                                                                                               |
| 1013        | Current order volume is too high, please try again later                                                                                        |
| 1014        | Duplicate order number                                                                                                                          |
| 1015        | Insufficient app balance                                                                                                                        |
| 1016        | Frequent orders from the same user, please try again later                                                                                      |
| 1017        | Order record does not exist                                                                                                                     |
| 1018        | Unsupported amount                                                                                                                              |
| 1019        | Payment collection is not enabled in the current app country                                                                                    |
| 1020        | Payout is not enabled in the current app country                                                                                                |
| 1021        | Failed                                                                                                                                          |
| 1036        | API not open                                                                                                                                    |
| 1037        | Unsupported currency                                                                                                                            |
| 1038        | Collection callback UTR exception                                                                                                               |
| 9999        | Other errors                                                                                                                                    |
| 3000        | System under maintenance, ordering suspended, please try again later                                                                            |

# 13. Collection Checkout API

URL: https://{api_domain}/api/v1/cashApi/CashIn.html
Request Method: GET

### Parameters

| Name       | Type   | Required | Description                        |
| ---------- | ------ | -------- | ---------------------------------- |
| app_id     | string | true     | Merchant app_id                    |
| order_no   | string | true     | Merchant order number              |
| amount     | string | true     | Merchant amount in Vietnamese Dong |
| notice_url | string | false    | Asynchronous callback URL          |
| pay_code   | int    | true     | Product code                       |

#### Example

```text
https://{api_domain}/api/v1/cashApi/CashIn.html?app_id={{app_id}}&order_no={{MerchantOrderNo}}&amount={{MerchantAmount}}&notice_url={{CallbackURL}}&pay_code={{ProductCode}}
```

# 14. Document Update Time

```text
2026-05-10 19:25:00
```
