<HTML>
<HEAD>
	<TITLE>Add Person Page</TITLE>
</HEAD>
<BODY background="BGP.jpg">
	<%@ page import="java.sql.*"%>
	<%
		if(request.getParameter("AddPerson")!=null && ((String)session.getAttribute("class"))!=null){
			out.println("<H1><CENTER><font color =Teal> New Person Register: </font></CENTER></H1>");
			out.println("<HR></HR>");
			out.println("<FORM NAME='AddPersonFrom' ACTION='CommitAddPerson.jsp' METHOD='post'>");
			out.println("	<TABLE style='margin: 0px auto'>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> First Name: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='FirstName' VALUE=''></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> Last Name: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='LastName' VALUE=''></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> Address: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='Address' VALUE=''></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> Email: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='Email' VALUE=''></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> Phone: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='Phone' VALUE=''></TD>");
			out.println("		</TR>");
			out.println("	</TABLE>");
			out.println("   <HR></HR>");
			out.println("   <CENTER><INPUT TYPE='submit' NAME='CommitAddPerson' VALUE='Add'></CENTER>");
			out.println("</FORM>");
			
			
			out.println("<FORM NAME='CancelForm' ACTION='AdminPage.jsp' METHOD='get'>");
			out.println("    <CENTER><INPUT TYPE='submit' NAME='cancel' VALUE='cancel'></CENTER>");
			out.println("</FORM>");
		}
		else{
			out.println("<p><b>You have no right to use this module</b></p>");
			out.println("<p><b>Press RETURN to the login page.</b></p>");
			out.println("<FORM NAME='NotAllowFrom' ACTION='Login.html' METHOD='get'>");
			out.println("    <CENTER><INPUT TYPE='submit' NAME='NOT_ALLOW' VALUE='RETURN'></CENTER>");
			out.println("</FORM>");
		}
	%>
</BODY>
</HTML>
