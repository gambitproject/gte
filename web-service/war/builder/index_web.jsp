<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>GTE&#946;</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<link href='https://fonts.googleapis.com/css?family=Architects+Daughter' rel='stylesheet' type='text/css'/>

	
	<script src="swfobject.js" type="text/javascript"></script>
	<script type="text/javascript" src="http://code.jquery.com/jquery-latest.js"></script>

	<script type="text/javascript" src="js/jquery.scrollTo.js"></script>
	<script type="text/javascript" src="js/jquery.localscroll.js"></script>
	<script type="text/javascript" src="js/jquery-ui-1.7.1.custom.min.js"></script>
	<script type="text/javascript" src="js/execute.js"></script>
	<script type="text/javascript" src="js/jqFancyTransitions.1.8.js"></script>

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
			var s="label="+name+";toolTip="+tooltip+";type="+type+";url="+url+";dir="+directory+";bw="+bw+";bl="+bl+";es="+es;
			flashvars[i]=s;
			i++;
		  });
		  
		  swfobject.embedSWF(
					"GuiBuilder-201207301904.swf", 
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
				document.getElementById("titleContainer").style.display = "none";
				document.getElementById("creditsContainer").style.display = "none";
				
				//Remove borders
				document.getElementById("GTEContainer").style.padding = "";
				document.getElementById("GTEContainer").style.border ="0px";
	
				//Maximize GTEContainer & solutionContainer
				document.getElementById("GTEContainer").style.height = "100%"; 
				document.getElementById("GTEContainer").style.width = "100%";
			}
			else //Contract
			{
				document.getElementById("titleContainer").style.display = "";
				document.getElementById("creditsContainer").style.display = "";
				
				document.getElementById("GTEContainer").style.padding = "2px 5px 5px 5px";
				document.getElementById("GTEContainer").style.border ="1px solid #808080";
				
				document.getElementById("GTEContainer").style.height = "580px";
				document.getElementById("GTEContainer").style.width = "85%";
			}
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
	
		  $(document).ready(function()
		    {
		      $('#box-links').localScroll({
  			 		target:'body'
				});	 
  			 $('#slideshowHolder').jqFancyTransitions({ width: 510, height: 250, delay: 2000 });	
				
		    });
		    
    
	</script>
	<style type="text/css">
		html, body { height:100%; background-color: #303030; background: url(header-bg.jpg) repeat;}		
		body { margin:0; }
		object:focus { outline:none; }	
		
		a:link {  color:white; text-decoration:underline; }
		a:hover {  color:black; text-decoration:underline; }
		h1 {
		
		  font-family: serif; 
		  font-size: 40px;
		  color: #fff;
		  text-align: center;

 		}
		
		h2 {
		
		  font-family: serif; 
		  font-size: 28px;
		  color: #fff;
		  text-align: center;		  
		}
		
		h3 {
		
		  font-family: serif; 
		  font-size: 28px;
		  color: #fff;
		}

		
		.menuFont {
		  font-family: serif; 
		  font-size: 32px;
		  color: #fff;
		}
		.normalFont {
		  font-family: serif; 
		  font-size: 18px;
		  color: #fff;
		}

		
		#nav-shadow {
			margin: 0 auto 50px auto;
			padding: 50px 0 0 127px;
			width: 700px;
			min-height: 130px;
			text-align: center;
			
			list-style: none;
			}
			
		#nav-shadow li {
			margin-right: 15px;
			width: 140px;
			height: 72px;
			position: relative;
			float: left;
			}
			
		#nav-shadow a, #nav-shadow a:visited, #nav-shadow a, #nav-shadow a:hover {
			margin: 0 auto;
			width: 59px;
			height: 59px;
			text-indent: -9999px;
			overflow: hidden;
			background: url(icons.png) no-repeat;
			display: block;
			position: relative;
			z-index: 2;
			}
			
		/* Button Colors */
		
		#nav-shadow li.button-color-1 a {
			background-position: -3px -3px;
			}
			
		#nav-shadow li.button-color-2 a {
			background-position: -92px -3px;
			}
			
		#nav-shadow li.button-color-3 a {
			background-position: -181px -3px;
			}
			
		#nav-shadow li.button-color-4 a {
			background-position: -270px -3px;
			}
			
		/* Button Shadow */
		
		#nav-shadow li img.shadow {
			margin: 0 auto;
			position: absolute;
			bottom: 0;
			left: 0;
			z-index: 1;
			}
	</style>
</head>
<body onload="javascript:prepareVars();">
<div id="box-links"> 
<div id="top">
	<h1> GTE - Game Theory Explorer</h1>
	<h2 style="text-align:center"> Build, explore and solve extensive and strategic form games.</h2>
</div>
<ul id="nav-shadow">
	<li class="button-color-1"><a href="#GTE" ></a><p class="menuFont">Explore GTE</p></li>
	<li class="button-color-3"><a href="#Tutorial" ></a><p class="menuFont">Tutorial</p></li>
	<li class="button-color-2"><a href="#Download" ></a><p class="menuFont">Download</p></li>
	<li class="button-color-4"><a href="#Contact" ></a><p class="menuFont">Contact</p></li>
</ul>


<div style=" margin: 0 auto;  width: 700px;  ">
<p class="normalFont">
The Game Theory Explorer (by <a href="https://github.com/gambitproject/gte">Mark Egesdal</a>,
<a href="https://github.com/alfongj/gte">Alfonso Gomez-Jordana</a> and 
<a href="https://github.com/trobar/gte">Martin Prause</a>) is a graphical user interface for 
interactive construction and analysis of small to medium games. 
GTE is part of the <a href="http://www.gambit-project.org/">Gambit Project</a> - a library of game theory software supervised by 
<a href="https://github.com/stengel">Bernhard von Stengel</a>  and
<a href="https://github.com/rahulsavani">Rahul Savani</a>
This version of GTE is designed to be portable across plarforms and runs on 
Linux and Windows (Mac OS X in progress). The software consists of a 
Web-Application-Client for the User-Interface (written in ActionScript) 
and a Web-Application-Server (Jetty) to process computational tasks 
such as calculation and enumeration of Nash-Equilibria.
</p>
</div>



<div id="GTE">
<h3>Explore GTE</h3>
<h2 style="text-align:center"><a href="index.jsp">Click here to explore and solve extensive and strategic form games.</a></h2>
<div id='slideshowHolder' style=" margin: 0 auto;  width: 100%;  ">
 <img src='slide01k.jpg' />
 <img src='slide02k.jpg'  />
 <img src='slide03k.jpg'  />
 <img src='slide04k.jpg' />
</div>
<a href="#TOP" >Up</a>
</div>

<div id="Tutorial">
<h3>Tutorial</h3>
<a href="#TOP" >Up</a>
</div>

<div id="Download">
<h3>Download</h3>
<a href="#TOP" >Up</a>
</div>


<div id="Contact">
<h3>Contact</h3>
<a href="#TOP" >Up</a>
</div>

</div>		
</body>
</html>
