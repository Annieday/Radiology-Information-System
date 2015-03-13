<HTML>
<HEAD>
	<TITLE>Manage Family Doctor Page</TITLE>
</HEAD>
<BODY background='BGP.jpg'>
	<%@ page import="java.sql.*"%>
	<%
		if(request.getParameter("ManageFamilyDoctor")!=null && ((String)session.getAttribute("class"))!=null){
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
				String patient_id=request.getParameter("ID").trim();
				String op=request.getParameter("OPERATION").trim();
				Statement s=con.createStatement();
				if(op.equals("Add")){
					out.println("<H1><CENTER><font color =Teal>Choose a Family Doctor to Add :</font></CENTER></H1>");
					out.println("<FORM NAME='AddFamilyDocForm' ACTION='CommitUpdateFamilyDoctor.jsp' METHOD='post'>");
					//Content
					out.println("<CENTER>");
					out.println("	<SELECT NAME='doctor_id'>");
					String sql="(SELECT * FROM persons p WHERE p.person_id = ANY(SELECT u.person_id FROM users u WHERE u.class='d')) MINUS (SELECT * FROM persons p2 WHERE p2.person_id = ANY(SELECT fd.doctor_id FROM family_doctor fd WHERE fd.patient_id="+patient_id+"))";
					ResultSet resSet=s.executeQuery(sql);
					int cnt=0;
					while(resSet.next()){
						Integer doctor_id=resSet.getInt("person_id");
						String fname=resSet.getString("first_name");
						String lname=resSet.getString("last_name");
						out.println("<OPTION VALUE='"+doctor_id+"' SELECTED> "+fname+" "+lname+" ,ID: "+doctor_id+"</OPTION>");
						cnt++;
					}
					out.println("	</SELECT>");
					out.println("</CENTER>");
					out.println("<INPUT TYPE='hidden' NAME='patient_id' VALUE='"+patient_id+"'>");
					if(cnt!=0){
						out.println("    <CENTER><INPUT TYPE='submit' NAME='Update' VALUE='Add'></CENTER>");
					}
					out.println("</FORM>");
				}
				else{
					out.println("<H1><CENTER><font color =Teal>Choose a Family Doctor to Remove :</font></CENTER></H1>");
					out.println("<FORM NAME='AddFamilyDocForm' ACTION='CommitUpdateFamilyDoctor.jsp' METHOD='post'>");
					//Content
					out.println("<CENTER>");
					out.println("	<SELECT NAME='doctor_id'>");
					String sql="SELECT * FROM persons p2 WHERE p2.person_id = ANY(SELECT fd.doctor_id FROM family_doctor fd WHERE fd.patient_id="+patient_id+")";
					ResultSet resSet=s.executeQuery(sql);
					int cnt=0;
					while(resSet.next()){
						Integer doctor_id=resSet.getInt("person_id");
						String fname=resSet.getString("first_name");
						String lname=resSet.getString("last_name");
						out.println("<OPTION VALUE='"+doctor_id+"' SELECTED> "+fname+" "+lname+" ,ID: "+doctor_id+"</OPTION>");
						cnt++;
					}
					out.println("	</SELECT>");
					out.println("</CENTER>");
					out.println("<INPUT TYPE='hidden' NAME='patient_id' VALUE='"+patient_id+"'>");
					if(cnt!=0){
						out.println("    <CENTER><INPUT TYPE='submit' NAME='Update' VALUE='Remove'></CENTER>");
					}
					out.println("</FORM>");
					out.println("<FORM NAME='CancelForm' ACTION='AdminPage.jsp' METHOD='get'>");
					out.println("<Center><INPUT TYPE='submit' NAME='cancel' VALUE='CANCEL'></Center>");
					out.println("</FORM>");
				}
				con.close();
			}
		}
		else{
			response.sendRedirect("Login.html");
		}
	%>
</BODY>
</HTML>
