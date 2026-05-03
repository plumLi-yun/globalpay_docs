# 1. Integration Process

> 1. Business negotiation for account opening and communication regarding relevant rates.
> 
> 2. Contact operations to create Merchant ID, Secret Key, Merchant AppId, Product Code, and apiUrl.
> 
> 3. Upon completion of development, both parties conduct joint debugging and testing to verify the integrity of requests, reporting, and other information.

# 2. Md5 Signature Algorithm

> 1. Sort all parameters in ascending order as key-value pairs (key1=value1) (empty parameter values are not included in the signature).
> 
> 2. Combine them in the format key1=value1&key2=value2.
> 
> 3. Append the merchant secret key: key1=value1&key2=value2...&key=MerchantSecretKey.
> 
> 4. sign=md5(the string assembled in the previous step). The signature result is a 32-bit lowercase string.
> 
> 5. The signature key can be found in the Merchant Backend -> Basic Information, or by inquiring with our customer service.

# 3. Precautions

## 3.1 Interface Related

> 1. All interfaces in this document use standard HTTP communication protocols, submitted via POST. Both request and response Content-type are application/json, and the character encoding is unified as UTF-8.
> 
> 2. The currency unit is Xu.
> 
> 3. The IP address for requesting the interface needs to be whitelisted.
> 
> 4. Collect the real user IP for user_ip as much as possible; if truly unavailable, leave it blank. Do not use local IPs like 127.0.0.1.

## 3.2 Callback Related

> 1. The callback reception was successful. Please return the text "success". This text must not contain any other characters. Otherwise, the system will no longer push this order information; otherwise, it will push it multiple times.
> 
> 2. During asynchronous notification interaction, if the received response is not `success`, it is considered a notification failure, and notifications will be re-initiated periodically based on a certain strategy. The notification intervals are: 1m, 1m, 4m, 10m, 10m, 1h, 2h, 6h, 15h.
> 
> 3. If the pay_notice_url notification address is empty, it will be considered that the merchant does not need a callback, and the system will not push a notification.

# 4. Pay-in (Collection) Order Interface

(The order placement IP needs to be whitelisted by contacting us)
Order address: {api_domain}/api/v1/payApi/CreatePayInOrder
Example: https://{api_domain}/api/v1/payApi/CreatePayInOrder

## 4.1 Pay-in - Order Request Parameters

| Name      | Type  | Required | Description                                                                                                                              |
| -------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| trade_no    | int  | true   | Merchant ID.                                                                                                                             |
| app_id     | int  | true   | Merchant appId.                                                                                                                            |
| pay_code    | int  | true   | Product code, obtained from our operations.                                                                                                              |
| pay_method   | string | true   | Payment method: VND-Payment.                                                                                                                     |
| price     | int  | true   | Order amount, unit: Xu, integer.                                                                                                                  |
| order_no    | string | true   | Merchant order number.                                                                                                                        |
| success_url  | string | false  | Redirect URL for successful payment.                                                                                                                 |
| fail_url    | string | false  | Redirect URL for failed payment.                                                                                                                   |
| pay_notice_url | string | false  | Notification URL for successful payment.                                                                                                               |
| user_id    | string | true   | System user ID.                                                                                                                            |
| user_ip    | string | true   | Payer IP address.                                                                                                                           |
| attach     | string | true   | Additional parameters in JSON string format: {"account_no":"","account_type":"","name":"Name","email":"Email","phone":"Phone","identify_type":"Identity Type","identify_num":"CPF,CNPJ,IFSC,BANK_CODE"} (Recommended for Brazil, Pakistan). |
| sign      | string | true   | Signature result, see the top of the document for the signature method.                                                                                                |
| timestamp   | string | false  | Order timestamp (10-digit timestamp in seconds).                                                                                                           |

