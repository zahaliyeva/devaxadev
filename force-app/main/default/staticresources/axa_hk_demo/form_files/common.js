function txtOnclick(obj){
	obj.value = "";
}

function txtOnblur(obj) {			
	if (obj.value == "your phone number" || obj.value == "") {
		obj.value = "your phone number";
	}			
}		

function ajaxCallMe() {
	if ($('#txtCallMe').val() == "your phone number" || $('#txtCallMe').val() == "") {
		$("#divCallMeMsg").html("<span class='error'>Please fill in phone number.</span>");
		return;							
	}

	$('#btnCallMe').hide();
	$('#imgLoader').show();

	var emailSendTo = $('#txtEmailSendTo').val();	
	var phoneNo = $('#txtCallMe').val();			
						
	var isSuccess = false;
	var pdata = { action_type: 'CALL_ME', emailSendTo:emailSendTo, phoneNo: phoneNo };
	$.ajax({
		type: "GET",
		url: webPath + "ajax.aspx", //webPath from master page
		data: pdata,
		success: function(xml) {
			//new method to get success indicator					
			$('YES', xml).each(
				function() {
					isSuccess = true;
				}
			);

			if (isSuccess) {
				$('#btnCallMe').show();
				$('#imgLoader').hide();
				$("#divCallMeMsg").html("<span class='notice'>Email sent successfully.</span>");
			}
			else {
				$('#btnCallMe').show();
				$('#imgLoader').hide();
				$("#divCallMeMsg").html("<span class='error'>" + $(xml).find('errMsg').text() + "</span>");
			}

		},
		timeout: function(data) {
			alert("Timeout!")
		},
		error: function(httpObj) {
			alert("Error!")
		},
		parsererror: function(data) {
			alert("Parse error!")
		}
	});
}

//for homepage
function ajaxBigCallMe() {				
		if ($('#txtBigCallMe').val() == "your phone number" || $('#txtBigCallMe').val() == "") {
			$("#divCallMeMsg").html("<span class='error'>Please fill in phone number.</span>");
			return;							
		}

		$('#btnCallMe').hide();
		$('#imgLoader').show();

		var emailSendTo = $('#txtEmailSendTo').val();	
		var phoneNo = $('#txtBigCallMe').val();			
							
		var isSuccess = false;
		var pdata = { action_type: 'CALL_ME', emailSendTo:emailSendTo, phoneNo: phoneNo };
		$.ajax({
			type: "GET",
			url: webPath + "ajax.aspx", //webPath from master page
			data: pdata,
			success: function(xml) {
				//new method to get success indicator					
				$('YES', xml).each(
					function() {
						isSuccess = true;
					}
				);

				if (isSuccess) {
					$('#btnCallMe').show();
					$('#imgLoader').hide();
					$("#divCallMeMsg").html("<span class='notice'>Email sent successfully.</span>");
				}
				else {
					$('#btnCallMe').show();
					$('#imgLoader').hide();
					$("#divCallMeMsg").html("<span class='error'>" + $(xml).find('errMsg').text() + "</span>");
				}

			},
			timeout: function(data) {
				alert("Timeout!")
			},
			error: function(httpObj) {
				alert("Error!")
			},
			parsererror: function(data) {
				alert("Parse error!")
			}
		});
	}        
		
	function jobPopup(id, lang) {
    sw = screen.width;
    sh = screen.height;

    var win_width = 680;
    var win_height = 600;
      
    x = Math.ceil((sw - win_width) / 2);
    y = Math.ceil((sh - win_height) / 2);
    window.open(webPath + "job-detail.aspx?id=" + id + "&lang=" + lang, "_blank", "left=" + x + ",top=" + y + ",status=yes,scrollbars=yes,width=" + win_width + ",height=" + win_height);      
    return false;
  }          
  