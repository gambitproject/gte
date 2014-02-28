<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>GTE&#946;</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="swfobject.js" type="text/javascript"></script>
	<script type="text/javascript" src="js/jquery-1.8.2.js"></script>
	<script type="text/javascript" src="js/jquery.bpopup-0.7.0.min.js"></script>
	
	
	<script type="text/javascript">
	


			
	
		<!-- For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. --> 
        var swfVersionStr = "10.0.0";
        <!-- To use express install, set to playerProductInstall.swf, otherwise the empty string. -->
        var xiSwfUrlStr = "playerProductInstall.swf";
        var flashvars ={};

        
        function prepareVars() {
	        $.ajax({
			    type: "GET",
			    url: "webservices.xml",
			    dataType: "xml",
			    success: parseXml,
			    error:function (xhr, ajaxOptions, thrownError){
	                alert(xhr.status);
	                alert(thrownError);}    
			  });
        };
        
		function parseXml(xml)
		{
		  //find every Tutorial and print the author
		  var i=0;
		  $(xml).find("Servlet").each(function()
		  {
		  	var active=$(this).find("Active").text();
		  	
		  	var name=$(this).attr("Name");
			var tooltip=$(this).find("Tooltip").text();
			var url=$(this).find("Url").text();	
			var type=$(this).find("Type").text();	
			var directory=$(this).find("Directory").text();
			var bw=$(this).find("BinaryWindows").text();	
			var bl=$(this).find("BinaryLinux").text();	
			var es=$(this).find("Estimate").text();
			var ms=$(this).find("MaxSeconds").text();
			var s="label="+name+";toolTip="+tooltip+";type="+type+";url="+url+";dir="+directory+";bw="+bw+";bl="+bl+";es="+es+";ms="+ms;
			flashvars[i]=s;
			i++;
		  });
		  
		  swfobject.embedSWF(
					"GuiBuilder.swf", 
					"flashContainer", 
					"100%", 
					"100%", 
					swfVersionStr, 
					xiSwfUrlStr, 
					flashvars, 
					params, 
					attributes);
		};
		
        <!--	var flashvars = { -->
        <!--			menum: "label=Lrs Find All Eq;toolTip=Lrs Find All Equilibria;type=nf;url=/gte/matrix/",-->
        <!--			msolve: "label=Lemke NF Eq;toolTip=Lemke Find One Equilibrium;type=nf;url=/gte/matrix/",    -->
        <!--	        xsolve: "label=Lemke SF Eq;toolTip=Lemke Find One Equilibrium (Sequence Form);type=xf;url=/gte/tree/", -->			
        <!--	        lrsC: "label=Lrs C algo;toolTip=Lrs C Algo;type=nf;url=/gte/lrsc/servlet;dir=/test" -->
		
		
	    <% if (request.getParameter("s") != null) { %>
	    flashvars.seed = "<%= request.getParameter("s") %>";
	    <% } %>
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#FFFFFF",		
		};
		var attributes = {
			id:"GuiBuilder"
		};
		attributes.align = "middle";
		
		
			
			
		//Changes the window title
		function changeDocTitle(value)
		{
			document.title = 'GTE - '+value;
		}		
			
		var outputWindow = null;
			
		//Writes the output solution from an algo into a pop-up window
		function writeSolution(data)
		{			
			var regex = /^SUCCESS/;
			if (regex.test(data)) {
				headerBackgroundColor = "#00ff6b";
			} else {
				headerBackgroundColor = "#ff0000";
			}
			
			if(outputWindow!=null)
				outputWindow.close();
				
			outputWindow=window.open("", "Output", "height=500, width=500, toolbar=yes, location=no, directories=no, status=no, menubar=yes, scrollbars=yes, resizable=yes"); 
							
			outputWindow.document.write("<html><head><title>Output</title><style type='text/css'>html, body { height:100%; background-color: #FFFFFF;} body { margin:0; }	object:focus { outline:none; } </style></head>"); 
			outputWindow.document.write("<body><div id='solutionHeader' style='background-color: "+headerBackgroundColor+"; color: #003300; border: #808080 solid 1px; font-size: 12px; padding: 3px 5px 3px 5px; font-family: Helvetica; font-weight: bold;  display: block;'>&#160;</div>");
			outputWindow.document.write("<div id='solution' style='background-color: #ffffff;  border-top: 0; font-size: 12px; padding: 3px 5px 3px 5px; display: block; overflow: auto;'><pre>"+data+"</pre></div></body></html>"); 
			outputWindow.document.close();
			var desiredHeight = Math.min(outputWindow.document.getElementById("solutionHeader").offsetHeight + outputWindow.document.getElementById("solution").offsetHeight + 100 , 750);
			outputWindow.resizeTo(500,desiredHeight); 
		}
			
		
		
		//Expands / Contracts the gui if setting is true / false
		function expand(setting)
		{
			if(setting) //Expand
			{
				//Hide title and credits
				//document.getElementById("titleContainer").style.display = "";
				//document.getElementById("creditsContainer").style.display = "none";
				
				//Remove borders
				document.getElementById("GTEContainer").style.padding = "";
				document.getElementById("GTEContainer").style.border ="0px";
	
				//Maximize GTEContainer & solutionContainer
				document.getElementById("GTEContainer").style.height = "100%"; 
				document.getElementById("GTEContainer").style.width = "100%";
			}
			/*
			else //Contract
			{
				document.getElementById("titleContainer").style.display = "";
				document.getElementById("creditsContainer").style.display = "";
				
				document.getElementById("GTEContainer").style.padding = "2px 5px 5px 5px";
				document.getElementById("GTEContainer").style.border ="1px solid #808080";
				
				document.getElementById("GTEContainer").style.height = "580px";
				document.getElementById("GTEContainer").style.width = "85%";
			}*/
		}
		
		//Returns the flashmovie
		function getFlashMovie() {
			if (navigator.appName.indexOf("Microsoft") != -1) {
				 return window["GuiBuilder"];
			} else {
				 return document["GuiBuilder"];
			}
		}
		
		//Before closing the browser window, it prompts if there are unsaved changes
		window.onbeforeunload = function (evt)
		{ 
		   if(getFlashMovie().askBeforeQuit())
		   {
			  var message = 'The current file has unsaved changes. '
							+ 'Do you really want to quit?'; 
			  return message;
		   }
		}	
		
		
		 ;(function($) {

	         // DOM Ready
	        $(function() {

	            // Binding a click event
	            // From jQuery v.1.7.0 use .on() instead of .bind()
	            $('#creditPopup').bind('click', function(e) {

	                // Prevents the default action to be triggered. 
	                e.preventDefault();

	                // Triggering bPopup when click event is fired
	                $('#creditsContainer').bPopup({modalClose: true});

	            });

	            $('#creditClose').bind('click', function(e) {

	                // Prevents the default action to be triggered. 
	                e.preventDefault();

	                // Triggering bPopup when click event is fired
	                $('#creditsContainer').bPopup().close();
	            });


	        });

	    })(jQuery);
	    
		;(function($) {
			$("#GTEContainer").height($(window).height() - $("#titleContainer").height());
			$(window).resize(function() { $("#GTEContainer").height($(window).height() - $("#titleContainer").height()); });
			
		})(jQuery);	
		
			
	
		
	</script>
	<style type="text/css">
		html, body { height:100%; background-color: #303030;}		
		body { margin:0; }
		object:focus { outline:none; }		
	</style>
</head>
<body onload="javascript:prepareVars();">
	<div id="titleContainer" style="text-align: left; width: 100%; margin: auto; background-color: #303030; color: #ffffff; padding: 0px 5px 0px 5px; border-left: 1px solid #303030; border-right: 1px solid #303030;">
		<img style="display:inline; vertical-align: middle; border: #808080 solid 1px; margin: 5px 5px 5px 0px;" src="8size32.ico" />
		<div style="vertical-align: middle; display: inline-block; margin: 5px 5px 5px 0px;">
			<h3 style="display: inline; font-family: Helvetica;">Game Theory Explorer <span style="color: #ffd700">&#946;</span></h3><br/>
			<em style="font-size: 13px; font-family: Helvetica; color: #a0a0a0;">Build, explore and solve extensive form games.</em>
		</div>
		<div style="vertical-align: middle; display: inline-block; margin: 5px 5px 5px 0px; float: right;">
		<em id="creditPopup" style="font-size: 13px; font-family: Helvetica; color: #a0a0a0; text-decoration:underline;cursor:pointer;">Credits and Feedback</em>
		</div>
	</div>
	<!--   <div id="GTEContainer" style="position: relative; text-align: left; width: 85%; margin: auto; background-color: #B7BABC;  padding: 2px 5px 5px 5px; border: 1px solid #808080;"> -->
    <div id="GTEContainer" style="position: relative; text-align: left; width: 100%; height: 100%; margin: auto; background-color: #B7BABC; border: 0px;">	
		<!-- <div style="background-color: #e0e0e0; border: #808080 solid 1px; font-size: 12px; padding: 3px 5px 3px 5px; font-family: Helvetica; font-weight: bold;">Build</div> -->
			<div id="flashContainer" style="height: 100%; position: absolute; top: 0px; left: 0px;" >			
				<p>
					To view this page ensure that Adobe Flash Player version 
					10.0.0 or greater is installed. 
				</p>
				<script type="text/javascript"> 
					var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://"); 
					document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
									+ pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" ); 
				</script>
				<noscript>
					<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%" id="GuiBuilder">
						<param name="movie" value="GuiBuilder.swf" />
						<param name="quality" value="high" />
						<param name="bgcolor" value="white" />
						<param name="allowFullScreen" value="true" />
						<param name="allowScriptAccess" value="always" />
						<!--[if !IE]>-->
						<object type="application/x-shockwave-flash" data="GuiBuilder.swf" width="100%" height="100%">
							<param name="quality" value="high" />
							<param name="bgcolor" value="white" />
							<param name="allowFullScreen" value="true" />
							<param name="allowScriptAccess" value="always" />
						<!--<![endif]-->
						<!--[if gte IE 6]>-->
							<p> 
								Either scripts and active content are not permitted to run or Adobe Flash Player version
								10.0.0 or greater is not installed.
							</p>
						<!--<![endif]-->
							<a href="http://www.adobe.com/go/getflashplayer">
								<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash Player" />
							</a>
						<!--[if !IE]>-->
						</object>
						<!--<![endif]-->
					</object>
				</noscript>	
			</div>
	</div>

 

    <div id="creditsContainer" style="display:none; font-size: 10px; font-family: Helvetica; text-align: left; margin: auto; background-color: #303030; color: #a0a0a0; padding: 3px 5px 3px 5px; border-left: 1px solid #303030; border-right: 1px solid #303030; width:400px;height:200px;">
		<img style="display:inline; vertical-align: middle; border: #808080 solid 1px; margin: 5px 5px 5px 0px;" src="8size32.ico" />
		<div style="vertical-align: middle; display: inline-block; margin: 5px 5px 5px 0px;">
			<h3 style="display: inline; font-family: Helvetica;">Game Theory Explorer <span style="color: #ffd700">&#946;</span></h3><br/>
			<em style="font-size: 13px; font-family: Helvetica; color: #a0a0a0;">Build, explore and solve extensive form games.</em>
		</div>
		<br/>
		<div>
		<div style="display: inline-block; margin-bottom: 5px;">Last modified: yyyy-MM-dd hh:mm GMT</div><br/>
		Developed by <span style="color: #ffffff;">Mark Egesdal, Alfonso Gomez-Jordana, Martin Prause, Rahul Savani, and Bernhard von Stengel.</span><br/><br/>Lemke algorithm and Sequence Form implementations adapted from the work of Bernhard von Stengel. Lrs algorithm implementation adapted from the work of David Avis.  Lrs enumeration adapted from the work of Rahul Savani.<br/><br/>Most icons courtesy of the Silk Icon Set created by Mark James.
		</div>
		<br/>
		<em id="creditClose" style="font-size: 13px; font-family: Helvetica; color: #a0a0a0; text-decoration:underline;cursor:pointer;margin:auto">Close</em>

	</div>


</body>
</html>
