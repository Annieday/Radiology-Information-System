<HTML>
<HEAD>
	<TITLE>Add User Page</TITLE>
</HEAD>
<BODY background="BGP.jpg">
	<%@ page import="java.sql.*"%>
	<%
		if(request.getParameter("AddUser")!=null && ((String)session.getAttribute("class"))!=null){
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
				con.setAutoCommit(true);
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
				out.println("<H1><CENTER><font color =Teal> New User Register: </font></CENTER></H1>");
				out.println("<HR></HR>");
				out.println("<FORM NAME='AddUserFrom' ACTION='CommitAddUser.jsp' METHOD='post'>");
				out.println("	<TABLE style='margin: 0px auto'>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> User Name: </font></I></B></TD>");
				out.println("			<TD><INPUT TYPE='text' NAME='UserName' VALUE=''></TD>");
				out.println("		</TR>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> Password: </font></I></B></TD>");
				out.println("			<TD><INPUT TYPE='password' NAME='Password' VALUE=''></TD>");
				out.println("		</TR>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> User Class: </font></I></B></TD>");
				out.println("			<TD><SELECT NAME='Class'>");
				out.println("           	<OPTION VALUE='a' SELECTED> Administrator </OPTION>");
				out.println("           	<OPTION VALUE='d' SELECTED> Doctor </OPTION>");
				out.println("           	<OPTION VALUE='r' SELECTED> Radiologist </OPTION>");
				out.println("           	<OPTION VALUE='p' SELECTED> Patient </OPTION>");
				out.println("			</SELECT></TD>");
				out.println("		</TR>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> Choose person : </font></I></B></TD>");
				out.println("			<TD><SELECT NAME='ID'>");
				//get all person info from table:
				Statement s=con.createStatement();
				String sqlStatement="SELECT person_id,first_name,last_name FROM persons";
				ResultSet resSet=s.executeQuery(sqlStatement);
				while(resSet.next()){
					Integer person_id=resSet.getInt("person_id");
					String first_name=resSet.getString("first_name");
					String last_name=resSet.getString("last_name");
					out.println("           	<OPTION VALUE='"+person_id+"' SELECTED> "+first_name+" "+last_name+" ;ID: "+person_id+"</OPTION>");
				}
				//-------------------------------
				out.println("			</SELECT></TD>");
				out.println("		</TR>");
				out.println("	</TABLE>");
				out.println("   <HR></HR>");
				out.println("   <CENTER><INPUT TYPE='submit' NAME='CommitAddUser' VALUE='Add'></CENTER>");
				out.println("</FORM>");
				con.close();
				
				
				out.println("<FORM NAME='CancelForm' ACTION='AdminPage.jsp' METHOD='get'>");
				out.println("    <CENTER><INPUT TYPE='submit' NAME='cancel' VALUE='cancel'></CENTER>");
				out.println("</FORM>");
			}
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