- Pay-in - attach additional parameter field description

 | Name     | Type  | Required | Description                                                               |
  | ------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
 | name     | string | false  | Payer name. (Recommended, mandatory for Pakistan). For Brazil individuals, provide individual name; for Brazil companies, company name. |
 | email     | string | false  | Payer email. (Recommended, mandatory for Pakistan).                                           |
 | phone     | string | false  | Payer phone. (Mandatory for Pakistan, must be 11 digits starting with 03).                               |
 | identify_type | string | false  | Identity type: CPF, CNPJ, IFSC.                                                     |
 | identify_num | string | false  | Identity number. Brazil: CPF (digits), CNPJ (digits). India: IFSC.                                   |
 | account_no  | string | true   | Payment account number.                                                         |
 | account_type | string | true   | Account type: CPF, CNPJ, EMAIL, PHONE, UPI (India UPI), BANK (Bank Account).                              |
 | bank_code   | string | false  | Bank code (Mandatory for Thailand).                                                   |
 | bank_name   | string | false  | Bank name.                                                               |

- Pay-in - Order Request Example

 ```json
 {
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
 }
 ```

## 4.2 Pay-in - Order Response

| Name     | Type  | Required | Description                                            |
| ------------ | ------ | -------- | -------------------------------------------------------------------------------------------------- |
| code     | int  | true   | 200: Success; Others: Failure.                                   |
| msg     | string | true   | Failure reason.                                          |
| pay_url   | string | false  | Payment link.                                           |
| qr_code   | string | false  | PIX QR code string.                                        |
| order_no   | string | true   | Merchant order number.                                       |
| dis_order_no | string | true   | Platform order number.                                       |
| create_time | int  | true   | Creation time.                                           |
| pay_info   | string | false  | Payment information JSON string. e.g., original pay-in/pay-out info, card number, name, bank, etc. |
| sign     | string | true   | Signature result, see the top of the document for the signature method.              |

- Pay-in - Order Response Example

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

# 5. Pay-in Callback Notification (post/json)

Push address: The `pay_notice_url` provided by the merchant during order placement. Callback IP: `call_back_server_ip`. Please add our IP to your callback whitelist.

## 5.1 Pay-in Callback - Request Parameters

| Name     | Type  | Required | Description                                                                                                                              |
| ------------ | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| trade_no   | int  | true   | Merchant ID.                                                                                                                             |
| status    | int  | true   | Order status: 2. Success, 3. Failure.                                                                                                                 |
| order_no   | string | true   | Merchant order number.                                                                                                                        |
| dis_order_no | string | true   | Platform order number.                                                                                                                        |
| order_price | int  | true   | Order amount, unit: Xu.                                                                                                                      |
| real_price  | int  | true   | Actual amount paid by the user, unit: Xu.                                                                                                             |
| nti_time   | int  | false  | Notification initiation time.                                                                                                                     |
| payer    | string | false  | JSON string, payer info: {"name":"Name", "account":"Account", "bank":"User Bank Code", "utr2":"Bank serial number", "email":"Email", "phone":"Phone", "identify_type":"Identity Type", "identify_num":"CPF, CNPJ"}. Also includes payer-related fields from `attach`. |
| pay_info   | string | false  | Payment information JSON string. e.g., original pay-in/pay-out info, card number, name, bank, etc.                                                                                  |
| create_time | int  | true   | Creation time.                                                                                                                            |
| sign     | string | true   | Signature result, see the top of the document for the signature method.                                                                                                |

- Pay-in Callback - Request Parameter Example

```json

{
 "trade_no": 10003,
 "status": 3,
 "order_no": "p71584120256SlWlKkymb",
 "dis_order_no": "2025071130460153942908928india1sKQbX",
 "order_price": 10099,
 "real_price": 10000,
 "payer": "{\"name\":\"Name\",\"email\":\"Email\",\"phone\":\"Phone\",\"identify_type\":\"Identity Type\",\"identify_num\":\"CPF,CNPJ\"}",
 "nti_time": 1752826164,
 "create_time": 1752751502,
 "sign": "eba7f27e0f49581d8784294ef29f994d"
}
```

## 5.2 Pay-in Callback - Response Description

If the callback is successfully received and processed, please return `success`. The system will stop pushing this order information; otherwise, it will be resent multiple times.

# 6. Pay-out (Disbursement) Order Interface

(The order placement IP needs to be whitelisted by contacting us)
Order address: {api_domain}/api/v1/payApi/CreatePayOutOrder
Example: https://{api_domain}/api/v1/payApi/CreatePayOutOrder

## 6.1 Pay-out - Request Parameters

