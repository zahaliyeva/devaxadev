var TEXT = 1;
var NUMBER = 2;
var EMAIL = 3;
var DATE = 4;
var DATETIME = 5;
var TIME = 6;

function doSort(sortBy) {
  formSortBy = document.getElementById('sortby');
  formSortDir = document.getElementById('sortdir');
  if (formSortDir.value == 'ASC' && formSortBy.value == sortBy) {
    newSortDir = 'DESC';
  }
  else {
    newSortDir = 'ASC';
  }
  formSortBy.value = sortBy;
  formSortDir.value = newSortDir;
  formSortDir.form.submit();
}

function padLeft(content, length, padChar) {
  var output = content.toString();
  if (!padChar) { padChar = '0'; }
  while (output.length < length) {
    output = padChar + output;
  }
  return output;
};

function zeroPad(num, count)
{
  var numZeropad = num + '';
  
  while(numZeropad.length < count) {
    numZeropad = "0" + numZeropad;
  }
  
  return numZeropad;
}

function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft,curtop];
}

function selectAll(elem) {
  var prefix = elem.name.substr(0, elem.name.length - 4);
  var postfix = elem.name.substr(elem.name.length - 4);
  var theForm = elem.form;
  if (postfix == '_all') { // This is the master controller
    for (i=0; i < theForm.length; i++) {
      if (theForm[i].type == 'checkbox' && 
          theForm[i].name.substr(0, prefix.length) == prefix &&
          theForm[i].name != prefix + '_all') {
        theForm[i].checked = elem.checked;    
      }
    }
  }
  else { // Slave
    // Find correct prefix
    var current = 0;
    var lastPos = 0;
    while (1) {
      lastPos = elem.name.indexOf('_', current);
      if (lastPos != -1) {
        current = lastPos + 1;
      }
      else {
        break;
      }
    }
    var prefix2 = elem.name.substr(0, current);
    if (elem.checked == false) {
      document.getElementById(prefix2 + 'all').checked = false;
    }
  }     
}

function validateCheckboxGroup(theForm, prefix, desc) {
  var count = 0;
  for (i=0; i < theForm.length; i++) {
    if (theForm[i].type == 'checkbox' && 
        theForm[i].name.substr(0, prefix.length) == prefix &&
        theForm[i].name != prefix + '_all' &&
        theForm[i].checked == true) {
      count++; 
    }
  }
  if (count == 0) {
    alert('Please select at least one '+desc);
    return false;
  }
  return true;
}

function validateSelectGroup(theForm, prefix, desc) {
  
  var count = 0;
  for (i=0; i < theForm.length; i++) {    
    if (theForm[i].type == 'select-one' && 
        theForm[i].name.substr(0, prefix.length) == prefix &&
        theForm[i].name != prefix + '_all' &&
        theForm[i].value != "") {
      count++;
    }
  }
  if (count == 0) {
    alert('Please select at least one ' + desc);
    return false;
  }
  return true;
}

function validateTextGroup(theForm, prefix, desc) {
  
  var count = 0;
  for (i=0; i < theForm.length; i++) {
    if (theForm[i].type == 'text' && 
        theForm[i].name.substr(0, prefix.length) == prefix &&
        theForm[i].name != prefix + '_all' &&
        theForm[i].value != "") {
      count++;
    }
  }
  if (count == 0) {
    alert('Please fill in at least one ' + desc);
    return false;
  }
  return true;
}

