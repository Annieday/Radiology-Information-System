<HTML>
<HEAD>
<TITLE>Manage Page</TITLE>
</HEAD>
<BODY background="BGP.jpg">
	<%@ page import="java.sql.*"%>
	<%
	if(request.getParameter("ManagePerson") != null && ((String)session.getAttribute("class"))!=null){
		String oracleId = (String)session.getAttribute("ORACLE_ID");
		String oraclePassword = (String)session.getAttribute("ORACLE_PASSWORD");

		Connection con = null;
		String driverName = "oracle.jdbc.driver.OracleDriver";
		String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
		Boolean canConnect = true;
		
		try{
			Class drvClass = Class.forName(driverName);
			DriverManager.registerDriver((Driver)drvClass.newInstance());
			con = DriverManager.getConnection(dbstring,oracleId,oraclePassword);
			con.setAutoCommit(false);
		}
		catch(Exception e){
			canConnect = false;
			out.println("<p><b>Unable to Connect Oracle DB!</b></p>");
			out.println("<p><b>Invalid UserName or Password!</b></p>");
			out.println("<p><b>Press RETURN to the previous page.</b></p>");
			out.println("<FORM NAME='ConnectFailForm' ACTION='Connector.html' METHOD='get'>");
			out.println("    <CENTER><INPUT TYPE='submit' NAME='CONNECTION_FAIL' VALUE='RETURN'></CENTER>");
			out.println("</FORM>");
    	}
		if(canConnect){
			Statement s=con.createStatement();
			String sqlStatement=null;
			String person_id=request.getParameter("ID").trim();
			ResultSet resSet=null;
			sqlStatement = "SELECT * FROM persons WHERE person_id="+person_id;
			resSet = s.executeQuery(sqlStatement);
			String first_name = null;
			String last_name=null;
			String address=null;
			String email=null;
			String phone=null;
			while(resSet != null && resSet.next()){
				first_name=resSet.getString("first_name");
				last_name=resSet.getString("last_name");
				address=resSet.getString("address");
				email=resSet.getString("email");
				phone=resSet.getString("phone");
			}
			out.println("<H1><CENTER><font color =Teal>"+first_name+" "+last_name+"'s profile:</font></CENTER></H1>");
			out.println("<HR></HR>");
			out.println("<FORM NAME='ChangeProfileForm' ACTION='CommitManagePersonInfo.jsp' METHOD='post'>");
			out.println("	<TABLE style='margin: 0px auto'>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon> First Name: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='newFirstName' VALUE='"+first_name+"'></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon>Last Name: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='newLastName' VALUE='"+last_name+"'></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon>Address: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='newAddress' VALUE='"+address+"'></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon>Email: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='newEmail' VALUE='"+email+"'></TD>");
			out.println("		</TR>");
			out.println("		<TR>");
			out.println("			<TD><B><I><font color=Maroon>Phone: </font></I></B></TD>");
			out.println("			<TD><INPUT TYPE='text' NAME='newPhone' VALUE='"+phone+"'></TD>");
			out.println("		</TR>");
			
			out.println("	</TABLE>");
			out.println("   <HR></HR>");
			
			out.println("<INPUT TYPE='hidden' NAME='person_id' VALUE='"+person_id+"'>");
			out.println("<INPUT TYPE='hidden' NAME='oldFirstName' VALUE='"+first_name+"'>");
			out.println("<INPUT TYPE='hidden' NAME='oldLastName' VALUE='"+last_name+"'>");
			out.println("<INPUT TYPE='hidden' NAME='oldAddress' VALUE='"+address+"'>");
			out.println("<INPUT TYPE='hidden' NAME='oldEmail' VALUE='"+email+"'>");
			out.println("<INPUT TYPE='hidden' NAME='oldPhone' VALUE='"+phone+"'>");
			
			out.println("   <CENTER><INPUT TYPE='submit' NAME='UPDATE' VALUE='UPDATE'></CENTER>");
			out.println("</FORM>");
			out.println("<FORM NAME='CancelForm' ACTION='AdminPage.jsp' METHOD='get'>");
			out.println("<Center><INPUT TYPE='submit' NAME='cancel' VALUE='CANCEL'></Center>");
			out.println("</FORM>");
			con.close();
		}
	}
	else{
		response.sendRedirect("Login.html");
	}
	%>
</BODY>
</HTML>
