# Java 签名示例

签名规则：

1. 解析请求参数 JSON。
2. 过滤值为 `null`、空字符串 `""` 和字段 `sign`。
3. 按参数名升序排序后，拼接为 `key1=value1&key2=value2`。
4. 末尾追加 `&key=商户密钥`。
5. 对待签名字符串做 MD5，输出 32 位小写签名。

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class SignTool {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    public static SignResult generateSign(String paramsJson, String merchantSecret) throws Exception {
        Map<String, Object> params = OBJECT_MAPPER.readValue(
                paramsJson, new TypeReference<HashMap<String, Object>>() {}
        );

        Map<String, Object> filteredParams = new TreeMap<>();
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();

            if ("sign".equals(key) || value == null) {
                continue;
            }
            if (String.valueOf(value).isEmpty()) {
                continue;
            }
            filteredParams.put(key, value);
        }

        List<String> pairs = new ArrayList<>();
        for (Map.Entry<String, Object> entry : filteredParams.entrySet()) {
            pairs.add(entry.getKey() + "=" + entry.getValue());
        }

        String paramStr = String.join("&", pairs);
        String signStr = paramStr + "&key=" + merchantSecret;
        String sign = md5Lower(signStr);

        return new SignResult(signStr, sign);
    }

    private static String md5Lower(String text) throws Exception {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] digest = md.digest(text.getBytes(StandardCharsets.UTF_8));

        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    public static void main(String[] args) throws Exception {
        String testParamsJson = "{"
                + "\"trade_no\":10003,"
                + "\"order_no\":\"p7158412025RAprmNz7lR\","
                + "\"app_id\":10002,"
                + "\"pay_code\":0,"
                + "\"price\":10099,"
                + "\"pay_notice_url\":\"http://host/api/v1/mer/cbtest\","
                + "\"attach\":\"\","
                + "\"sign\":\"3d6dea05a7c08564911b9922e16455c2\","
                + "\"user_ip\":\"87.200.59.100\","
                + "\"success_url\":\"\","
                + "\"fail_url\":\"\","
                + "\"user_id\":\"2677343\""
                + "}";

        String testSecret = "your_merchant_secret_key";

        SignResult result = generateSign(testParamsJson, testSecret);
        System.out.println("待签名字符串: " + result.getSignStr());
        System.out.println("最终签名(MD5, 32位小写): " + result.getSign());
    }

    public static class SignResult {
        private final String signStr;
        private final String sign;

        public SignResult(String signStr, String sign) {
            this.signStr = signStr;
            this.sign = sign;
        }

        public String getSignStr() {
            return signStr;
        }

        public String getSign() {
            return sign;
        }
    }
}
```

说明：以上示例使用 Jackson 解析 JSON，实际接入时也可以替换为你项目中已有的 JSON 库。