function validate_field(field_obj, msg, field_type) {
	
	//field_obj must be a valid form field
	if (field_obj.value.search(/\S/) == -1) {

        alert(msg);
        field_obj.focus();
        return 0;
    }
    else    {
        //checking for email if needed
        if (field_type == EMAIL)    {
            if (field_obj.value.search(/^[^@ ]+@[^@ ]+\.[^@ \.]+$/) == -1)   {
                alert(msg);
                field_obj.focus();
                return 0;
            }
                return 1;
        }
        else if (field_type == NUMBER)  {
            if (isNaN(field_obj.value)) {
                alert(msg);
                field_obj.focus();
                return 0;
            }
            else
                return 1;
        }

		else if (field_type == DATE)    {
			if (field_obj.value.length == 10 &&
				field_obj.value.search(/(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d/) >= 0)    {
				parts = field_obj.value.split("/");
                d = parseInt(parts[0]);
                m = parseInt(parts[1]);
                y = parseInt(parts[2]);

                //get the wrong dates
                if ((d>=30 && m==2) ||
                    (d==31 && (m==2 || m==4 || m==6 || m==9 || m==11)) ||
                    (d==29 && m==2 && !(((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0))))   {
					alert(msg);
            		field_obj.focus();
					return 0;
                }
                else
                    return 1;
			}
			else    {
			    alert(msg);
                field_obj.focus();
				return 0;
			}
		}
		
		
		else if (field_type == TIME)    {
		    if (field_obj.value.length == 5)    {
		        parts = field_obj.value.split(":");
		        if (parts.length == 2)  {
		            h = parts[0];
		            m = parts[1];
		            if (h>=0 && h<=23 && m>=0 && m<=59)
						return 1;
					else    {
					    alert(msg);
        				field_obj.focus();
						return 0;
					}
		        }
		        else    {
		            alert(msg);
					field_obj.focus();
					return 0;
		        }
		    }
		    else    {
		        alert(msg);
				field_obj.focus();
				return 0;
		    }
		}


		else if (field_type == DATETIME)    {
			parts = field_obj.value.split(" ");
			if (parts.length == 2)  {
			    dates = parts[0];
			    times = parts[1];
				
				if (dates.length == 10 &&
					dates.search(/(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d/) >= 0)  {
	                dateparts = dates.split("/");
	                d = parseInt(dateparts[0]);
	                m = parseInt(dateparts[1]);
	                y = parseInt(dateparts[2]);

	                //get the wrong dates
	                if ((d>=30 && m==2) ||
	                    (d==31 && (m==2 || m==4 || m==6 || m==9 || m==11)) ||
	                    (d==29 && m==2 && !(((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0))))   {
						alert(msg);
                		field_obj.focus();
						return 0;
	                }
	                else    {
	                    //check time
						timeparts = times.split(":");
						if (timeparts.length == 2)  {
						    h = parseInt(timeparts[0]);
							m = parseInt(timeparts[1]);
							if (h>=0 && h<=23 && m>=0 && m<=59)
								return 1;
							else    {
							    alert(msg);
                				field_obj.focus();
								return 0;
							}
						}
						else    {
                            alert(msg);
                			field_obj.focus();
							return 0;
						}
					}
                }
                else    {
                    alert(msg);
        			field_obj.focus();
					return 0;
                }
			}
			else    {
			    alert(msg);
                field_obj.focus();
				return 0;
			}
		}

		else
		    return 1;
	}
}

function validate_sel(obj, msg) {
  if (obj.value == "")  {
    alert(msg);
    obj.focus();
    return false;
  } 
  else
    return true;
}

function validate_multiplesel(obj, msg){  
  var numSelected = 0;
  var i;
  
  for (i=0;i<obj.length;i++){
    if (obj.options[i].selected){
      if(obj.options[i].value != 0 && obj.options[i].value != "0" && obj.options[i].value != "")
        numSelected++;  
    }
  }
  
  if (numSelected < 1){
    alert(msg);
    obj.focus();
    return false;
  }else{
    return true;
  }
}

function validate_rd(obj, msg){
  
  myOption = -1;
  
  for (i=obj.length-1; i > -1; i--) {    
    if (obj[i].checked) {      
      myOption = i; 
      i = -1;
    }
  }
  
  if(obj.checked==true)
  {
    myOption= 1;
  }
  if (myOption == -1) {
    alert(msg);
    return false;
  }else{
    return true;
  }
  
}

function validate_checkbox(obj, prefix, msg){
  var cnt = 0;  
  var len = prefix.length;
  
  for (i=0; i<obj.elements.length; i++) {
    if (obj.elements[i].name.substring(0, len) == prefix) {    
      if (obj.elements[i].checked){
        cnt++;  
      }
    }
  }     
  
  if (cnt > 0)
    return true;  
  else {
    alert(msg);
    return false;
  }
}

function checkValidDate(d, m, y, msg)    {
	if ((d>=30 && m==2) ||
	    (d==31 && (m==2 || m==4 || m==6 || m==9 || m==11)) ||
	    (d==29 && m==2 && !(((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0))))   {
		alert("Please fill in valid Date for " + msg);
		return 0;
    }
    else
        return 1;
}


function compareTimeString(time1, time2)    {
//return 0 if time1 == time2
//return 1 if time1 > time2
//return -1 if time1 < time2
	if (time1 == time2)
	    return 0;

	//split the time first
	time1part = time1.split(":");
	time2part = time2.split(":");

	time1_h = time1part[0];
	time1_m = time1part[1];
	time2_h = time2part[0];
	time2_m = time2part[1];

	//compare
	if (time1_h > time2_h ||
		(time1_h == time2_h && time1_m > time2_m))
	    return 1;
	else
	    return -1;
}


function compareDateString(date1, date2)    {
//return 0 if time1 == time2
//return 1 if time1 > time2
//return -1 if time1 < time2
	if (date1 == date2)
	    return 0;

	//split the time first
	date1part = date1.split("/");
	date2part = date2.split("/");

	date1_d = date1part[0];
	date1_m = date1part[1];
	date1_y = date1part[2];
	date2_d = date2part[0];
	date2_m = date2part[1];
	date2_y = date2part[2];

	//compare
	if ((date1_y > date2_y) ||
	    (date1_y == date2_y && date1_m > date2_m) ||
	    (date1_y == date2_y && date1_m == date2_m && date1_d > date2_d))
	    return 1;
	else
	    return -1;
}


function winpopup(url, win_width, win_height)  {
	sw = screen.width;
	sh = screen.height;

	x = Math.ceil((sw - win_width) / 2);
	y = Math.ceil((sh - win_height) / 2);
	window.open(url, "_blank", "left=" + x + ",top=" + y + ",menubar=yes,toolbar=yes,scrollbars=yes,status=yes,resizable=yes,width=" + win_width + ",height=" + win_height);
}

function winpopup2(url, win_width, win_height)  {
	sw = screen.width;
	sh = screen.height;

	x = Math.ceil((sw - win_width) / 2);
	y = Math.ceil((sh - win_height) / 2);
	window.open(url, "_blank", "left=" + x + ",top=" + y + ",toolbar=yes,menubar=yes,scrollbars=yes,status=yes,resizable=yes,width=" + win_width + ",height=" + win_height);
}

function winpopup3(url, win_width, win_height)  {
	sw = screen.width;
	sh = screen.height;

	x = Math.ceil((sw - win_width) / 2);
	y = Math.ceil((sh - win_height) / 2);
	window.open(url, "_blank", "left=" + x + ",top=" + y + ",menubar=no,scrollbars=no,status=yes,resizable=no,width=" + win_width + ",height=" + win_height);
}

function winpopup4(url, win_width, win_height)  {
	sw = screen.width;
	sh = screen.height;

	x = Math.ceil((sw - win_width) / 2);
	y = Math.ceil((sh - win_height) / 2);
	window.open(url, "_blank", "left=" + x + ",top=" + y + ",menubar=no,scrollbars=yes,status=yes,resizable=no,width=" + win_width + ",height=" + win_height);
}

function winpopup3s(url, win_width, win_height) {
    sw = screen.width;
    sh = screen.height;

    x = Math.ceil((sw - win_width) / 2);
    y = Math.ceil((sh - win_height) / 2);
    window.open(url, "_dp", "left=" + x + ",top=" + y + ",menubar=no,scrollbars=no,status=yes,resizable=no,width=" + win_width + ",height=" + win_height);
}

//restrict typing beyond maximum length. (used by textarea)
function restrict_length(obj, len)  {
  if (obj.value.length > len) {
    alert("Maximum Length Reach");
    obj.value = obj.value.substr(0, len);
  }
}

//word counter
function wordCounter(field, countfield, maxlimit) { 
  var objTxt = field;
  var objCnt = countfield;
  var strOutput = "";
  
  char_count = objTxt.value.length; // very crude measure

  fullStr = objTxt.value + " "; // add space delimiter to end of text
  
  initial_whitespace_rExp = /^[^A-Za-z0-9]+/gi; //use for complex whitespace
  
  left_trimmedStr = fullStr.replace(initial_whitespace_rExp, " ");
  
  non_alphanumerics_rExp = /[^A-Za-z0-9]+/gi;   // and for delimiters
  
  cleanedStr = left_trimmedStr.replace(non_alphanumerics_rExp, " ");
  
  splitString = cleanedStr.split(" ");
  wordcounter = splitString.length-1;
  objCnt.value = maxlimit - wordcounter;
  
  if(wordcounter > maxlimit){
    splitString = splitString.slice(0, maxlimit-1);
    objTxt.value = splitString.join(" ");
    objCnt.value = 0;
    
    return false;
  }
  
  return true;
}

//text counter
function textCounter(field, countfield, maxlimit) {
  if (field.value.length > maxlimit){
    field.value = field.value.substring(0, maxlimit);
  }else{
    countfield.value = maxlimit - field.value.length;
  }
}

//AJAX
function GetXmlHttpObject() {
  var xmlHttp=null;
  try
    {
    // Firefox, Opera 8.0+, Safari
    xmlHttp=new XMLHttpRequest();
    }
  catch (e)
    {
    // Internet Explorer
    try
      {
      xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
      }
    catch (e)
      {
      xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
    }
  return xmlHttp;
}

// return the value of the radio button that is checked
// return an empty string if none are checked, or
// there are no radio buttons
function getCheckedValue(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return radioObj.value;
		else
			return "";
	for(var r = 0; r < radioLength; r++) {
		if(radioObj[r].checked) {
			return radioObj[r].value;
		}
	}
	return "";
}

function sendpage(){
	location.href = "send-page.php?sp="+encodeURIComponent(location.href)+"";
}

function gosearch(){
	var srckey = document.frmtopsearch.srckey.value;
	if(srckey!=""&&srckey!=null&&srckey!=undefined){
		location.href = "src-publication-result.php?srckey="+encodeURIComponent(srckey)+"";
	}
}

function gosearch1(){
	var srckey = document.getElementById("srckey").value;
	if(srckey!=""&&srckey!=null&&srckey!=undefined){
		location.href = "src-publication-result.php?srckey="+encodeURIComponent(srckey)+"";
	}
}

function validateInt(value) {
	var match = /^ *[0-9]+ *$/.test(value);
	if (match == true) {
		return true;
	}
	else {				
		return false;
	}
}

function validateString(obj, msg){
  var match = /^[a-zA-Z ]+$/.test(obj.value);
  if (match == true) {
    return true;
  }
  else {
    alert(msg);
    obj.focus();
    return false;
  }
}

function validateNoSpaceString(obj, msg){
  var match = /^[a-zA-Z]+$/.test(obj.value);  //just remove space after Z
  if (match == true) {
    return true;
  }
  else {
    alert(msg);
    obj.focus();
    return false;
  }
}

function validateChineseEmailAddOn(obj, msg) {
	var match = /^[a-zA-Z0-9\.\@\_\-]+$/.test(obj.value);  //just remove space after Z
	if (match == true) {
		return true;
	}
	else {
		alert(msg);
		obj.focus();
		return false;
	}
}

function getRadioListSelectedValue(objName) {
	for (var i = 0; i < objName.length; i++) {
		if (objName[i].checked == true) {
			return objName[i].value;
		}
	}
}

function validateChkBox(obj, msg) {
	if (obj.checked) {
		return true;
	}
	else {
		alert(msg);
		obj.focus();
		return false;
	}
}

function validateDecimal(obj, msg, isMandatory) {
	if (isMandatory) {
		var match = /^\s*((\d+(\.\d+)?)|(\.\d+))\s*$/.test(obj.value);
		if (match == true) {
			return true;
		}
		else {
			alert(msg);
			obj.focus();
			return false;
		}
	}
	else {
		if (obj.value != "") {
			var match = /^\s*((\d+(\.\d+)?)|(\.\d+))\s*$/.test(obj.value);
			if (match == true) {
				return true;
			}
			else {
				alert(msg);
				obj.focus();
				return false;
			}
		}
		else {
			return true;
		}
	}
}

function getDateDiffInDays(date1, date2) {
	var one_day = 1000 * 60 * 60 * 24;

	return Math.ceil((date1.getTime() - date2.getTime()) / one_day);
}

function validateChineseWords(obj, msg) {
	var match = /^[a-zA-Z0-9\.\@\_\- ]+$/.test(obj.value);  //just remove space after Z

	if (obj.value == "") {
		return true;
	}
	else {
		if (match == true) {
			return true;
		}
		else {
			alert(msg);
			obj.focus();
			return false;
		}
	}		
}

function validateFileType(obj, msg, isMandatory){
	var valid_extensions = /(.xls|.xlsx|.doc|.docx)$/i;
            
	if(isMandatory){
		if (valid_extensions.test(obj.value)) {
			return true;        
		}
		else{        
			alert(msg + "(\".xls\",\".xlsx\",\".doc\",\".docx\")");
			obj.select();
			obj.focus();
			return false;        
		}
	}
	else{
		//if optional field then put (|| obj.value == "") else take it out	
		if (valid_extensions.test(obj.value) || obj.value == "") {
			return true;        
		}
		else{        
			alert(msg + "(\".xls\",\".xlsx\",\".doc\",\".docx\")");
			obj.select();
			obj.focus();
			return false;        
		}    
	}	 

}

function isNumberKey(evt){
	//var charCode = (evt.which) ? evt.which : event.keyCode

	if (window.event) {
		charCode = window.event.keyCode;
	}
	else if (evt) {
		charCode = evt.which;
	}
	else {
		return true;
	}

	if (charCode > 31 && (charCode < 48 || charCode > 57)){
		return false;
	}

	return true;
	// onkeypress="return isNumberKey(event)"			 
}


function validate_checkbox_axa(obj, prefix, msg){
  var cnt = 0;  
  var len = prefix.length;
  
  
  document.getElementById("hd"+prefix).value="";
  
  for (i=0; i<obj.elements.length; i++) {
    if (obj.elements[i].name.substring(0, len) == prefix) {    
      if (obj.elements[i].checked){
        cnt++;  
        
        var curSelected=document.getElementById("hd"+prefix).value; 
        if(curSelected!="")
        {
            curSelected=curSelected+";"
        }
        document.getElementById("hd"+prefix).value=curSelected+obj.elements[i].value;
        
      }
    }
  }     
  
  if (cnt > 0)
    return true;  
  else {
    return true;
  }
}

function validate_checkbox_axa_getAnswer(obj, prefix, msg){
  var cnt = 0;  
  var len = prefix.length;
  
  
  document.getElementById("hd"+prefix).value="";
  
  for (i=0; i<obj.elements.length; i++) {
    if (obj.elements[i].name.substring(0, len) == prefix) {    
      if (obj.elements[i].checked){
        cnt++;  
        
        var curSelected=document.getElementById("hd"+prefix).value; 
        if(curSelected!="")
        {
            curSelected=curSelected+";"
        }
        document.getElementById("hd"+prefix).value=curSelected+obj.elements[i].value;
        
      }
    }
  }     
  
  if (cnt > 0)
    return true;  
  else {
    return true;
  }
}


function checkbox_axa_getSelected(obj, prefix, msg){
    var cnt = 0;  
    var len = prefix.length;


    var hd=document.getElementById("hd"+prefix);

    var myString = hd;
    var mySplitResult = myString.split(";");
    for(x = 0; x < mySplitResult.length; x++){
        document.write("<br /> Option " + x + " = " + mySplitResult[x]);
        
        for (i=0; i<obj.elements.length; i++) {
        if (obj.elements[i].name.substring(0, len) == prefix) {    
          if (obj.elements[i].checked){
            cnt++;  
            
            if(obj.elements[i].value==mySplitResult[x])
            {
            obj.elements[i].checked=true;
            }
           
          }
        }
      }
      
    
    }
  
  return true;
  
}


 function isFloatKey(itm){
    if (document.getElementById(itm).value.search(/\S/) == -1)
    {
        return true;
    }
    else
    {
        if (validate_field(document.getElementById(itm), "No allow fill-in alphabet", NUMBER)) 
        {
            return true;
        }
        document.getElementById(itm).value="";
        document.getElementById(itm).focus();
    }
    return false;
    //onblur='return isFloatKey(this.id)'
}


function callError1()
{
    alert('Invalid file size. The maximum upload size is 3MB.\n上載文件無效。上載最大限額為3MB.');
}


function validateCaptcha() {
    challengeField = $("input#recaptcha_challenge_field").val();
    responseField = $("input#recaptcha_response_field").val();
    var html = $.ajax({
        type: "POST",
        url: "ajax-captcha.aspx",
        data: "action_type=CAPTCHA&recaptcha_challenge_field=" + challengeField + "&recaptcha_response_field=" + responseField,
        async: false
    }).responseText;

    if (html == "True") {
        return true;
    } else {

        alert('The security code you entered did not match. Please try again.');
        ///$("#captchaStatus").html("** The security code you entered did not match. Please try again.");
        Recaptcha.reload();
        return false;
    }
}