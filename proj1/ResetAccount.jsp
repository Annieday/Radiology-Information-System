<HTML>
<HEAD>
	<TITLE>Reset Account Page</TITLE>
</HEAD>
<BODY background="BGP.jpg">
	<%@ page import="java.sql.*"%>
	<%
	if((request.getParameter("UpdateAccount")!=null 
	|| request.getParameter("CommitUpdateAccount")!=null )
	&& ((String)session.getAttribute("class"))!=null){
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
			String user_name = request.getParameter("UserName").trim();
			Statement s=con.createStatement();
			String sqlStatement="SELECT * FROM users WHERE user_name='"+user_name+"'";
			String password = null; String userClass=null; Integer person_id=null;
			ResultSet resSet=s.executeQuery(sqlStatement);
			int cnt=0;
			while(resSet.next()){
				password=resSet.getString("password");
				userClass=resSet.getString("class");
				cnt++;
			}
			if(cnt==0){
				out.println("<p><b>No such an Account</b></p>");
				out.println("<p><b>Invalid UserName!</b></p>");
				out.println("<p><b>Press RETURN to the previous page.</b></p>");
				out.println("<FORM NAME='AbortForm' ACTION='AdminPage.jsp' METHOD='get'>");
				out.println("    <CENTER><INPUT TYPE='submit' NAME='RETURN' VALUE='RETURN'></CENTER>");
				out.println("</FORM>");
			}
			else{
				out.println("<H1><CENTER><font color =Teal> Manage a specific Account: </font></CENTER></H1>");
				out.println("<HR></HR>");
				out.println("<FORM NAME='AddUserFrom' ACTION='ResetAccount.jsp' METHOD='post'>");
				out.println("	<TABLE style='margin: 0px auto'>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> User Name: </font></I></B></TD>");
				out.println("			<TD>"+user_name+"</TD>");
				out.println("		</TR>");
				
				out.println("		<TR>");
				if(request.getParameter("CommitUpdateAccount") == null){
					out.println("			<TD><B><I><font color=Maroon> Password: </font></I></B></TD>");
					out.println("			<TD><INPUT TYPE='text' NAME='newPassword' VALUE='"+password+"'></TD>");
				}
				else{
					String newPassword=request.getParameter("newPassword").trim();
					out.println("			<TD><B><I><font color=Maroon> Password: </font></I></B></TD>");
					out.println("			<TD><INPUT TYPE='text' NAME='newPassword' VALUE='"+newPassword+"'></TD>");
				}
				out.println("		</TR>");
				out.println("		<TR>");
				out.println("			<TD><B><I><font color=Maroon> User Class(type in one of a,d,p,r)*: </font></I></B></TD>");
				out.println("			<TD>"+userClass+"</TD>");
				out.println("		</TR>");
				out.println("	</TABLE>");
				out.println("<CENTER>*a for Admin, d for Doctor, p for Patient, r for Radiologist</CENTER>");
				out.println("   <HR></HR>");
				out.println("<INPUT TYPE='hidden' NAME='UserName' VALUE='"+user_name+"'>");
				out.println("   <CENTER><INPUT TYPE='submit' NAME='CommitUpdateAccount' VALUE='OK'></CENTER>");
				
			}
			if(request.getParameter("CommitUpdateAccount")!=null){
				String newPassword=request.getParameter("newPassword").trim();
					
				Statement s1=con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_UPDATABLE);
				String sqlStatement1="SELECT user_name,password,class FROM users WHERE user_name='"+user_name+"' FOR UPDATE";
				ResultSet resSet1=s1.executeQuery(sqlStatement1);
				try{
					while(resSet1.next()){
						resSet1.updateString("password",newPassword);
						resSet1.updateRow();
					}
					s1.executeUpdate("commit");
					out.println("<CENTER>Change password successfully! New Password is: "+newPassword+"</CENTER>");
				}
				catch(Exception e){
					
				}
			}
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