| Name      | Type  | Required | Description                                        |
| -------------- | ------ | -------- | ----------------------------------------------------------------------------------------- |
| trade_no    | int  | true   | Merchant ID.                                       |
| order_no    | string | true   | Merchant order number.                                  |
| app_id     | int  | true   | Merchant appId.                                      |
| pay_code    | int  | true   | Product code, obtained from our operations.                        |
| price     | int  | true   | Order amount, unit: Xu, integer. Cannot have decimal points after converting to Dong. |
| account_no   | string | true   | Receiving account number.                                 |
| account_type  | string | true   | Account type: CPF, CNPJ, EMAIL, PHONE, UPI (India UPI), BANK (Bank Account), CLABE (Mex). |
| account_name  | string | true   | Name.                                           |
| bank_code   | string | true   | Receiving bank code, refer to bank codes.                         |
| identify_type | string | true   | Identity type: Brazil (CPF, CNPJ), Pakistan (CNIC), India (IFSC, BANK_CODE).       |
| identify_num  | string | true   | Identity number.                                     |
| pay_notice_url | string | false  | Notification URL for successful pay-out.                         |
| attach     | string | false  | Additional parameters: {"email":"Email", "phone":"Phone", "bank_name":"Bank Name"}.    |
| user_ip    | string | true   | Receiving user IP address.                                |
| sign      | string | true   | Signature result, see the top of the document for the signature method.          |
| timestamp   | string | false  | Order timestamp (10-digit timestamp in seconds).                     |

- Pay-out - Request Parameter Example

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

## 6.2 Pay-out - Order Response

| Name     | Type  | Required | Description                                  |
| ------------ | ------ | -------- | ----------------------------------------------------------------------------- |
| code     | int  | true   | 200: Success; Others: Failure.                        |
| msg     | string | true   | Failure reason.                                |
| dis_order_no | string | true   | Platform order number.                            |
| order_no   | string | true   | Merchant order number.                            |
| status    | int  | true   | Order status: 2. Success, 3. Failure, 7. Rejected, 9. Reversal, 10. Processing. |
| create_time | int  | true   | Creation time.                                |
| sign     | string | true   | Signature result, see the top of the document for the signature method.    |

- Pay-out - Order Response Example

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

# 7. Pay-out Callback Notification

Push address: The `pay_notice_url` provided by the merchant during order placement. Callback IP: `call_back_server_ip`. Please add our IP to your callback whitelist.

## 7.1 Pay-out Callback Request Parameters

| Name     | Type  | Required | Description                                            |
| ------------ | ------ | -------- | -------------------------------------------------------------------------------------------------- |
| trade_no   | int  | true   | Merchant ID.                                            |
| order_no   | string | true   | Merchant order number.                                       |
| dis_order_no | string | true   | Platform order number.                                       |
| order_price | int  | true   | Order amount, unit: Xu.                                     |
| fee     | int  | false  | Order fee, unit: Xu.                                      |
| status    | int  | true   | Order status: 2. Success, 3. Failure, 7. Rejected, 9. Reversal.                  |
| pay_info   | string | false  | Payment information JSON string. e.g., original pay-in/pay-out info, card number, name, bank, etc. |
| remark    | string | false  | Failure reason.                                          |
| create_time | int  | true   | Creation time.                                           |
| sign     | string | true   | Signature result, see the top of the document for the signature method.              |
| nti_time   | int  | true   | Notification initiation time.                                   |

- Pay-out Callback Request Example

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

## 7.2 Pay-out Callback Response Description

If the callback is successfully received and processed, please return `success`. The system will stop pushing this order information; otherwise, it will be resent multiple times.

# 8. Query Order Interface (Common for Pay-in and Pay-out)

