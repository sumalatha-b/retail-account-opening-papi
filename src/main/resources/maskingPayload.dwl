%dw 2.0
import * from dw::core::Strings
output application/json
 
fun getMaskDataFields(fields) =
    (fields splitBy ",") map ((item) -> trim(upper(item)))
 
fun last4(inputData : String | Null) =
    if (inputData == null) ""
    else if (sizeOf(inputData) <= 4) inputData
    else repeat("*", sizeOf(inputData) - 4) ++ substring(inputData, sizeOf(inputData) - 4, sizeOf(inputData))
 
fun maskData(payload, keyName, fieldsList) =
    payload match {
        case is Array ->
            payload map maskData($, null, fieldsList)
 
        case is Object ->
            payload mapObject {
                ($$): maskData($, $$, fieldsList)
            }
 
        else ->
            if (fieldsList contains upper(keyName as String))
                last4(payload)
            else
                payload
    }
 
fun createDebugLog(logMsg, flowName, payload, fields) = {
    timestamp: now(),
    flowName: flowName default "",
    logLevel: "INFO",
    logMessage: logMsg default "",
    payload: maskData(payload, null, getMaskDataFields(fields))
}
 
---
createDebugLog(
    "Request Payload",
    "SampleFlow",
    payload,
    "accountNumber,ssn,password,partyIdentificationValue"
)