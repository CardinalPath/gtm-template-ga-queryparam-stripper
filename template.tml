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
            "displayName": "These parameters are automatically allowed: \ngclid, gclsrc, utm_source, utm_content, utm_id,utm_medium,utm_campaign,utm_term"
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

// Enter your template code here.
const log = require('logToConsole');
var url_noparams;  // url with query params removed
const decode = require('decodeUriComponent');

function getQueryVariable(query,variable) {
  if(data.lowercase){
    query=query.toLowerCase();
  }
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
      if(data.lowercase){
        pair[0]=pair[0].toLowerCase();
      }
        if (decode(pair[0]) == variable) {
            return decode(pair[1]);
        }
    }
}

function getFinalURL(data){  // omit query parmams that should be excluded
  var output="";
  for (let i = 0; i < data.length; i++) {
    if(i==0){
    output+="?";
    }else{
      output+="&";
    }
    output+=data[i];
}
  return output;
}

if(data.lowercase){
  data.document_location=data.document_location.toLowerCase();
}

if(data.param_setting=="exclude"){
  /* 
       exclude all query params except those on the white list 
  */
  if(data.document_location && data.document_location.indexOf("?")>=0){ // query params detected 
    if(data.allowed_param_list!=undefined){
    data.allowed_param_list=data.params_allowed.split(",");
    data.allowed_param_list.push("gclid","gclsrc","utm_source","utm_content","utm_id","utm_medium","utm_campaign","utm_term");
    log(data.allowed_param_list);
    data.allowed_params_detected=[];  
    
    for (let i = 0; i < data.allowed_param_list.length; i++) {
   
      if(getQueryVariable(data.document_location,data.allowed_param_list[i])!=undefined){         data.allowed_params_detected.push(data.allowed_param_list[i].toLowerCase()+"="+getQueryVariable(data.document_location,data.allowed_param_list[i]));
      }
    }
    }
    var base_url=data.document_location.split("?")[0];
    
    if(data.allowed_params_detected && data.allowed_params_detected.length>0){
      data.qsp="";
      for (let j = 0; j < data.allowed_params_detected.length; j++) {
        if(j==0){
          data.qsp+="?";
        }else{
          data.qsp+="&";
        }
        data.qsp+=data.allowed_params_detected[j];
      }
       log('exclude most params', data);
      return base_url+data.qsp;

    }else{
       log('exclude most params', data);
       return base_url;
    }
  
  }else{
    // no params detected
    log('data =', data);
    return data.document_location;
  } 
  
}else{
  /* 
     only specific query params will be excluded 
     
  */
   log('include =', data);
  if(data.document_location && data.document_location.indexOf("?")>=0){ // query params detected
    data.params=data.document_location.split("?")[1];
    url_noparams=data.document_location.split("?")[0];
    data.params=data.params.split("&");
    data.allowed_params=[];
    
    if(data.lowercase){      
      log("include: lower case enabled");
      data.param_exclusions=data.param_exclusions.toLowerCase();
    }
    var key;  
    for (let i = 0; i < data.params.length; i++) {   
      if(data.param_exclusions.indexOf(data.params[i].split("=")[0])<0){
        log("include, index>0",data.params[i]);
       data.allowed_params.push(data.params[i]);
      }
    }
    
    log('exclude some params =', data);
      return url_noparams+getFinalURL(data.allowed_params);
    
    
  }else{
    // no params detected
    log('exclude some params =', data);
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
      document_location:"https://www.broadcom.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true",
      param_exclusions:"foo,sourceurl",
      param_setting:"include",
      lowercase:true
    };

    // Call runCode to run the template's code.
    let result = runCode(test_data);

    // Verify that the variable returns a result.
    assertThat(result).isNotEqualTo(undefined);
    assertThat(result).isEqualTo("https://www.broadcom.com/404-symantec?test=true&app=true");
- name: '[INCLUDE] one param'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec?test=true\"\
    ,\n  param_exclusions:\"foo,test\",\n  param_setting:\"include\"\n  \n};\n\n//\
    \ Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[INCLUDE] no params'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec\"\
    ,\n  param_exclusions:\"foo\",\n  param_setting:\"include\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[INCLUDE] folder'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec/?test=true\"\
    ,\n  param_exclusions:\"foo,test\",\n  param_setting:\"include\"\n  \n};\n\n//\
    \ Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);\n\
    // Call runCode to run the template's code."
- name: '[EXCLUDE] multiple parameters'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true\"\
    ,\n  params_allowed:\"foo,test\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[EXCLUDE] gclid'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true&gclid=1234\"\
    ,\n  params_allowed:\"foo,test\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call\
    \ runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isNotEqualTo(undefined);"
- name: '[EXCLUE] without whitelist'
  code: "const mockData = {\n  // Mocked field values\n  document_location:\"https://www.broadcom.com/404-symantec?sourceURL=http://symantec.com/nothing&foo=bar&test=true&app=true&gclid=1234\"\
    ,\n // params_allowed:\"\",\n  param_setting:\"exclude\"\n  \n};\n\n// Call runCode\
    \ to run the template's code.\nlet result = runCode(mockData);\n\n// Verify that\
    \ the variable returns a result.\nassertThat(result).isNotEqualTo(undefined);\n\
    assertThat(result).isEqualTo(\"https://www.broadcom.com/404-symantec\");"


___NOTES___

Created on 6/16/2022, 10:28:43 AM
