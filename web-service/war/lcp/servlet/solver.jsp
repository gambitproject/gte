<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>LCP Solver</title>
</head>
<body>

<% if (request.getAttribute("error") != null) { %>
<div style="border: 1px solid #880000; padding: 8px; background: #ffbbbb; width: 400px;">
<h3 style="display: inline; margin-right: 1em;">Error:</h3>
<%= request.getAttribute("error") %>
<% if ((request.getAttribute("qerror") != null) || (request.getAttribute("Merror") != null) || (request.getAttribute("derror") != null)) { %>
<ul style="margin-top: 0; margin-bottom: 0;">
<%= request.getAttribute("qerror") != null ? "<li>" + request.getAttribute("qerror") + "</li>" : "" %>
<%= request.getAttribute("Merror") != null ? "<li>" + request.getAttribute("Merror") + "</li>" : "" %>
<%= request.getAttribute("derror") != null ? "<li>" + request.getAttribute("derror") + "</li>" : "" %>
</ul>
<% } %>
</div>
<% } %>

<h3>Solves the following system:</h3>

<p>
z &#8805; <b>0</b>,&#160;&#160;&#160;&#160;&#160; 
z<sub>0</sub> &#8805; 0,&#160;&#160;&#160;&#160;&#160;
w = q + Mz + dz<sub>0</sub> &#8805; <b>0</b>,&#160;&#160;&#160;&#160;&#160; 
z<sup>T</sup>w = 0
</p>

<form action="" method="post">
<p>
q<sup>T</sup>:
<span style="display: inline-block; vertical-align: middle;<%= request.getAttribute("qerror") != null ? " border: 2px solid #ff0000; padding: 3px;" : "" %>">
<textarea rows="1" cols="35" name="q" style="overflow: hidden;"><%= request.getParameter("q") != null ? request.getParameter("q") : "1 -1 -1 -1" %></textarea>
</span>
</p>

<p>
M:
<span style="display: inline-block; vertical-align: middle;<%= request.getAttribute("Merror") != null ? " border: 2px solid #ff0000; padding: 3px;" : "" %>">
<textarea rows="8" cols="35" name="M" style="overflow: hidden;"><%= request.getParameter("M") != null ? request.getParameter("M") : "1 -2 3 -5\r\n7 11 -13 17\r\n19 -23 29 -31\r\n37 41 -43 47" %></textarea>
</span>
</p>

<p>
d<sup>T</sup>:
<span style="display: inline-block; vertical-align: middle;<%= request.getAttribute("derror") != null ? " border: 2px solid #ff0000; padding: 3px;" : "" %>"> 
<textarea name="d" rows="1" cols="35" style="overflow: hidden;"><%= request.getParameter("d") != null ? request.getParameter("d") : "1 1 1 1" %></textarea> 
</span>
</p>

<p><input type="submit" value="Find Solution"></input></p>
</form>

<% if(request.getAttribute("z") != null) { %>
<div style="border: 1px solid #008800; padding: 8px; background: #bbffbb; width: 400px;">
<h3 style="display: inline; margin-right: 1em;">Solution:</h3>  
<% 
String[] z = (String[]) request.getAttribute("z");
int count = z.length;
StringBuilder sb = new StringBuilder();
for (int i = 0; i < count; ++i)
{ 
	sb.append((i == count - 1) ? z[i] : (z[i] + ", "));
} 
%>
<%--  <textarea rows="1" cols="35" name="z" readonly="readonly" style="overflow: hidden;"> --%>
z<sup>T</sup>: [ <%= sb.toString() %> ]
<%-- </textarea> --%>
</div>
<% } else if(request.getAttribute("nosolz") != null) { %>
<div style="border: 1px solid #000088; padding: 8px; background: #bbbbff; width: 400px;">
<h3 style="display: inline; margin-right: 1em;">No Solution:</h3>
<%= request.getAttribute("nosolz") %>
</div>
<% } %>
</body>
</html>