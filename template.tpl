___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Query Parameter Stripping Utility",
  "description": "This will remove unwanted query parameters( page UR, Referrer, etc.) to reduce cardinality.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "param_setting",
    "displayName": "",
    "radioItems": [
      {
        "value": "exclude",
        "displayValue": "Exclude All Parameters",
        "help": "This will strip out all parameters except for those specified aboveThis will only strip out parameters listed within the Parameters text box",
        "subParams": [
          {
            "type": "TEXT",
            "name": "params_allowed",
            "displayName": "These parameters are allowed",
            "simpleValueType": true,
            "help": "Use a comma separated string",
            "valueHint": "param1,param2"
          },
          {
            "type": "LABEL",
            "name": "note",
            "displayName": "These parameters are automatically allowed: \ngclid, gclsrc, utm_source, utm_content, utm_id,utm_medium,utm_campaign,utm_term,utm_id,dclid,gclsrc,utm_source_platform,utm_creative_format,utm_marketing_tactic,srsltid"
          }
        ]
      },
      {
        "value": "include",
        "displayValue": "Exclude Certain Parameters",
        "help": "This will only strip out parameters listed within the Parameters text box",
        "subParams": [
          {
            "type": "TEXT",
            "name": "param_exclusions",
            "displayName": "Only these parameters will be removed",
            "simpleValueType": true
          }
        ]
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "document_location",
    "displayName": "Field which needs parameters removed",
    "simpleValueType": true,
    "help": "Mandatory field to pass Full URL to template",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "lowercase",
    "checkboxText": "Force  to Lowercase",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const decode = require('decodeUriComponent');
const parseUrl = require('parseUrl');
const Object = require('Object');

function getQueryVariable(query_param) {
  return urlObject.searchParams[query_param];
}

function toLowerKeys(obj) {
  return Object.keys(obj).reduce((accumulator, key) => {
    accumulator[key.toLowerCase()] = obj[key];
    return accumulator;
  }, {});
}

function getFinalURL(data){  // omit query parmams that should be excluded
  var output="";
  for (let i = 0; i < data.length; i++) {
    if(i==0){
    output+="?";
    }else{
      output+="&";
    }
    output+=data[i]+"="+getQueryVariable(data[i]);
}
  return output;
}

const urlObject = parseUrl(data.document_location);
data.url_noparams=urlObject.protocol+"//"+urlObject.hostname+urlObject.pathname;
data.detected_query_params_array = Object.entries(urlObject.searchParams);

if(data.lowercase){
  data.document_location=data.document_location.toLowerCase();
  urlObject.searchParams=toLowerKeys(urlObject.searchParams);
}

if(data.param_setting=="exclude"){
  /* 
       exclude all query params except those on the white list 
  */
  if(data.document_location && data.document_location.indexOf("?")>=0){ // query params detected 
    if(data.params_allowed){
      data.allowed_param_list=data.params_allowed.split(",");
    }else{
      data.allowed_param_list=[];
    }
    data.allowed_param_list.push("gclid","gclsrc","utm_source","utm_content","utm_id","utm_medium","utm_campaign","utm_term","wbraid","gbraid","utm_id","dclid","gclsrc","utm_source_platform","utm_creative_format","utm_marketing_tactic","srsltid");
    if(data.allowed_param_list!=undefined){
    data.allowed_params_detected=[];  
    for (let i = 0; i < data.allowed_param_list.length; i++) {
      if(getQueryVariable(data.allowed_param_list[i])!=undefined){  
        data.allowed_params_detected.push(data.allowed_param_list[i]);
      }
    }
    }
    
    if(data.allowed_params_detected && data.allowed_params_detected.length>0){
      return data.url_noparams+getFinalURL(data.allowed_params_detected);
    }else{
 //    log('exclude most params', data);
       return data.url_noparams;
    }
  
  }else{
    // no params detected
    return data.document_location;
  } 
  
}else{
  /* 
     only specific query params will be excluded     
  */
  if(data.document_location && data.document_location.indexOf("?")>=0){ // query params detected
    data.params=data.detected_query_params_array;
    data.allowed_params=[];   
    if(data.lowercase){      
      data.param_exclusions=data.param_exclusions.toLowerCase();
    }
    
    // loop thru each parameter, identify parameters allowed.
    for (let i = 0; i < data.detected_query_params_array.length; i++) {        
      if(getQueryVariable(data.detected_query_params_array[i][0])!==undefined && data.param_exclusions.indexOf(data.detected_query_params_array[i][0])<0){
        data.allowed_params.push(data.detected_query_params_array[i][0]);
      }
    }
      return data.url_noparams+getFinalURL(data.allowed_params); 
  }else{
    return data.document_location;
  } 
}
___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___


scenarios:
- name: '[INCLUDE] multiple params'
  code: |-
    const test_data = {
      document_location:"https://www.domain.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true",
      param_exclusions:"foo,sourceurl",
      param_setting:"include",
      lowercase:true
    };

    // Call runCode to run the template's code.
    let result = runCode(test_data);

    // Verify that the variable returns a result.
    assertThat(result).isNotEqualTo(undefined);
    assertThat(result).isEqualTo("https://www.domain.com/404-symantec?test=true&app=true");
- name: '[INCLUDE] one param'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec?test=true\"\
    ,\n  param_exclusions:\"foo,test\",\n  param_setting:\"include\"\n  \n};\n\n//\
    \ Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[INCLUDE] no params'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec\"\
    ,\n  param_exclusions:\"foo\",\n  param_setting:\"include\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[INCLUDE] folder'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec/?test=true\"\
    ,\n  param_exclusions:\"foo,test\",\n  param_setting:\"include\"\n  \n};\n\n//\
    \ Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo(\"\
    https://www.domain.com/404-symantec/\");\n// Call runCode to run the template's\
    \ code."
- name: '[EXCLUDE]utm'
  code: |-
    const test_data = {
      document_location:"https://www.domain.com/?utm_medium=test",
      param_exclusions:"",
      params_allowed:"",
      param_setting:"exclude",
      lowercase:true
    };

    // Call runCode to run the template's code.
    let result = runCode(test_data);

    // Verify that the variable returns a result.
    assertThat(result).isNotEqualTo(undefined);
    assertThat(result).isEqualTo("https://www.domain.com/?utm_medium=test");
- name: '[EXCLUDE] multiple parameters'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true\"\
    ,\n  params_allowed:\"foo,test\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[EXCLUDE] gclid'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true&gclid=1234\"\
    ,\n  params_allowed:\"foo,test\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[EXCLUE] without whitelist'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.domain.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true&gclid=1234\"\
    ,\n  //params_allowed:\"\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call runCode\
    \ to run the template's code.\nlet result = runCode(mockData);\n\n// Verify that\
    \ the variable returns a result.\nassertThat(result).isNotEqualTo(undefined);\n\
    assertThat(result).isEqualTo(\"https://www.domain.com/404-symantec?gclid=1234\"\
    );"


___NOTES___

Created on 6/16/2022, 10:28:43 AM