(The (Request IP needs to be whitelisted by contacting us)
Query address: {api_domain}/api/v1/payApi/QueryOrder

## 8.1 Query Request Parameters

| Name     | Type  | Required | Description                               |
| ------------ | ------ | -------- | ----------------------------------------------------------------------- |
| order_type  | string | true   | pay_out: Disbursement, pay_in: Collection.               |
| trade_no   | int  | true   | Merchant ID.                              |
| app_id    | int  | true   | Merchant appId.                             |
| dis_order_no | string | false   | Platform order number.                         |
| order_no | string | false  | Merchant  order number.              |
| sign     | string | true   | Signature result, see the top of the document for the signature method. |

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

| Name     | Type  | Required | Description                                                                                                 |
| ------------ | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| code     | int  | true   | 200: Query successful; Others: Failure.                                                                                   |
| msg     | string | true   | Query failure reason.                                                                                            |
| trade_no   | int  | true   | Merchant ID.                                                                                                 |
| real_price  | int  | true   | Actual amount paid, unit: Xu.                                                                                       |
| status    | int  | true   | Order status: 1. Unpaid, 2. Success, 3. Failure, 7. Rejected, 9. Reversal, 10. Processing.                                                          |
| success_time | int  | true   | Success timestamp.                                                                                              |
| order_no   | string | true   | Merchant order number.                                                                                            |
| dis_order_no | string | true   | Platform order number.                                                                                            |
| remark    | string | true   | Reason for pay-out failure.                                                                                         |
| fee     | int  | false  | Order fee, unit: Xu.                                                                                           |
| create_time | int  | true   | Creation time.                                                                                                |
| payer    | string | false  | JSON string, payer info: {"account_name":"Name", "account_type":"Account Type: CPF, CNPJ, EMAIL, PHONE", "account_no":"Account", "identify_type":"Identity Type", "identify_num":"CPF, CNPJ"}.       |
| pay_info   | string | false  | Payment information JSON string. e.g., original pay-in/pay-out info, card number, name, bank, etc.                                                      |
| sign     | string | true   | Signature result, see the top of the document for the signature method.                                                                   |
| utr2     | string | false  | Bank order number.                                                                                              |

- Query Response Example

Failure:

```json

{
 "code": 1017,
 "msg": "Order does not exist"
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
 "payer": "{\"name\":\"Name\",\"email\":\"Email\",\"phone\":\"Phone\",\"identify_type\":\"Identity Type\",\"identify_num\":\"CPF,CNPJ\"}",
 "sign": "db3406277185f9660b3b928d6adc7bc4"
}
```

# 9. Pay-out Balance Query Interface

(The (Request IP needs to be whitelisted by contacting us)
Address: {api_domain}/api/v1/payApi/QueryBalance

## 9.1 Balance Request Parameters

| Name   | Type  | Required | Description                               |
| -------- | ------ | -------- | ----------------------------------------------------------------------- |
| trade_no | int  | true   | Merchant ID.                              |
| app_id  | int  | true   | Merchant appid.                             |
| sign   | string | true   | Signature result, see the top of the document for the signature method. |

- Balance Request Example

```json

{
 "trade_no": 165,
 "app_id": 281,
 "sign": "db3406277185f9660b3b928d6adc115"
}
```

## 9.2 Balance Response

| Name      | Type  | Required | Description                               |
| -------------- | ------ | -------- | ----------------------------------------------------------------------- |
| code      | int  | true   | 200: Query successful; Others: Failure.                 |
| msg      | string | true   | Failure reason.                             |
| balance    | int  | true   | Balance, unit: Xu.                          |
| balance_frozen | int  | false  | Frozen balance, unit: Xu.                      |
| sign      | string | true   | Signature result, see the top of the document for the signature method. |

- Balance Response Example

Failure:

```json

{
 "code": 10001,
 "msg": "Merchant does not exist"
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

# 10. Payment Voucher Query Interface

(The (Request IP needs to be whitelisted by contacting us)
Address: {api_domain}/api/v1/payApi/QueryCertificate

## 10.1 Payment Voucher Request Parameters

| Name     | Type  | Required | Description                                |
| ------------ | ------ | -------- | ------------------------------------------------------------------------- |
| trade_no   | int  | true   | Merchant ID.                               |
| app_id    | int  | true   | Merchant appid.                              |
| order_no   | string | false  | Merchant order number (choose either this or dis_order_no).        |
| dis_order_no | string | false  | Platform order number (choose either this or order_no).          |
| sign     | string | true   | Signature result, see the top of the document for the signature method. |

- Payment Voucher Request Example

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

| Name   | Type  | Required | Description                               |
| -------- | ------ | -------- | ----------------------------------------------------------------------- |
| code   | int  | true   | 200: Response successful; Others: Failure.               |
| msg   | string | true   | Failure reason.                             |
| img_link | string | false  | Voucher link.                              |
| img_base | string | false  | Base64 code generated for the voucher.                 |
| sign   | string | true   | Signature result, see the top of the document for the signature method. |

- Payment Voucher Response Example
 No payment voucher:

```json

{
 "code":200,
 "msg":"No payment voucher available at the moment",
 "sign": "",
 "img_link": "",
 "img_base": ""
}
```



With payment voucher:

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

| Field Name | Code | Bank Name |
| :-------- | :----------- | :----------------------------------------------------------------------------------- |
| bank_code | SHINHANYND   | NHShinhan(ShinhanBank)                                                               |
| bank_code | KBankYNDA    | Ngân hàng Đại chúng TNHH Kasikornbank                                                |
| bank_code | HSBCYND      | Ngân hàng TNHH MTV HSBC (Việt Nam)                                                   |
| bank_code | DBSYND       | DBS Bank Ltd - Chi nhánh Thành phố Hồ Chí Minh                                       |
| bank_code | CITIBANKYND  | Ngân hàng Citibank, N.A. - Chi nhánh Hà Nội                                          |
| bank_code | ANZYDD       | Ngân hàng TNHH MTV ANZ (Việt Nam)                                                    |
| bank_code | NKCHCM       | Ngân hàng Kookmin CN Ho Chi Minh                                                     |
| bank_code | NHB HN       | Ngân hàng Nonghyup - Chi nhánh Hà Nội                                                |
| bank_code | IBK - HCM    | Ngân hàng Công nghiệp Hàn Quốc - Chi nhánh TP.Hồ Chí Minh                            |
| bank_code | HLBVN        | Ngân hàng TNHH MTV Hong Leong Việt Nam                                               |
| bank_code | DAB          | Ngân hàng TMCP Đông Á                                                                |
| bank_code | WOORIHCM     | NHWooriViệtNam(WooriBank)                                                            |
| bank_code | VIETTELMONEY | ViettelMoney                                                                         |
| bank_code | VID          | NHPublicViệtNam(PublicBankVietnam)                                                   |
| bank_code | PVCB         | Ngân hàng TMCP Đại Chúng Việt Nam                                                    |
| bank_code | LPB          | Ngân hàng TMCP Lộc Phát Việt Nam                                                     |
| bank_code | KBHN         | Ngân hàng Kookmin - Chi nhánh Hà Nội                                                 |
| bank_code | VBA          | Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam                               |
| bank_code | TIMO         | Ngân hàng số Timo by Ban Viet Bank (Timo by Ban Viet Bank)                           |
| bank_code | MAFC         | Công ty Tài chính TNHH MTV Mirae Asset (Việt Nam)                                    |
| bank_code | IBK - HN     | Ngân hàng Công nghiệp Hàn Quốc - Chi nhánh Hà Nội                                    |
| bank_code | EAB          | NHĐôngÁ(DongABank)                                                                   |
| bank_code | BID          | NHĐầuTư&PTViệtNam(BIDV)                                                              |
| bank_code | VCCB         | Ngân hàng TMCP Bản Việt                                                              |
| bank_code | KEBHANAHCM   | Ngân hàng KEB Hana – Chi nhánh Thành phố Hồ Chí Minh                                 |
| bank_code | KBHCM        | Ngân hàng Kookmin - Chi nhánh Thành phố Hồ Chí Minh                                  |
| bank_code | IBK          | NHCôngnghiệpHànQuốcHàNội(IBK-HN)                                                     |
| bank_code | COOPBANK     | Ngân hàng Hợp tác xã Việt Nam                                                        |
| bank_code | WVN          | Ngân hàng TNHH MTV Woori Việt Nam                                                    |
| bank_code | SGICB        | Ngân hàng TMCP Sài Gòn Công Thương                                                   |
| bank_code | ICB          | Ngân hàng TMCP Công thương Việt Nam                                                  |
| bank_code | IBKHN        | Ngân hàng Công nghiệp Hàn Quốc - Chi nhánh Hà Nội                                    |
| bank_code | VNPTMONEY    | VNPT Money                                                                           |
| bank_code | UOB          | Ngân hàng United Overseas - Chi nhánh TP. Hồ Chí Minh                                |
| bank_code | PVB          | NHĐạiChúng(PVcomBank)                                                                |
| bank_code | OCEANBANK    | Ngân hàng Thương mại TNHH MTV Đại Dương                                              |
| bank_code | CTG          | NHCôngThươngViệtNam(Vietinbank)                                                      |
| bank_code | VIETBANK     | Ngân hàng TMCP Việt Nam Thương Tín                                                   |
| bank_code | SCVN         | Ngân hàng TNHH MTV Standard Chartered Bank Việt Nam                                  |
| bank_code | PVDB         | Ngân hàng TMCP Đại Chúng Việt Nam Ngân hàng số                                       |
| bank_code | NTMXVN       | Ngân hàng TNHH MTV Xây dựng Viet Nam                                                 |
| bank_code | IBKHCM       | Ngân hàng Công nghiệp Hàn Quốc - Chi nhánh Thành phố Hồ Chí Minh                     |
| bank_code | VBSP         | Ngân hàng Chính sách Xã hội                                                          |
| bank_code | NTMHLVN      | Ngân hàng TNHH MTV Hong Leong Viet Nam                                               |
| bank_code | momo         | CTCP Dịch Vụ Di Động Trực Tuyến                                                      |
| bank_code | KEBHANAHN    | Ngân hàng KEB Hana – Chi nhánh Hà Nội                                                |
| bank_code | VTLMONEY     | Tổng Công ty Dịch vụ số Viettel - Chi nhánh tập đoàn công nghiệp viễn thông Quân Đội |
| bank_code | LIOBANK      | Liobank by OCB                                                                       |
| bank_code | UBANK        | Ubank by VPBank                                                                      |
| bank_code | CAKE         | Cake by VPBank                                                                       |
| bank_code | VIKKI        | Vikki Digital Bank                                                                   |
| bank_code | SAIGONB      | SAIGONBANK                                                                           |
| bank_code | PBVN         | VIDPublic Bank                                                                       |
| bank_code | EIB          | NGAN HANG TMCP XUAT NHAP KHAU VIET NAM (EXIMBANK)                                    |
| bank_code | VTB          | NGAN HANG TMCP CONG THUONG VIET NAM (VIETINBANK)                                     |
| bank_code | VCAPB        | NHTMCP BAN VIET                                                                      |
| bank_code | VUOB         | UNITED OVERSEAS BANK                                                                 |
| bank_code | HDB          | NGAN HANG TMCP PHAT TRIEN TP.HCM (HDBANK)                                            |
| bank_code | GPB          | Ngân hàng TM TNHH MTV (GPBANK)                                                       |
| bank_code | BIDV         | NGAN HANG TMCP DAU TU VA PHAT TRIEN VIET NAM (BIDV)                                  |
| bank_code | DONGA        | Donga Bank                                                                           |
| bank_code | MSB          | NGAN HANG TMCP HANG HAI VIET NAM (MARITIME BANK)                                     |
| bank_code | VPB          | NGAN HANG TMCP VIET NAM THINH VUONG (VPBANK)                                         |
| bank_code | SACOMB       | SACOMBANK                                                                            |
| bank_code | LVB          | NGAN HANG BUU DIEN LIEN VIET (LIENVIETPOSTBANK)                                      |
| bank_code | KLB          | Kien Long Joint-stock Commercial Bank (KienLongBank)                                 |
| bank_code | BAB          | Ngân hàng TMCP Bắc Á (BAC A BANK)                                                    |
| bank_code | ABB          | NGAN HANG TMCP AN BINH (ABBANK)                                                      |
| bank_code | VDBS         | DBS                                                                                  |
| bank_code | NCB          | NH TMCP QUOC DAN                                                                     |
| bank_code | YOLO         | Ngân hàng số VPDirect                                                                |
| bank_code | TPB          | TIENPHONG BANK                                                                       |
| bank_code | SHBVN        | SHINHAN BANK VN                                                                      |
| bank_code | SCB          | SCB                                                                                  |
| bank_code | OJB          | OCEANBANK                                                                            |
| bank_code | VIETB        | VIETBANK                                                                             |
| bank_code | SGB          | SAIGONBANK                                                                           |
| bank_code | SEAB         | SEABANK                                                                              |
| bank_code | NAB          | Ngân hàng TMCP Nam Á (NAM A BANK)                                                    |
| bank_code | IVB          | NGAN HANG TNHH INDOVINA (INDOVINA BANK)                                              |
| bank_code | AGR          | Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam (AGRIBANK)                    |
| bank_code | MBV          | Military Bank                                                                        |
| bank_code | VIETA        | VietABank                                                                            |
| bank_code | WOO          | WOORI BANK                                                                           |
| bank_code | HLB          | NGAN HANG TNHH MTV HONGLEONG VIET NAM (HLBANK)                                       |
| bank_code | CIMB         | NH MTV CIMB                                                                          |
| bank_code | OCBV         | OCB Vietnam                                                                          |
| bank_code | VHSBC        | HSBC                                                                                 |
| bank_code | VIB          | VIB BANK                                                                             |
| bank_code | VCPTB        | VIET CAPITAL BANK                                                                    |
| bank_code | VCB          | VIETCOMBANK                                                                          |
| bank_code | VAB          | Ngân hàng TMCP Việt Á                                                                |
| bank_code | SHB          | SHB BANK                                                                             |
| bank_code | BVB          | BAO VIET BANK (BVB)                                                                  |
| bank_code | ACB          | NGAN HANG TMCP A CHAU (ACB)                                                          |
| bank_code | VSTB         | STB                                                                                  |
| bank_code | STB          | SACOMBANK                                                                            |
| bank_code | PVCOMB       | PVCOMBANK                                                                            |
| bank_code | PGB          | PGBANK                                                                               |
| bank_code | OCB          | PHUONGDONG BANK                                                                      |
| bank_code | MB           | NGAN HANG TMCP QUAN DOI (MB)                                                         |
| bank_code | VIETCB       | VietCapitalBank                                                                      |
| bank_code | CBB          | C B BANK                                                                             |
| bank_code | VNCB         | National Citizen Bank                                                                |
| bank_code | VNHSBC       | HSBC Bank Vietnam Ltd (HSBC)                                                         |
| bank_code | VRB          | NH LD VIET NGA                                                                       |
| bank_code | TCB          | TECHCOMBANK  |

# 12. Error Codes

| Status Code | Description                                                              |
|------|----------------------------------------------------------------------------------------------------------------------------------------|
| 200 | Success                                                                |
| 1000 | Internal Error                                                             |
| 1001 | IP not in merchant IP whitelist.                                                    |
| 1002 | Parameter Error                                                            |
| 1003 | Signature Error                                                            |
| 1004 | Interface currently unavailable for the merchant (Contact operations to verify: Merchant or App (Not exist\|Closed\|Product not configured)) |
| 1005 | Merchant does not exist.                                                        |
| 1006 | Current user IP is in the blacklist.                                                  |
| 1007 | Current user is in the blacklist.                                                   |
| 1008 | Merchant App does not exist.                                                      |
| 1009 | Payment product does not exist.                                                    |
| 1010 | Payment channel does not exist.                                                    |
| 1011 | Payment channel development not completed, temporarily unavailable.                                  |
| 1012 | Payment channel exception, please try again later.                                           |
| 1013 | High order volume, please try again later.                                               |
| 1014 | Duplicate order number.                                                        |
| 1015 | Insufficient app balance.                                                       |
| 1016 | Frequent order placement by the same user, please try again later.                                   |
| 1017 | Order record does not exist.                                                      |
| 1018 | Current amount not supported.                                                     |
| 1019 | Pay-in not enabled for the app's country.                                               |
| 1020 | Pay-out not enabled for the app's country.                                               |
| 1021 | Failure                                                                |
| 1036 | Interface not yet open.                                                        |
| 1037 | Currency not supported.                                                        |
| 1038 | Pay-in utr reporting error.                                                      |
| 9999 | Other errors.                                                             |
| 3000 | System maintenance, order placement suspended, please try again later.                                 |

# 13. Pay-in Checkout Interface

Address: /api/v1/cashApi/CashIn.html 
Request Method: GET

### Parameters:

| Name    | Type  | Required | Description            |
| ---------- | ------ | -------- | ---------------------------------- |
| app_id   | string | true   | Merchant app_id.          |
| order_no  | string | true   | Merchant order number.       |
| amount   | string | true   | Merchant Amount (Unit: Dong) |
| notice_url | string | false  | Asynchronous notification address. |

#### Example

```
/api/v1/cashApi/CashIn.html?app_id={{app_id}}&order_no={{MerchantOrderNumber}}&amount={{MerchantAmount}}&notice_url={{AsynchronousNotificationAddress}} 
```
---
# 14. Document Update Time
```
2026-05-04 00:00:08
```