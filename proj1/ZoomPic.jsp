<HTML>
<HEAD>
		<TITLE>Picture View Page</TITLE>
</HEAD>
<BODY>
	<%
		String picID=request.getParameter("picID");
		if(picID!=null){
			out.println("<H1>Click the image to Zoom</H1>");
			out.println("<a href='GetOnePic?f"+picID+"'><img src='GetOnePic?"+picID+"'></a>");
		}
	%>
</BODY>
</HTML>