<HTML>
<HEAD>
	<TITLE>Update Family Doctor Page</TITLE>
</HEAD>
<BODY>
	<%@ page import="java.sql.*"%>
	<%
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
			Statement s=con.createStatement();
			String patient_id=request.getParameter("patient_id").trim();
			String doctor_id=request.getParameter("doctor_id").trim();
			if(request.getParameter("Update").trim().equals("Add")){
				String sql="INSERT INTO family_doctor VALUES("+doctor_id+","+patient_id+")";
				try{
					s.executeQuery(sql);
				}
				catch(Exception e){
					out.println("<p><b>"+e.getMessage()+"</b></p>");
					out.println("<p><b>Press RETURN to the previous page.</b></p>");
					out.println("<FORM NAME='AbortForm' ACTION='ManageFamilyDoctor.jsp' METHOD='get'>");
					out.println("    <CENTER><INPUT TYPE='submit' NAME='return' VALUE='RETURN'></CENTER>");
					out.println("</FORM>");
				}
			}
			else if(request.getParameter("Update").trim().equals("Remove")){
				String sql="DELETE FROM family_doctor WHERE doctor_id="+doctor_id+" AND patient_id="+patient_id;
				try{
					s.executeQuery(sql);
				}
				catch(Exception e){
					out.println("<p><b>"+e.getMessage()+"</b></p>");
					out.println("<p><b>Press RETURN to the previous page.</b></p>");
					out.println("<FORM NAME='AbortForm' ACTION='ManageFamilyDoctor.jsp' METHOD='get'>");
					out.println("    <CENTER><INPUT TYPE='submit' NAME='return' VALUE='RETURN'></CENTER>");
					out.println("</FORM>");
				}
			}
			con.close();
			response.sendRedirect("AdminPage.jsp");
		}
	%>
</BODY>
</HTML>